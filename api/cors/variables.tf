variable "rest_api_id" {
  description = ""
}
variable "resource_id_count" {
  description = "Cannot use length for computed variables, so pass the count as a workaround"
}
variable "resource_ids" {
  description = ""
  type        = list
}
variable "allowed_headers" {
  description = ""
  type        = list
}
variable "allowed_methods" {
  description = ""
  type        = list
}
variable "allowed_origin" {
  description = ""
}
