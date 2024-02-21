packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

variable "box_basename" {
  type    = string
  default = "debian-12.4.0-desktop"
}

variable "build_directory" {
  type    = string
  default = "/bisos/var/vagrant/builds"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "65536"
}

variable "git_revision" {
  type    = string
  default = "__unknown_git_revision__"
}

variable "guest_additions_url" {
  type    = string
  default = ""
}

variable "headless" {
  type    = string
  default = ""
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "iso_checksum" {
  type    = string
  default = "64d727dd5785ae5fcfd3ae8ffbede5f40cca96f1580aaa2820e8b99dae989d94"
}

variable "iso_name" {
  type    = string
  default = "debian-12.4.0-amd64-netinst.iso"
}

variable "memory" {
  type    = string
  default = "1024"
}

variable "mirror" {
  type    = string
  default = "https://cdimage.debian.org/cdimage/archive/12.4.0"
}

variable "mirror_directory" {
  type    = string
  default = "amd64/iso-cd"
}

variable "name" {
  type    = string
  default = "debian-12.4.0"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "preseed_path" {
  type    = string
  default = "debian-9/preseed.cfg"
}

variable "template" {
  type    = string
  default = "debian-12.4.0-amd64"
}

variable "version" {
  type    = string
  default = "TIMESTAMP"
}
# The "legacy_isotime" function has been provided for backwards compatability, but we recommend switching to the timestamp and formatdate functions.

locals {
  build_timestamp = "${legacy_isotime("20060102150405")}"
  http_directory  = "${path.root}/http"
}

source "qemu" "autogenerated_2" {
  accelerator      = "kvm"
  boot_command     = ["<esc><wait>", "install <wait>", " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.preseed_path} <wait>", "debian-installer=en_US.UTF-8 <wait>", "auto <wait>", "locale=en_US.UTF-8 <wait>", "kbd-chooser/method=us <wait>", "keyboard-configuration/xkb-keymap=us <wait>", "netcfg/get_hostname={{ .Name }} <wait>", "netcfg/get_domain=vagrantup.com <wait>", "fb=false <wait>", "debconf/frontend=noninteractive <wait>", "console-setup/ask_detect=false <wait>", "console-keymaps-at/keymap=us <wait>", "grub-installer/bootdev=/dev/vda <wait>", "<enter><wait>"]
  boot_wait        = "5s"
  cpus             = "${var.cpus}"
  disk_size        = "${var.disk_size}"
  headless         = "${var.headless}"
  http_directory   = "${local.http_directory}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  memory           = "${var.memory}"
  output_directory = "${var.build_directory}/packer-${var.template}-qemu"
  shutdown_command = "echo 'vagrant' | sudo -S /sbin/shutdown -hP now"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "10000s"
  ssh_username     = "vagrant"
  vm_name          = "${var.template}"
}

build {
  sources = ["source.qemu.autogenerated_2"]

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/vagrant", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/update.sh", "${path.root}/../_common/motd.sh", "${path.root}/../_common/sshd.sh", "${path.root}/scripts/networking.sh", "${path.root}/scripts/sudoers.sh", "${path.root}/../_common/vagrant.sh", "${path.root}/scripts/systemd.sh", "${path.root}/scripts/augment.sh", "${path.root}/scripts/cleanup.sh", "${path.root}/../_common/minimize.sh"]
  }

  post-processor "vagrant" {
    output = "${var.build_directory}/${var.box_basename}.{{ .Provider }}.box"
  }
}
