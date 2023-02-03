provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "clis" {
  alias = "clis1"

  bin_dir = ".bin3"
}
