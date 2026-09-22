# These two ARNs are the whole point of this layer, and neither is consumed
# automatically — both are wired by hand into infrastructure this repository
# does not own. See the "Prerequisites on the AWS side" section of the README
# for the two places each one goes:
#
#   1. the agent's assume_role_arns, so it is allowed to assume them at all
#   2. the aws-iam-configuration provider, under the selectors
#      "documentdb-cluster" and "documentdb-database", which is where
#      utils/assume_role_step looks them up at runtime
#
# Miss (1) and sts:AssumeRole is denied. Miss (2) and the step finds no ARN for
# its selector, silently falls back to the agent's own credentials, and fails
# later on a permission the agent was never meant to have.
#
# Named <slug>_assume_role_arn to match the convention the nullplatform
# infrastructure wizard uses for every other scope and service, so these drop
# into an existing setup without renaming.

output "documentdb_cluster_assume_role_arn" {
  value       = module.documentdb_cluster_requirements.permissions_role_arn
  description = "ARN of the permissions role for the documentdb-cluster service (selector: documentdb-cluster)"
}

output "documentdb_database_assume_role_arn" {
  value       = module.documentdb_database_requirements.permissions_role_arn
  description = "ARN of the permissions role for the documentdb-database service (selector: documentdb-database)"
}
