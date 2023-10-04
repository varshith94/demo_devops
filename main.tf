provider "aws" {
    access_key = "AKIAQA6H5JP7TPUZFJ5Z"
    secret_key = "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"
    region = "us-east-1"
  
}

resource "aws_vpc" "prod" {
    cidr_block = "10.20.0.0/16"
    enable_dns_hostnames = true
    tags = {
        "Name" = "prod"
    }
  
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.prod.id
    tags = {
        "Name" = "prod-igw"
    }
  
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.prod.id
    cidr_block = "10.20.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"
    tags = {
        "Name" = "public-1"
    }
  
}

resource "aws_subnet" "public1" {
    vpc_id = aws_vpc.prod.id
    cidr_block = "10.20.2.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1b"
    tags = {
        "Name" = "public-2"
    }
  
}


resource "aws_route_table" "dev-rt" {
    vpc_id = aws_vpc.prod.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        "Name" = "prod-rt"
    }
  
}

resource "aws_route_table_association" "public1" {
    subnet_id = aws_subnet.public1.id
    route_table_id = aws_route_table.dev-rt.id
  
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.dev-rt.id
  
}

resource "aws_security_group" "sg" {
    description = "allow inbound and outbound rules"
    name = "prod security group"
    vpc_id = aws_vpc.prod.id
    tags = {
        "Name" = "prod-sg"
    }
    ingress  {
          to_port = 0
          from_port = 0
          protocol = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "allow all inbound rules "
    }
  egress {
           to_port = 0
          from_port = 0
          protocol = "-1"
          cidr_blocks = ["0.0.0.0/0"]
    }
 
  
}

resource "aws_instance" "webserver" {
    ami = "ami-053b0d53c279acc90"
    key_name = "devopslatest"
    instance_type = "t2.medium"
    vpc_security_group_ids = [aws_security_group.sg.id]
    associate_public_ip_address = true
    subnet_id = aws_subnet.public.id
   tags = {
    "Name" = "kubemaster"
   }
}

resource "aws_instance" "dbserver" {
    ami = "ami-053b0d53c279acc90"
    key_name = "devopslatest"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.sg.id]
    associate_public_ip_address = true
    subnet_id = aws_subnet.public1.id
   tags = {
    "Name" = "worker"
   }
}