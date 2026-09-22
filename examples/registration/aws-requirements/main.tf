# ---------------------------------------------------------------------------
# Layer 0 — AWS IAM requirements. Apply BEFORE nullplatform/.
#
# Numbered 0 rather than 1 because it is a different kind of thing: layers 1
# and 2 register the service with nullplatform, this one grants the agent
# permission to actually do the work. Registering without applying this
# succeeds, and then every action fails at plan time on an UnauthorizedOperation.
#
# Like the other two layers, this directory does NOT belong in the service
# repository — it belongs in the infrastructure repo of whoever installs the
# service. It lives here as a ready-to-copy example, which is also why it
# carries no backend block.
#
# WHY THIS IS NOT PART OF SERVICE CREATION, since it is the first thing people
# ask: the agent must already hold sts:AssumeRole on these role ARNs before it
# can run any workflow, so a workflow cannot create the role it needs to run
# as. The agent also deliberately has no iam:CreateRole or iam:AttachRolePolicy
# — if a service package could mint roles and attach policies, it could escalate
# to admin in the customer's account. Creating roles is the installer's job;
# the agent only ever assumes roles that already exist.
#
# RE-APPLY THIS LAYER WHENEVER THE POLICIES CHANGE. The IAM lives in AWS, not
# in the package, so pulling a new tag of this repository and re-registering
# the service changes nothing about permissions. A missing action shows up as
# UnauthorizedOperation on the first plan, which reads like a service bug and
# is not one.
# ---------------------------------------------------------------------------

# IAM is global; the region only picks the endpoint these calls go to.
provider "aws" {
  region = var.aws_region
}

# Terraform cannot interpolate a module source, so the ref is repeated
# literally in each block rather than held in a variable — bump both together.
#
# Pinned to a tag, never to main. The nullplatform catalog documents what
# pinning a branch costs: a sibling repo renamed its requirements path from the
# long-standing misspelling "requeriments" to "requirements", and every setup
# tracking main broke at `tofu init` the moment it landed. A tag is unaffected.
#
# Bump both refs together when adopting a new release. v0.1.0 is this
# repository's first release; its IAM policies were verified against a live
# account end to end: create, link and delete on the cluster, create and link
# on the database.
module "documentdb_cluster_requirements" {
  source = "git::https://github.com/nullplatform/services-document-db.git//documentdb-cluster/specs/requirements/aws?ref=v0.1.0"

  cluster_name           = var.cluster_name
  agent_role_arn         = var.agent_role_arn
  iam_resource_tags_json = var.iam_resource_tags_json
}

module "documentdb_database_requirements" {
  source = "git::https://github.com/nullplatform/services-document-db.git//documentdb-database/specs/requirements/aws?ref=v0.1.0"

  cluster_name           = var.cluster_name
  agent_role_arn         = var.agent_role_arn
  iam_resource_tags_json = var.iam_resource_tags_json
}
