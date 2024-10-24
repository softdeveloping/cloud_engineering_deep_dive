terraform {
  backend "s3" {
    bucket         = "project.ht.tg01"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    key            = "projects/project.ht.tg01.tfstate"
    region         = "us-east-1"
  }
}