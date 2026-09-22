variable "cluster_name" {
  type        = string
  description = "Name of the cluster where the nullplatform agent runs. Drives every derived name: the roles become nullplatform_<cluster_name>_documentdb_cluster_role and nullplatform_<cluster_name>_documentdb_database_role, and the trusted agent role defaults to nullplatform-<cluster_name>-agent-role. Get it wrong and the apply still succeeds — it just creates roles nothing assumes."
}

variable "agent_role_arn" {
  type        = string
  default     = ""
  description = "ARN of the agent's IRSA role, which the trust policy of both roles allows to call sts:AssumeRole. Leave empty to derive arn:aws:iam::<this account>:role/nullplatform-<cluster_name>-agent-role. Set it only if your agent role does not follow that convention — the derived default is what a standard nullplatform install produces."
}

variable "iam_resource_tags_json" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the roles and policies created here, merged with the modules' own ManagedBy and Module tags."
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Region for the AWS provider. IAM is global, so this only selects the endpoint — it does NOT have to match the region the DocumentDB clusters are created in."
}
