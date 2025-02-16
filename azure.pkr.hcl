variable "client_id" {
  type    = string
  default = "538e2a9d-4a51-4c75-b789-2719c27bd63c"
}

variable "client_secret" {
  type    = string
  default = "mMA8Q~VawRRI9YC1rny6zpPyDxAG5iENl2N3KbIA"
}

variable "tenant_id" {
  type    = string
  default = "b1051c4b-3b94-41ab-9441-e73a72342fdd"
}

variable "subscription_id" {
  type    = string
  default = "bf6508bd-9810-44bc-904a-dfa0cd494a2d"
}

variable "resource_group_name" {
  type    = string
  default = "rgsnap"
}

variable "gallery_name" {
  type    = string
  default = "imagegallery"
}

variable "image_name" {
  type    = string
  default = "Image_terra"
}

variable "new_image_version" {
  type    = string
  default = "0.0.4"  # Nova versão da imagem
}

source "azure-arm" "example" {
  client_id                        = var.client_id
  client_secret                    = var.client_secret
  tenant_id                        = var.tenant_id
  subscription_id                  = var.subscription_id

  resource_group_name              = var.resource_group_name
  managed_image_resource_group_name = var.resource_group_name
  managed_image_name                = "${var.image_name}_${var.new_image_version}"

  os_type = "Linux"

  azure_tags = {
    dept = "Engineering"
    task = "Image deployment"
  }

  location = "East US"
  vm_size  = "Standard_DS2_v2"
}

build {
  sources = ["source.azure-arm.example"]

  provisioner "shell" {
    inline = [
      "apt-get update",
      "apt-get upgrade -y",
      "apt-get -y install nginx",
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
  }


post-processor "azure-arm" {
  action                          = "SharedImage"
  subscription_id                 = var.subscription_id
  tenant_id                       = var.tenant_id
  client_id                       = var.client_id
  client_secret                   = var.client_secret
  location                        = "East US"
  resource_group_name             = var.resource_group_name
  gallery_name                    = var.gallery_name
  image_name                      = var.image_name
  image_version                   = var.new_image_version
  managed_image_id                = "${var.resource_group_name}/providers/Microsoft.Compute/images/${var.image_name}_${var.new_image_version}"
}

}