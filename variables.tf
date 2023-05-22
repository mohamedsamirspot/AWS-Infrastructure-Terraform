variable "aws_profile" {
  type    = string
  default = "spot_profile"
}

# should be list of string
variable "aws_shared_config_files" {
  type    = list(string)
  default = ["~/.aws/config"]
}

# should be list of string
variable "aws_shared_credentials_files" {
  type    = list(string)
  default = ["~/.aws/credentials"]
}