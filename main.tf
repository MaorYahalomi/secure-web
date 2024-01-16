
resource "aws_iam_role" "web_server_role" {
  name               = "ec2-web-server-role"
  assume_role_policy = "${file("assumerolepolicy.json")}"
}

data "aws_iam_policy" "s3_read_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "s3-policy-attached" {
  name       = "s3-Policy"
  roles      = ["${aws_iam_role.web_server_role.name}"]
  policy_arn = "${data.aws_iam_policy.s3_read_policy.arn}"
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-profile"
  role = aws_iam_role.web_server_role.name
}

### Using The Default VPC resource ####
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "Default VPC"
  }
}

### Create Secuirty Group In Default VPC ####
resource "aws_security_group" "instance_sg" {
  name        = "Allow_traffic"
  description = "Allow SSH and Web inbound traffic"
  vpc_id      = aws_default_vpc.default_vpc.id
  dynamic "ingress" {
    for_each = [80,443,22]
    iterator = port
    content {
      description = "Allow_ssh_and_http"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Allow_ssh_only"
  }
}

## Specify Amazon Linux AMI  ####
data "aws_ami" "amazon-linux-2" {
 most_recent = true

 filter {
   name   = "name"
   values = ["amzn2-ami-kernel*"]
 }
 owners = ["amazon"]
}

# ## Specify Amazon Linux AMI  Latest####
data "aws_ami" "amazon-linux-2-latest" {
 most_recent = true

 filter {
   name   = "name"
   values = ["al2023-ami-2023*"]
 }
 owners = ["amazon"]
}

### Create instance assume the role, and install Cloudwatch Agent ####
resource "aws_instance" "server" {
  ami = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = var.instance_type
  vpc_security_group_ids =  [aws_security_group.instance_sg.id]
  user_data = <<EOF
  #!/bin/bash
  yum update -y
  yum install -y httpd.x86_64
  systemctl start httpd.service
  systemctl enable httpd.service
  echo “Hello World from $(hostname -f)” > /var/www/html/index.html
  EOF

  tags = {
    Name = "web_instance"
  }
}

#### Create instance with tls ####
resource "aws_instance" "server_tls2" {
  ami = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = var.instance_type
  vpc_security_group_ids =  [aws_security_group.instance_sg.id]
  user_data = <<-EOF
    #!/bin/bash
    yum install -y httpd.x86_64
    yum install -y httpd mod_ssl
    systemctl start httpd.service
    systemctl enable httpd.service
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/httpd/conf.d/selfsigned.key -out /etc/httpd/conf.d/selfsigned.crt -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
    echo “Hello World from $(hostname -f)” > /var/www/html/index.html
    chmod o+w /etc/httpd/conf.d/ssl.conf
    chmod o+w /etc/httpd/conf/httpd.conf
    cat <<EOF_CONFIG > /etc/httpd/conf.d/ssl.conf
    <VirtualHost *:443>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        SSLEngine on
        SSLCertificateFile /etc/httpd/conf.d/selfsigned.crt
        SSLCertificateKeyFile /etc/httpd/conf.d/selfsigned.key
        ErrorLog logs/ssl_error_log
        TransferLog logs/ssl_access_log
    </VirtualHost>
EOF_CONFIG
    cat <<PORT >> /etc/httpd/conf/httpd.conf
    Listen 443
PORT
    systemctl restart httpd.service
EOF

  tags = {
    Name = "web_instance_tls2"
  }
}

#### Create instance with tls ####
resource "aws_instance" "server_tls3" {
  ami = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = var.instance_type
  vpc_security_group_ids =  [aws_security_group.instance_sg.id]
  user_data = <<-EOF
    #!/bin/bash
    yum install -y httpd.x86_64
    yum install -y httpd mod_ssl
    systemctl start httpd.service
    systemctl enable httpd.service
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/httpd/conf.d/selfsigned.key -out /etc/httpd/conf.d/selfsigned.crt -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
    echo “Hello World from $(hostname -f)” > /var/www/html/index.html
    chmod o+w /etc/httpd/conf.d/ssl.conf
    chmod o+w /etc/httpd/conf/httpd.conf
    cat <<EOF_CONFIG > /etc/httpd/conf.d/ssl.conf
    <VirtualHost *:443>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        SSLEngine on
        SSLCertificateFile /etc/httpd/conf.d/selfsigned.crt
        SSLCertificateKeyFile /etc/httpd/conf.d/selfsigned.key
        ErrorLog logs/ssl_error_log
        TransferLog logs/ssl_access_log
    </VirtualHost>
EOF_CONFIG
    cat <<PORT >> /etc/httpd/conf/httpd.conf
    Listen 443
PORT
    systemctl restart httpd.service
EOF

  tags = {
    Name = "web_instance_tls3"
  }
}



#### Create instance with tls with policy ####
resource "aws_instance" "server_tls5" {
  ami = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = var.instance_type
  vpc_security_group_ids =  [aws_security_group.instance_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
  user_data = <<-EOF
    #!/bin/bash
    yum install -y httpd.x86_64
    yum install -y httpd mod_ssl
    systemctl start httpd.service
    systemctl enable httpd.service
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/httpd/conf.d/selfsigned.key -out /etc/httpd/conf.d/selfsigned.crt -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
    echo “Hello World from $(hostname -f)” > /var/www/html/index.html
    chmod o+w /etc/httpd/conf.d/ssl.conf
    chmod o+w /etc/httpd/conf/httpd.conf
    cat <<EOF_CONFIG > /etc/httpd/conf.d/ssl.conf
    <VirtualHost *:443>
        ServerAdmin webmaster@localho
        st
        DocumentRoot /var/www/html
        SSLEngine on
        SSLCertificateFile /etc/httpd/conf.d/selfsigned.crt
        SSLCertificateKeyFile /etc/httpd/conf.d/selfsigned.key
        ErrorLog logs/ssl_error_log
        TransferLog logs/ssl_access_log
    </VirtualHost>
EOF_CONFIG
    cat <<PORT >> /etc/httpd/conf/httpd.conf
    Listen 443
PORT
    systemctl restart httpd.service
EOF

  tags = {
    Name = "web_instance_tls5_policy"
  }
}