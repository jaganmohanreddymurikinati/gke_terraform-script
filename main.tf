#initialize the terraform 
# terraform init

# Apply the terraform script
# terraform apply -auto-approve

# release resources and avoid cost
# terraform destroy -auto-approve


provider "google"{
    project=var.project_id
    region=var.region
    #credentials = file("C:/Users/anush/OneDrive/Desktop/gcp/monitoring-terraform-script/auth.json")
}

resource "google_container_cluster" "primary"{
    name=var.cluster_name
    location=var.region 
    
    remove_default_node_pool=true 
    deletion_protection = false
    initial_node_count=1 
    lifecycle{
        ignore_changes = [ initial_node_count ]
    }
}

resource "google_container_node_pool" "primary_nodes"{
    name="default-pool"
    cluster=google_container_cluster.primary.id 
    location=var.region
    
    node_count=var.node_count
    node_config{
        machine_type="e2-medium"
        disk_size_gb=10 
        preemptible=true 
        oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    }
# Disable auto-scaling
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
}

