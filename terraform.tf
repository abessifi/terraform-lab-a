resource "alicloud_vpc" "vpc" {
  vpc_name   = "lab-a-vpc"
  cidr_block = "192.168.0.0/16"
}

resource "alicloud_vswitch" "vsw-1" {
  vpc_id            = alicloud_vpc.vpc.id
  cidr_block        = "192.168.1.0/28"
  zone_id           = "eu-central-1a"
}

resource "alicloud_vswitch" "vsw-2" {
  vpc_id            = alicloud_vpc.vpc.id
  cidr_block        = "192.168.2.0/28"
  zone_id           = "eu-central-1b"
}

resource "alicloud_security_group" "default" {
  name = "default"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_ecs_key_pair" "publickey" {
  key_pair_name = "alibabacloud_public_key"
  public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQChe+txjHlJbens+HIjokvgR8OmiNfqX+shd8OQopv7RDbrNick6uVuZyzYJUQvv4zcSjxx6lzIay3wKdrV1cm+pBlirrgk1yz1fieob0HNFUBM13fN9diejzHtBcg711EA52unnTGiown69F1g3gUvGgGxa2Z2KlEYHa7tyNEWHV9gzWNBdUNtNYBcV33mkMRXly4zKIH9AXyjKjK3uN6d88NkaUubuhICDlGVrqmyzhIBvgNqfnSDUjzyUuHM0/QQ9ntgMglEgRP1xdoj9AE5rmJgLMtVzgZ/are6UHZ3n+WktNixVZfOrnHGX7eF4QuEXjiH5EBZOPe25qVDfByAUU48i9JCwqsRbdC2DOxu3hO8rYVUjoyTeSaEouIvC7Oj0dIxY0gCzYE/LJ6ES115uNpCmUIkVqriaCDOg2HM9NdJBXjQ4NuviFnnftMRIHrT6DzdWMHD/04NRpLK1kfLhjTZcBlA4hrPJycqTHnSEeky1iFD6hR1qq1+pDA1LbmeFHyPrkIoIeHTzgWJnX4at47iVEbnSn2DkdQxTUHyjkdHA6EpReYckcLdtvO32vwkNHklVLt1btZHZDAHbIvS4khD/X3guQC3m8m2qrX3a1KJHwbvbPm1zqqQ/g8H8+Au0BDhBaH3JjKcKm3uXfJTX7x5pryey6kNLEC56XlqcQ=="
}

resource "alicloud_instance" "ansible-provisionner" {
  availability_zone = "eu-central-1a"
  security_groups = alicloud_security_group.default. *.id
  instance_type        = "ecs.n4.small" # 1 vCPU / 2 GiB RAM
  system_disk_category = "cloud_efficiency"
  image_id             = "centos_8_5_x64_20G_alibase_20211228.vhd"
  instance_name        = "ansible-provisionner"
  vswitch_id = alicloud_vswitch.vsw-1.id
  internet_charge_type = "PayByTraffic"
  key_name = alicloud_ecs_key_pair.publickey.key_pair_name
}
resource "alicloud_instance" "instance-1" {
  availability_zone = "eu-central-1a"
  security_groups = alicloud_security_group.default. *.id
  instance_type        = "ecs.n4.small" # 1 vCPU / 2 GiB RAM
  system_disk_category = "cloud_efficiency"
  image_id             = "centos_8_5_x64_20G_alibase_20211228.vhd"
  instance_name        = "centos-vm-1"
  vswitch_id = alicloud_vswitch.vsw-1.id
  internet_charge_type = "PayByTraffic"
  #instance_charge_type = ""
  key_name = alicloud_ecs_key_pair.publickey.key_pair_name
}
resource "alicloud_instance" "instance-2" {
  availability_zone = "eu-central-1b"
  security_groups = alicloud_security_group.default. *.id
  instance_type        = "ecs.n4.small" # 1 vCPU / 2 GiB RAM
  system_disk_category = "cloud_efficiency"
  image_id             = "centos_8_5_x64_20G_alibase_20211228.vhd"
  instance_name        = "centos-vm-2"
  vswitch_id = alicloud_vswitch.vsw-2.id
  internet_charge_type = "PayByTraffic"
  #instance_charge_type = ""
  key_name = alicloud_ecs_key_pair.publickey.key_pair_name
}
resource "alicloud_eip_address" "ansible-provisionner-vm-public-ip" {
  address_name         = "ansible-provisionner-vm-public-ip"
  isp                  = "BGP"
  internet_charge_type = "PayByTraffic"
  payment_type         = "PayAsYouGo"
}

resource "alicloud_eip_association" "ansible-provisionner-vm-public-ip-binding" {
  allocation_id = alicloud_eip_address.ansible-provisionner-vm-public-ip.id
  instance_id   = alicloud_instance.ansible-provisionner.id
}

