variable "nrn" {
  type        = string
  description = "Account NRN, e.g. organization=<org-id>:account=<account-id>"
}

variable "np_api_key" {
  type        = string
  sensitive   = true
  description = "nullplatform API key the terraform provider authenticates with. It is not embedded in the notification channels: nullplatform manages their credentials. It must be able to assign the controlplane:agent-dispatcher role. Pass through TF_VAR_np_api_key; never put it in a file."
}

variable "tags_selectors" {
  type        = map(string)
  description = "Tags that select which agent handles these services. The agent MUST be started with the matching -tags flag, e.g. tags_selectors = { owner = \"platform\" } requires -tags \"owner:platform\". A mismatch delivers the notification and never executes it — and the service still shows as active in the UI."
}

variable "nullplatform_state_path" {
  type        = string
  default     = "../nullplatform/terraform.tfstate"
  description = "Path to the state of the nullplatform/ layer, which must be applied first. Replace with your real backend config."
}
