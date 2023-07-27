#! /bin/bash

yum update -y
yum install -y httpd 
systemctl start httpd
systemctl enable httpd 
echo "<h1>Hello world This is $(hostname -f)</h1>" > /var/www/html/index.html
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent