# Terraform Variables That Will Be Referenced In "main.tf" Google Cloud Resource Terraform Configuration
variable "project" {
  type = string
  default = "ac-rftexchange-dev-project"
}

variable "location" {
  type = string
  default = "US"
}

variable "region" {
  type = string
  default = "us-central1"
}

variable "zone" {
  type = string
  default = "us-central1-a"
}

# Either implicitly by using a default value of empty brackets:
variable "cidrs" { default = [] }

variable "environment" {
  type = string
  default = "master"
}

variable "machine_types" {
  type = map(string)
  default = {
    "worker" = "n1-standard-8"
    "master" = "c2-standard-8"
    "preemptible" = "c2-standard-8"
  }
}

variable "disk_type" {
  type = map(string)
  default = {
    "worker" = "pd-ssd"
    "master" = "pd-ssd"
    "preemptible" = "pd-ssd"
  }
}

variable "disk_image" {
   type = string
   default = "debian-cloud/debian-10"
 }

variable "disk_size" {
  type = map(string)
  default = {
    "worker" = 100
    "master" = 200
  }
}

variable "count_server" {
  type = map(string)
  default = {
    "worker" = 2
    "master" = 1
    "preemptible" = 0
  }
}

variable "service_account" {
  type = string
  default = "tf-cloud@ac-rftexchange-dev-project.iam.gserviceaccount.com"
  #default="20490098264-compute@developer.gserviceaccount.com"
}

variable "image_version" {
  type = string
  default = "2.0-debian10"
  
}


variable "staging_bucket" {
  type = string
  default = "ac-rftexchange-dev-project-dataproc-staging"
}
