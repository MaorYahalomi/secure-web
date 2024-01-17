# webapp-security-pipeline

## Description ##
This GitHub repository contains two web application servers (one with HTTP access, and one with HTTPS)<br>
All the required resources for these web apps were created using Terraform.
The main branch contains branch protection which prevents pushing any changes in the code if the workflow check fails.
To assess the security of Terraform files, a Static Application Security Testing (SAST) tool named tfsec is utilized.

https://github.com/aquasecurity/tfsec


| Terraform Version| Provider version |
|------|---------|
|v1.3.8 | registry.terraform.io/hashicorp/aws v5.32.1 |

## GitHub Workflows ##
There is one main workflow that is configured to run each time there is a change in the code and trying to push it to the main branch.


## Terraform Resources

| Name | Type | Usage |
|------|------|-------|
| [aws_default_vpc.default_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource | Default VPC |
| [aws_iam_instance_profile.ec2-profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource | EC2-Instance-Profile |
| [aws_iam_policy_attachment.s3-policy-attached](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource | EC2-Instance-Profile-Attachment |
| [aws_iam_role.web_server_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource | EC2-Instance-Role |
| [aws_instance.server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource | EC2-Instance-web |
| [aws_instance.server_tls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource | EC2-Instance-web-tls |
| [aws_security_group.instance_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |  Security-Group |
| [aws_ami.amazon-linux-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source | ami-0c0b74d29acd0cd97 |
| [aws_iam_policy.s3_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source | S3-Policy |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_public_IP"></a> [instance\_public\_IP](#output\_instance\_public\_IP) | Public IP address of the instance |
| <a name="output_instance_public_dns"></a> [instance\_public\_dns](#output\_instance\_public\_dns) | Public DNS of the instance |
| <a name="output_instance_public_tls_IP2"></a> [instance\_public\_tls\_IP2](#output\_instance\_public\_tls\_IP2) | Public IP address of the instance |
| <a name="output_instance_public_tls_dns2"></a> [instance\_public\_tls\_dns2](#output\_instance\_public\_tls\_dns2) | Public DNS of the instance |
