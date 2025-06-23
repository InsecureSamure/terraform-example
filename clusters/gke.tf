resource "google_container_cluster" "k-dotnet-api" {
  name = "dotnet-api-cluster"
  location = "us-east1"
  initial_node_count = "1"

  master_auth {
      username = "username"
      password = "password-or-more-chars"
  }

  node_config {
      oauth_scopes = [
          "https://www.googleapis.com/auth/compute",
          "https://www.googleapis.com/auth/devstorage.read_only",
          "https://www.googleapis.com/auth/logging.write",
          "https://www.googleapis.com/auth/monitoring"
      ]
  } 

}
