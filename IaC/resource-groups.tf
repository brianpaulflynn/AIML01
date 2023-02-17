resource "azurerm_resource_group" "default" {
  name     = "${var.name}-${var.environment}-rg"
  location = var.location
}

# resource "azurerm_resource_group" "ds" {
#   name     = "rcs-datascience"
#   location = "${var.location}"
# }