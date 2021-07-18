provider "libvirt" {
  uri   = "qemu+ssh://root@sr.sironi.local/system?socket=/var/run/libvirt/libvirt-sock"
}

variable "network" { default = "default" }
variable "bridge" { default = "br1" }

variable "vm_machines" {
    description = "Create lists of machines."
    type = list(string)
    default = ["vm-cnts-7-db","vm-cnts-7-app","vm-cnts-7-impres"]
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    HOSTNAME = var.vm_machines[count.index]
  }

  count = length(var.vm_machines)
}  

# Create one init for each machine.
resource "libvirt_cloudinit_disk" "commoninit" {  
  name = "commoninit${count.index}.iso"
  user_data      = data.template_file.user_data[count.index].rendered
  count = length(var.vm_machines)
}      

resource "libvirt_volume" "storage" {
  pool= "storage"  
  name = "${var.vm_machines[count.index]}.qcow2"
  count = length(var.vm_machines)
  base_volume_name = "cts7.template.qcow2"
}


# Machine Creations
resource "libvirt_domain" "vm" {
  count = length(var.vm_machines)
  name = var.vm_machines[count.index]
  memory = "1024"
  vcpu = 1
  qemu_agent = true

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    bridge = "br1"
    hostname = var.vm_machines[count.index]
    wait_for_lease = true
  }

    disk {
    volume_id = libvirt_volume.storage[count.index].id
    }

 
}

# generate inventory file for Ansible
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    { 
      vms_adresss = libvirt_domain.vm.*.network_interface.0.addresses.0
    }
  )
  filename = "hosts.cfg"
}
