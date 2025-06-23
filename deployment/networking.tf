
# Google Cloud Platform
resource "google_compute_network" "our_development_network" {
  name = "devnetwork"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "dev-subnet" {
  ip_cidr_range = "10.0.1.0/24"
  name = "devsubnet"
  network = "${google_compute_network.our_development_network.self_link}"
  region = "us-east1"
}


# Amazon Web Services
resource "aws_vpc" "environment-example-two" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "terraform-aws-vpc-example-two"
  }
}

resource "aws_subnet" "subnet1" {
    cidr_block = "${cidrsubnet(aws_vpc.environment-example-two.cidr_block, 3, 1)}"
    vpc_id = "${aws_vpc.environment-example-two.id}"
    availability_zone = "us-east-2a"
}

resource "aws_subnet" "subnet2" {
    cidr_block = "${cidrsubnet(aws_vpc.environment-example-two.cidr_block, 2, 2)}"
    vpc_id = "${aws_vpc.environment-example-two.id}"
    availability_zone = "us-east-2b"
}

resource "aws_security_group" "subnetsecurity" {
    vpc_id = "${aws_vpc.environment-example-two.id}"

    ingress {
        cidr_blocks = [
            "${aws_vpc.environment-example-two.cidr_block}"
        ]

        from_port = 80
        to_port = 80
        protocol = "tcp"
    }

    egress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"

        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }
}


# Azure 

resource "azurerm_resource_group" "azy_network" {
  location = "West US"
  name = "dev-resource-group"
}

resource "azurerm_virtual_network" "blue_virtual_network" {
  address_space = ["10.0.0.0/16"]
  location = "West US"
  name = "blue-virt-network"
  resource_group_name = "${azurerm_resource_group.azy_network.name}"
  dns_servers = ["10.0.0.4", "10.0.0.5"]

  subnet {
      name = "subnet1"
      address_prefix = "10.0.0.0/24"
  }

  subnet {
      name = "subnet2"
      address_prefix = "10.0.2.0/24"      
  }

  tags = {
      environment = "blue-world-finder"
  }
}

resource "azurerm_subnet" "az_subnet1" {
  name = "subnet1"
  address_prefix = "10.0.0.0/24"
  virtual_network_name = "${azurerm_virtual_network.blue_virtual_network.name}"
  resource_group_name = "${azurerm_resource_group.azy_network.name}"
}

resource "azurerm_subnet" "az_subnet2" {
  name = "subnet2"
  address_prefix = "10.0.2.0/24"
  virtual_network_name = "${azurerm_virtual_network.blue_virtual_network.name}"
  resource_group_name = "${azurerm_resource_group.azy_network.name}"
}

resource "azurerm_network_interface" "blue_network_interface" {
  name = "nic-blue"
  location = "West US"
  resource_group_name = "${azurerm_resource_group.azy_network.name}"
  
  ip_configuration {
    name = "testconfiguration1"
    subnet_id = "${azurerm_subnet.az_subnet1.id}"
    private_ip_address_allocation = "Dynamic"
  }
}
