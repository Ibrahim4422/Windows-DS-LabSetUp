variable "location" { 
    type = string  
    default = "polandcentral" 
}

variable "prefix"   { 
    type = string  
    default = "adlab" 
}

variable "admin_username" { 
    type = string  
    default = "azureadmin" 
}

variable "admin_password" { 
    type = string  
    sensitive = true 
}

variable "dsrm_password"  { 
    type = string  
    sensitive = true 
}

variable "vm_size" { 
    type = string  
    default = "Standard_B2ms" 
}

variable "address_space" { 
    type = list(string) 
    default = ["192.168.0.0/16"] 
}
variable "lab_subnet_prefix" { 
    type = string 
    default = "192.168.2.0/24" 
}

variable "bastion_subnet_prefix" { 
    type = string 
    default = "192.168.3.0/27" 
}

variable "use_bastion" { 
    type = bool 
    default = true 
}