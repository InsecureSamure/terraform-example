# Google Cloud Platform

resource "google_compute_instance" "firstserver" {
    name = "thefirstserver"
    machine_type = "n1-standard-1"
    zone = "us-east1-b"

    boot_disk {
        initialize_params {
            image = "centos-7-v20190515"
        }
    }

    network_interface {
        subnetwork = "${google_compute_subnetwork.dev-subnet.name}"
        access_config { }
    }

    metadata = {
        foo = "bar"
    }

    service_account {
        scopes = ["userinfo-email", "compute-ro", "storage-ro"]
    }
}


# Amazon Web Services

data "aws_ami" "centos" {
    most_recent = true

    filter {
        name = "name"
        values = ["ami-centos-7*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["285398391915"]
}

resource "aws_instance" "second_server" {
    ami = "${data.aws_ami.centos.id}"
    instance_type = "t2.micro"

    tags = {
        Name = "name of the server"
    }
    subnet_id = "${aws_subnet.subnet1.id}"
}

# Azure

resource "azurerm_virtual_machine" "third_server" {
  name = "server-name"
  location = "West US"
  resource_group_name = "${azurerm_resource_group.azy_network.name}"
  network_interface_ids = ["${azurerm_network_interface.blue_network_interface.id}"]
  vm_size = "Standard_DS1_v2"
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination = true

  storage_image_reference {
      publisher = "OpenLogic"
      offer = "CentOS"
      sku = "7.5"
      version = "latest"
  }

  storage_os_disk {
      name = "myosdisk1"
      caching = "ReadWrite"
      create_option = "FromImage"
      managed_disk_type = "Standard_LRS"
  }

  os_profile {
      computer_name = "hostname"
      admin_password = "Password1234!"
      admin_username = "testadmin"
  }
  os_profile_linux_config {
      disable_password_authentication = false
  }
}
