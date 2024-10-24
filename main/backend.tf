terraform {
  backend "s3" {
    bucket         = "p-trfm-state-back.demo"
    dynamodb_table = "p-trfm-state-lock.demo"
    encrypt        = true
    key            = "projects/p-trfm-state-back.demo.tfstate"
    region         = "us-east-1"
  }
}