terraform {
  cloud {
    organization = "terraform-tom"
    workspaces {
      name = "lock-file-test"
    }
  }
  required_providers {
    random = {
      source  = "app.terraform.io/terraform-tom/random"
      version = "3.7.2"
    }
  }
}

variable "sleep_duration_seconds" {
  description = "Number of seconds to sleep"
  type        = number
  default     = 1
}

resource "random_pet" "name" {
  prefix = timestamp()

  provisioner "local-exec" {
    command = "sleep ${var.sleep_duration_seconds}"
  }
}

output "name" {
  value = random_pet.name.id
}
