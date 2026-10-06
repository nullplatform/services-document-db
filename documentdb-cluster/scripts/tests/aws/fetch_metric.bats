#!/usr/bin/env bats

load helpers

setup() {
	setup_mocks
	export CONTEXT
	CONTEXT=$(metric_context "$(jq -n --argjson service "$(cluster_service)" '{
		metric: "CPUUtilization",
		start_time: "2026-10-02T10:00:00.000Z",
		end_time: "2026-10-02T11:00:00.000Z",
		period: 300,
		service_id: "0f3a6b1e-9c2d-4e8f-a1b2-c3d4e5f60718",
		service: $service
	}')")
}

@test "queries cloudwatch for the cluster with the window, period and statistic of the metric" {
	run_script fetch_metric
	[ "$status" -eq 0 ]
	assert_contains "$(cat "$MOCK_LOG")" "aws cloudwatch get-metric-statistics --region us-west-2 --namespace AWS/DocDB --metric-name CPUUtilization --dimensions Name=DBClusterIdentifier,Value=np-my-docdb-0f3a6 --start-time 2026-10-02T10:00:00.000Z --end-time 2026-10-02T11:00:00.000Z --period 300 --statistics Average --output json"
}

@test "returns the datapoints sorted by timestamp in the telemetry format" {
	export MOCK_CW_RESPONSE='{"Label":"CPUUtilization","Datapoints":[{"Timestamp":"2026-10-02T10:05:00+00:00","Average":91.5,"Unit":"Percent"},{"Timestamp":"2026-10-02T10:00:00+00:00","Average":88,"Unit":"Percent"}]}'
	run_script fetch_metric
	[ "$status" -eq 0 ]
	assert_equal "$captured_stdout" '{"metric":"CPUUtilization","type":"gauge","period_in_seconds":300,"unit":"percent","results":[{"selector":{"cluster_identifier":"np-my-docdb-0f3a6"},"data":[{"timestamp":"2026-10-02T10:00:00+00:00","value":88},{"timestamp":"2026-10-02T10:05:00+00:00","value":91.5}]}]}'
}

@test "prints only the result and logs nothing when the query succeeds" {
	export MOCK_CW_RESPONSE='{"Label":"CPUUtilization","Datapoints":[{"Timestamp":"2026-10-02T10:00:00+00:00","Average":88}]}'
	run_script fetch_metric
	[ "$status" -eq 0 ]
	assert_equal "$(echo "$captured_stdout" | wc -l | tr -d ' ')" "1"
	echo "$captured_stdout" | jq -e '.results[0].data[0].value == 88'
	assert_equal "$captured_stderr" ""
}

@test "uses the statistic and unit that belong to each metric" {
	for pair in "CPUUtilization:Average:percent" "DatabaseConnections:Maximum:count" "FreeableMemory:Minimum:bytes" "VolumeBytesUsed:Maximum:bytes" "OpcountersQuery:Sum:count"; do
		IFS=: read -r metric statistic unit <<<"$pair"
		CONTEXT=$(echo "$CONTEXT" | jq --arg metric "$metric" '.arguments.metric = $metric')
		: >"$MOCK_LOG"
		run_script fetch_metric
		[ "$status" -eq 0 ]
		assert_contains "$(cat "$MOCK_LOG")" "--metric-name ${metric} "
		assert_contains "$(cat "$MOCK_LOG")" "--statistics ${statistic} "
		assert_equal "$(echo "$captured_stdout" | jq -r '.unit')" "$unit"
	done
}

@test "rounds the period up to a multiple of sixty seconds" {
	CONTEXT=$(echo "$CONTEXT" | jq '.arguments.period = 90')
	run_script fetch_metric
	[ "$status" -eq 0 ]
	assert_contains "$(cat "$MOCK_LOG")" "--period 120 "
	assert_equal "$(echo "$captured_stdout" | jq '.period_in_seconds')" "120"

	CONTEXT=$(echo "$CONTEXT" | jq '.arguments.period = 15')
	run_script fetch_metric
	assert_contains "$(cat "$MOCK_LOG")" "--period 60 "

	CONTEXT=$(echo "$CONTEXT" | jq 'del(.arguments.period)')
	run_script fetch_metric
	[ "$status" -eq 0 ]
	assert_equal "$(echo "$captured_stdout" | jq '.period_in_seconds')" "60"
}

@test "falls back to the last hour when the request has no window" {
	CONTEXT=$(echo "$CONTEXT" | jq 'del(.arguments.start_time, .arguments.end_time)')
	run_script fetch_metric
	[ "$status" -eq 0 ]
	[[ "$(cat "$MOCK_LOG")" =~ --start-time\ [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]{8}Z\ --end-time\ [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]{8}Z ]]
}

@test "reads the region from the cluster endpoint" {
	CONTEXT=$(echo "$CONTEXT" | jq '.arguments.service.attributes.endpoint = "x.cluster-abc.eu-central-1.docdb.amazonaws.com"')
	run_script fetch_metric
	[ "$status" -eq 0 ]
	assert_contains "$(cat "$MOCK_LOG")" "--region eu-central-1 "
}

