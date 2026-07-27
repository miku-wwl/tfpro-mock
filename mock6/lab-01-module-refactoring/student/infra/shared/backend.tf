terraform {
  backend "s3" {
    bucket = "northstar-amusing-piglet-tfstate"
    key    = "tfpro-sim/final-06/lab-01/shared.tfstate"
    region = "us-east-1"
  }
}
