# EC2 Instance
resource "aws_instance" "ibm_web_server" {
  ami           = "ami-03c983f9003cb9cd1"
  instance_type = "t2.micro"
  key_name = "730"
  subnet_id = aws_subnet.ibm_web_sn.id
  vpc_security_group_ids = aws_security_group.ibm_web_sg.id
  user_data = file("app.sh")

  tags = {
    Name = "HelloWorld"
  }
}