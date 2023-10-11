##################################################### CREATING RESOURCE GROUP ############################################################
resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.region
}

################################################ CREATING VNET WITH TWO SUBNETS ############################################################
resource "azurerm_virtual_network" "vnet" { 
  name                = var.vnet
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

 resource "azurerm_subnet" "snet-library-web" {
  name                 = "snet-library-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "snet-library-db" {
  name                 = "snet-library-db"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

######################################################## CREATING NSGs ####################################################################


# NSG for the web
resource "azurerm_network_security_group" "nsg-library-web" {
  name                = "nsg-library-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Inbound rule for the web nsg
resource "azurerm_network_security_rule" "inboundrule" {
  name                        = "allow_inbound_5000"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg-library-web.name
}

# Web subnet association to nsg-web 
resource "azurerm_subnet_network_security_group_association" "subnet_web_nsg_association" {
  subnet_id                 = azurerm_subnet.snet-library-web.id
  network_security_group_id = azurerm_network_security_group.nsg-library-web.id
}




#-------------------------------------------------------------------------------------------------------------------------------------------

# Creating NSG for db subnet
resource "azurerm_network_security_group" "nsg-library-db" {
  name                = "nsg-library-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Inbound rule for nsg-db
resource "azurerm_network_security_rule" "allow_inbound_5432_snet-db" {
  name                        = "allow_inbound_5432"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg-library-db.name
}

# Database subnet association to nsg
resource "azurerm_subnet_network_security_group_association" "subnet_db_nsg_association" {
  subnet_id                 = azurerm_subnet.snet-library-db.id
  network_security_group_id = azurerm_network_security_group.nsg-library-db.id
}




#################################################### CREATING WEB VIRTUAL MACHINE #########################################################

# Create an Ubuntu VM for the web app
resource "azurerm_linux_virtual_machine" "vm-library-web" {
  name                = "vm-library-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_DS2_v2"

  admin_username = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [azurerm_network_interface.nic-library-web.id]

  os_disk {
    name              = "osdisk-library-web"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "dev"
  }
}

# Create public IP
resource "azurerm_public_ip" "web-public-ip" {
  name                = "library-web-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create a network interface
resource "azurerm_network_interface" "nic-library-web" {
  name                = "NIC-library-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "NICConfig-library-web"
    subnet_id                     = azurerm_subnet.snet-library-web.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.1.7"
    public_ip_address_id          = azurerm_public_ip.web-public-ip.id
  }
}


##################################################### CREATING DB VIRTUAL MACHINE #########################################################


# Create an Ubuntu VM for the db app
resource "azurerm_linux_virtual_machine" "vm-library-db" {
  name                = "vm-library-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_DS2_v2"

  admin_username = "adminuser"

   admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [azurerm_network_interface.nic-library-db.id]

  os_disk {
    name              = "osdisk-library-db"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "dev"
  }
}

# Create a network interface
resource "azurerm_network_interface" "nic-library-db" {
  name                = "NIC-library-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "NICConfig-library-db"
    subnet_id                     = azurerm_subnet.snet-library-db.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.2.5"
  }
}


####################################################### CREATING EXTENSION FOR DB VM #########################################################

resource "azurerm_virtual_machine_extension" "postgresql_script" {
  name                 = "postgresql_on_db-library"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm-library-db.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"


  protected_settings = <<PROT
    {
         "commandToExecute": "git clone https://github.com/LiyaKeidar1/terraformLibrary.git &&
          cd terraformLibrary/scripts &&
          chmod +x PostgreSQL_script.sh && 
          ./PostgreSQL_script.sh ${var.password-db}"
    }
    PROT

}


###################################################### CREATING EXTENSION FOR WEB VM #########################################################

resource "azurerm_virtual_machine_extension" "flask-commands" {
  name                 = "flask_on_web-library"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm-library-web.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 =  "CustomScript"
  type_handler_version = "2.1"


  protected_settings = <<-EOT
{
    "commandToExecute": "git clone https://github.com/LiyaKeidar1/terraformLibrary.git &&
     cd terraformLibrary/scripts &&
      chmod +x Flask_script1.sh &&
       ./Flask_script1.sh ${var.password-db}"
}
EOT


}
