data "terraform_remote_state" "projects" {
  for_each = toset(local.core_workspaces)
  backend  = "s3"
  config = {
    bucket               = "project.ht.tg01"
    key                  = "projects/project.ht.tg01.tfstate"
    region               = "us-east-1"
    workspace_key_prefix = "env:"
  }
  workspace = each.key
}
