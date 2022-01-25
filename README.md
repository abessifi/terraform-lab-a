## Infrastructure Installation

1. Install Terraform CLI and clone this repo

2. Configure Alibaba AccessKey and SecretKey

```
export ALICLOUD_ACCESS_KEY="XXXXXXXXXXXXXXXXX"
export ALICLOUD_SECRET_KEY="XXXXXXXXXXXXXXXXXXXXXXX"
export ALICLOUD_REGION="XXXXX"
```

3. Generate ssh key (to be injected in each created VM by terraform)

```
$ ssh-keygen -t rsa -f ~/.ssh/alibabacloud
```

Get the public key part (~/.ssh/alibabacloud.pub) and update the `terraform.tf`.

4. Run `terraform init` to make sure all required providers are installed

5. Run `terraform plan` then `terraform apply`

## Configuration Management

1. Install `ansible` on the ansible-provisionner VM

```
$ yum install ansible
```

2. Pick the IP addresses of the two provisionned VMs (centos-vm-1, centos-vm-2)

3. Load the ssh key into the ssh-agent (to be used by Ansible)

```
$ eval $(ssh-agent -s)
$ ssh-add ~/.ssh/alibabacloud
$ ssh-add -l
```

4. Update the `ansible/hosts` inventory file with the two IP addresses.

5. Run the following Ansible command to check the SSH connectivity between the provisionner VM and targeted nodes:

```
$ cd ansible/
$ ansible -i hosts -m ping webservers
```

5. Run the following Ansible playbook to install HTTPD/Apache2 server on each targeted VM:

```
$ ansible-playbook -i hosts apache.yml
```

6. Get the Loadbalancer IP and visit the http://<lb-ip>
