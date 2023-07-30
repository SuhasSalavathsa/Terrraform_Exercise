variable "vpc_id" {
  type = string
}

variable "availability_zone" {
  type = list(string)
}

variable "cidr_block" {
  type = string
}
variable "key_name" {
  type = string
}

variable "webserver_sg_rules" {
  type = object({
    ingress_rules = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
    egress_rules = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  })
  default = {
    ingress_rules = [
      {
        description = "SSH from management workstation"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["134.238.14.57/32"] # <- replace with your own workstation IP
      },
      {
        description = "80 from public subnets"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    egress_rules = [
      {
        description = "All outbound internet traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}