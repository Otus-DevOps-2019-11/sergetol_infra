terraform {
  backend "gcs" {
    bucket = "tf-state-strg-bckt"
    prefix = "terraform/state/prod"
  }
}
