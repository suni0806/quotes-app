# Backend configuration for Production environment
resource_group_name  = "statefile"
storage_account_name = "statefiletest001"
container_name       = "tfstate"
key                  = "production/quotes-app.tfstate"
