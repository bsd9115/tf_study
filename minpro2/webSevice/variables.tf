variable "db_username" {
    description = "Aurora DB username"
    type = string
    default = "admin"
    sensitive = true
}