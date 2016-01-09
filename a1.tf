#Example to show build a Infrastrucure stack using code
#Infrastrucure consists of Network, Compute and Storage

#Configure the OpenStack Provider
provider "openstack" {
    user_name  = "demo"
    tenant_name = "ademo"
    auth_url  = "http://openstack.ut1.adobe.net:5000/v2.0"
}

#Network is composed of Virtual links, subnets, and routers
#Create a network
resource "openstack_networking_network_v2" "network_1" {
  name = "network_1"
  admin_state_up = "true"
}

#Create a subnet
resource "openstack_networking_subnet_v2" "subnet_1" {
  name = "subnet_1"
  network_id = "${openstack_networking_network_v2.network_1.id}"
  cidr = "192.168.199.0/24"
  ip_version = 4
}

#Create a router
resource "openstack_networking_router_v2" "router_1" {
  region = ""
  name = "my_router"
  external_gateway = "1dd0b6d2-9aa8-405c-bfd7-d37a33a867f5"
}

#Create the interface for the router
resource "openstack_networking_router_interface_v2" "router_interface_1" {
  region = ""
  router_id = "${openstack_networking_router_v2.router_1.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
 }
 

#Request a floating IP
 resource "openstack_compute_floatingip_v2" "floatip_1" {
  region = ""
  pool = "public"
}

#Create a web server
resource "openstack_compute_instance_v2" "test-server" {
    name = "tf-test"
	image_id = "e5ab64f4-f870-497c-9160-a50a870679ba"
	flavor_name = "m1.medium"
	network {
		name = "${openstack_networking_network_v2.network_1.name}"
			}
	floating_ip = "${openstack_compute_floatingip_v2.floatip_1.address}"
	security_groups = [
                    "default",
                    "${openstack_compute_secgroup_v2.secgroup_1.name}"
                ]
}

resource "openstack_compute_secgroup_v2" "secgroup_1" {
  name = "my_secgroup"
  description = "my security group"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = -1
    to_port = -1
    ip_protocol = "icmp"
    cidr = "0.0.0.0/0"
  }
}



