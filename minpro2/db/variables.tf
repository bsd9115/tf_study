variable "availability_zone1" {
    default = "ap-northeast-2a"
}

variable "availability_zone2" {
    default = "ap-northeast-2c"
}

variable "db_username" {
    description = "Aurora DB username"
    type = string
    default = "admin"
    sensitive = true
}
variable "db_password" {
    description = "Aurora DB password"
    type = string
    default = "admin"
    sensitive = true
}
variable "db_name" {
    description = "Aurora DB name"
    type = string
    default = "myDB"
}