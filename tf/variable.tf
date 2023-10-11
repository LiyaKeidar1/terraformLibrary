variable "region" {
  description = "Azure region: West Europe"
  type        = string
  default     = "West Europe"
}

variable "rg" {
    type= string
    default = "rg-library-dev"
}

variable "vnet" {
  type= string
  default= "vnet-library-dev"
}

variable dbfile{
    type = string
    default = "scripts/PostgreSQL_script.sh"
}

variable webfile{
    type = string
    default = "scripts/Flask_script1.sh"
}


variable "password-db" {
   description = "Password for the database user" 
   type = string 
   }