@test "never reads the service from the api because the request always carries its attributes" {
	CONTEXT=$(echo "$CONTEXT" | jq 'del(.arguments.service.attributes)')
	run_script fetch_metric
	[ "$status" -eq 0 ]
	assert_not_contains "$(cat "$MOCK_LOG")" "np "
}

@test "returns an empty series without calling cloudwatch while the cluster does not exist yet" {
	CONTEXT=$(echo "$CONTEXT" | jq 'del(.arguments.service.attributes)')
	run_script fetch_metric
	[ "$status" -eq 0 ]
	assert_equal "$captured_stdout" '{"metric":"CPUUtilization","type":"gauge","period_in_seconds":300,"unit":"percent","results":[]}'
	assert_equal "$captured_stderr" ""
	assert_not_contains "$(cat "$MOCK_LOG")" "cloudwatch"
}

@test "returns an empty series when the endpoint is not written yet" {
	CONTEXT=$(echo "$CONTEXT" | jq '.arguments.service.attributes.endpoint = ""')
	run_script fetch_metric
	[ "$status" -eq 0 ]
	assert_equal "$(echo "$captured_stdout" | jq -c '.results')" '[]'
	assert_equal "$(cat "$MOCK_LOG")" ""
}

@test "returns an empty series when the endpoint carries no region" {
	CONTEXT=$(echo "$CONTEXT" | jq '.arguments.service.attributes.endpoint = "something.example.com"')
	run_script fetch_metric
	[ "$status" -eq 0 ]
	assert_equal "$(echo "$captured_stdout" | jq -c '.results')" '[]'
	assert_equal "$(cat "$MOCK_LOG")" ""
}

@test "fails on an unknown metric" {
	CONTEXT=$(echo "$CONTEXT" | jq '.arguments.metric = "BufferCacheHitRatio"')
	run_script fetch_metric
	[ "$status" -ne 0 ]
	assert_contains "$captured_stderr" "unknown metric 'BufferCacheHitRatio'"
	assert_not_contains "$(cat "$MOCK_LOG")" "cloudwatch"
}

@test "fails on a malformed time window" {
	CONTEXT=$(echo "$CONTEXT" | jq '.arguments.start_time = "yesterday --region evil"')
	run_script fetch_metric
	[ "$status" -ne 0 ]
	assert_contains "$captured_stderr" "is not a UTC ISO 8601 timestamp"
	assert_not_contains "$(cat "$MOCK_LOG")" "cloudwatch"
}

@test "returns an empty series when the endpoint region is not a valid region" {
	CONTEXT=$(echo "$CONTEXT" | jq '.arguments.service.attributes.endpoint = "x.cluster-abc.bad region.docdb.amazonaws.com"')
	run_script fetch_metric
	[ "$status" -eq 0 ]
	assert_equal "$(echo "$captured_stdout" | jq -c '.results')" '[]'
	assert_not_contains "$(cat "$MOCK_LOG")" "cloudwatch"
}

@test "fails on a cluster identifier that is not a valid identifier" {
	CONTEXT=$(echo "$CONTEXT" | jq '.arguments.service.attributes.cluster_identifier = "x --region evil"')
	run_script fetch_metric
	[ "$status" -ne 0 ]
	assert_contains "$captured_stderr" "is not a DocumentDB cluster identifier"
	assert_not_contains "$(cat "$MOCK_LOG")" "cloudwatch"
}

@test "fails instead of returning an empty series when cloudwatch rejects the query" {
	export MOCK_CW_EXIT=254
	run_script fetch_metric
	[ "$status" -ne 0 ]
	assert_contains "$captured_stderr" "AccessDenied"
	assert_contains "$captured_stderr" "CloudWatch rejected the CPUUtilization query for np-my-docdb-0f3a6 in us-west-2"
}

@test "makes exactly one aws call and none to np for every metric" {
	for metric in CPUUtilization DatabaseConnections FreeableMemory VolumeBytesUsed OpcountersQuery; do
		CONTEXT=$(echo "$CONTEXT" | jq --arg metric "$metric" '.arguments.metric = $metric')
		: >"$MOCK_LOG"
		run_script fetch_metric
		[ "$status" -eq 0 ]
		assert_equal "$(grep -c '^aws ' "$MOCK_LOG")" "1"
		assert_contains "$(grep '^aws ' "$MOCK_LOG")" "aws cloudwatch get-metric-statistics"
		assert_not_contains "$(cat "$MOCK_LOG")" "np "
	done
}

@test "never runs a command smuggled in a non-string request field" {
	marker="$BATS_TEST_TMPDIR/pwned"
	for field in metric start_time end_time period; do
		CONTEXT=$(echo "$CONTEXT" | jq --arg field "$field" --arg marker "$marker" '.arguments[$field] = ["x", "touch", $marker]')
		run_script fetch_metric
		[ ! -e "$marker" ]
	done
	for field in cluster_identifier endpoint; do
		CONTEXT=$(echo "$CONTEXT" | jq --arg field "$field" --arg marker "$marker" '.arguments.service.attributes[$field] = ["x", "touch", $marker]')
		run_script fetch_metric
		[ ! -e "$marker" ]
	done
}
