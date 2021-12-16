# Terraform Provider's
provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project
  region  = var.region
  zone    = var.zone
}  

terraform {
  backend "remote" {
    organization = "rft-exchange" /*Terraform Cloud - Organization*/

    workspaces {
      name = "gcp-training-sk" /*Terraform Cloud - Workspace*/
    }
  }
}

resource "google_composer_environment" "test" {
  project = var.project
  provider = google-beta
  name   = "composer-dev"
  region = "us-central1"
  config {
    
    software_config {
      #scheduler_count = 2         #only in Composer 1 with Airflow 2, use workloads_config in Composer 2
      airflow_config_overrides = {
        core-dags_are_paused_at_creation = "True"
      }

      #pypi_packages = {
      #  numpy = ""
      #  scipy = "==1.1.0"
      #}

      env_variables = {
        FOO = "bar"
      }
    }
    
    database_config {
      machine_type = "db-n1-standard-2"
    }

    web_server_config {
      machine_type = "composer-n1-webserver-2"
    }
    
    node_count = 4

    node_config {
      zone         = "us-central1-a"
      machine_type = "n1-standard-1"

      network    = google_compute_network.test.id
      subnetwork = google_compute_subnetwork.test.id

      service_account = google_service_account.test.name
      
      ip_allocation_policy {
        use_ip_aliases = true
        cluster_secondary_range_name = "composer-sec-ip-range-pod"
        #cluster_secondary_range_cidr = "10.16.0.0/12"
        
        services_secondary_range_name = "composer-sec-ip-range-services"
        #services_secondary_range_cidr = "10.1.0.0/20"
      }

      tags = ["composer-gke-master", "composer-gke-nodes", "composer-gke-pods"]
    }

        
    private_environment_config {
      enable_private_endpoint = true
      
      master_ipv4_cidr_block = "172.16.20.0/23"
      cloud_sql_ipv4_cidr_block = "10.0.0.0/12"
      web_server_ipv4_cidr_block = "172.31.245.0/24"
    }
    
    #web_server_network_access_control {
    #}
  }
}

resource "google_compute_network" "test" {
  project = var.project
  name                    = "composer-test-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "test" {
  project = var.project#
  name          = "composer-test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.test.id
  private_ip_google_access = true
  secondary_ip_range {
    range_name    = "composer-sec-ip-range-pod"
    ip_cidr_range = "10.3.0.0/16"
  }
  secondary_ip_range {
    range_name    = "composer-sec-ip-range-services"
    ip_cidr_range = "10.4.0.0/16"
  }
}

resource "google_service_account" "test" {
  project = var.project
  account_id   = "composer-env-sa"
  display_name = "Test Service Account for Composer Environment"
}

resource "google_project_iam_member" "composer-worker" {
  project = var.project
  role   = "roles/composer.worker"
  member = "serviceAccount:${google_service_account.test.email}"
}
