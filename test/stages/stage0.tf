terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    template = {
      source = "hashicorp/template"
    }
    clis = {
      source  = "cloud-native-toolkit/clis"
    }
  }
}

data clis_check clis1 {
  provider = clis.clis1

  clis = ["kubectl", "oc"]
}

resource local_file bin_dir {
  filename = "${path.cwd}/.bin_dir"

  content = data.clis_check.clis1.bin_dir
}
