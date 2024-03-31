# note:- please import access & secret-access key before executing this terraform script like this below.
#export AWS_ACCESS_KEY_ID=bdhbjbbsbjd
#export AWS_SECRET_ACCESS_KEY=bdhbdshjbhj
# how to run this terraform script ?
# clone this file in your directory and run these below commands
# terraform init (this cmd initialize a Terraform working directory)
# terraform apply (this cmd executes the actions proposed in a terraform file)

provider "aws" {
  region = "eu-west-3"   # region in which our ec2-instance is deploying
}

# Creating elastic-ip
resource "aws_eip" "elastic-ip" {
 instance = aws_instance.mongo.id
 vpc      = true

 tags = {
   Name = "mongo-elastic-ip"
 }
}

# creating additional disk-volume
resource "aws_ebs_volume" "volume" {
 availability_zone = data.aws_subnet.default.availability_zone
 size              = 50
 type              = "gp2"
 tags = {
   Name = "mongo-volume"
 }
}

# attaching volume to ec2-instance
resource "aws_volume_attachment" "ebs-att" {
 device_name = "/dev/sdh"
 volume_id   = aws_ebs_volume.volume.id
 instance_id = aws_instance.mongo.id
}

# creating mongo ec2-instance
resource "aws_instance" "mongo" {
  ami           = "ami-008bcc0a51a849165"
  instance_type = "r5.xlarge" #"t2.nano"
  key_name      = "aws_trackier_terraform"
  availability_zone = data.aws_subnet.default.availability_zone
  tags = {
    Name = "mongodb-1-server-2"
  }
  root_block_device {
  volume_size = 20
  volume_type = "gp2"
  }
}

# create null resource for installing mongo on ec2
resource "null_resource" "installing-mongo" {

   connection {
    type        = "ssh"
    host        = aws_eip.elastic-ip.public_ip 
    user        = "ubuntu"
    private_key = file("/etc/terraform/aws_trackier_terraform.cer") 
    timeout     = "4m"
    }

  provisioner "file" {
   source      = "/home/wasimali/terraform-script/aws/mongodb/mongo.sh"
   destination = "/home/ubuntu/mongo.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/mongo.sh",
      "sudo bash /home/ubuntu/mongo.sh"
    ]

  }
  depends_on = [aws_instance.mongo] #[aws_volume_attachment.ebs-att]

}


# subet in which our ec2 instance will create
data "aws_subnet" "default" {
  filter {
    name   = "availability-zone"
    values = ["eu-west-3c"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# vpv will be default
data "aws_vpc" "default" {
  default = true
}
