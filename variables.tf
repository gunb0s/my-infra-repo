variable "name" {
  type = string
  description = "The name of the instance"
  default = "terraform-example"
}

variable "allowed_repos_branches" {
  description = "GitHub repos/branches allowed to assume the IAM role."
  type = list(object({
    org    = string
    repo   = string
    branch = string
  }))
  default = [ {
    org = "gunb0s"
    repo = "my-infra-repo"
    branch = "main"
  } ]
  # Example:
  # allowed_repos_branches = [
  #   {
  #     org    = "brikis98"
  #     repo   = "terraform-up-and-running-code"
  #     branch = "main"
  #   }
  # ]
}
