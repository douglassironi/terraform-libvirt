# terraform-libvirt
Repositorie with example to create a list of machine with terraform file and configure using init-cloud suporte.


#### Requirements
   - [install-cli](https://learn.hashicorp.com/tutorials/terraform/install-cli)
   - Install KVM Provider 
   - Libvirt Enviroment Installed.
### Get Start
- ##### Clone and init project.

```sh 
git clone https://github.com/douglassironi/terraform-libvirt.git
cd terraform-libvirt
terraform init 
```
- ##### Edit Destination libvirt
```
provider "libvirt" {
  uri   = "qemu+ssh://root@{{YOUR-SERVER}}/system?socket=/var/run/libvirt/libvirt-sock"
}
```
- ##### Define how many machines do you need
```
variable "vm_machines" {
    description = "Create lists of machines."
    type = list(string)
    default = ["vm-cnts-7-db","vm-cnts-7-app","vm-cnts-7-impres"]
}
```
<b>  PS: In my case, I created a template with Centos and install a cloud-int package to adjust each machine.
</b>

#### Run terraform
```
terraform apply
```

After this, the machines will be created and add at local network using bridge.
