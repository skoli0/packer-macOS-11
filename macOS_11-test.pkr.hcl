packer {
  required_version = ">= 1.6.6"
}

variable "iso_file_checksum" {
  type    = string
  default = "file:install_bits-macos-1121/macOS_1121_installer.shasum"
}

variable "iso_filename" {
  type    = string
  default = "install_bits-macos-1121/macOS_1121_installer.iso"
}

variable "user_password" {
  type    = string
  default = "vagrant"
}

variable "user_username" {
  type    = string
  default = "vagrant"
}

variable "cpu_count" {
  type    = number
  default = "2"
}

variable "ram_gb" {
  type    = number
  default = "4"
}

variable "xcode" {
  type    = string
  default = "install_bits/Xcode_12.4.xip"
}

variable "xcode_cli" {
  type    = string
  default = "install_bits/Command_Line_Tools_for_Xcode_12.4.dmg"
}

variable "board_id" {
  type    = string
  default = "Mac-27AD2F918AE68F61"
}

variable "hw_model" {
  type    = string
  default = "MacPro7,1"
}

variable "serial_number" {
  type    = string
  default = "M00000000001"
}

# Set this to DeveloperSeed if you want prerelease software updates
variable "seeding_program" {
  type    = string
  default = "none"
}

variable "tools_path" {
  type    = string
  default = "/Applications/VMware Fusion.app/Contents/Library/isoimages/darwin.iso"
}

variable "boot_key_interval_iso" {
  type    = string
  default = "150ms"
}

variable "boot_wait_iso" {
  type    = string
  default = "150s"
}

variable "boot_keygroup_interval_iso" {
  type    = string
  default = "4s"
}

# Full build 
build {
  name    = "full"
  sources = ["sources.parallels-iso.macOS_11-test"]

  provisioner "shell" {
    expect_disconnect = true
    pause_before      = "2m" # needed for the first provisioner to let the OS finish booting
    script            = "scripts/os_settings.sh"
  }

  #provisioner "file" {
  #  sources     = [var.xcode, var.xcode_cli, var.tools_path]
  #  destination = "~/"
  #}

  provisioner "shell" {
    expect_disconnect   = true
    start_retry_timeout = "2h"
    environment_vars = [
      "SEEDING_PROGRAM=${var.seeding_program}"
    ]
    scripts = [
      "scripts/parallels_tools.sh",
      "scripts/softwareupdate.sh",
      "scripts/softwareupdate_complete.sh"
    ]
  }

  #post-processor "shell-local" {
  #  inline = ["scripts/vmx_cleanup.sh output/macOS_11/macOS_11.vmx"]
  #}
  post-processor "vagrant" {
    output = "./output/macOS11.box"
    keep_input_artifact = true
    provider_override = "parallels"
  }

}

source "parallels-iso" "macOS_11-test" {
  vm_name              = "macOS_11-test"
  iso_url              = "${var.iso_filename}"
  iso_checksum         = "${var.iso_file_checksum}"
  output_directory     = "output/{{build_name}}"
  ssh_username         = "${var.user_username}"
  ssh_password         = "${var.user_password}"
  shutdown_command     = "printf 'vagrant\n' | sudo -S shutdown -h now"
  guest_os_type        = "macosx"
  disk_size            = "100000"
  http_directory       = "http"
  ssh_timeout          = "12h"
  #usb                  = "true"
  boot_wait              = var.boot_wait_iso
  parallels_tools_flavor = "mac"
  boot_keygroup_interval = var.boot_keygroup_interval_iso
  boot_command = [
    "<enter><wait10s>",
    "<leftSuperOn><f5><leftSuperOff>",
    "<leftCtrlOn><f2><leftCtrlOff>",
    "u<down><down><down><down>",
    "<enter>",
    "w<down><down>",
    "<enter>",
    "curl -o /var/root/vagrant.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/vagrant.pkg<enter>",
    "curl -o /var/root/setupsshlogin.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/setupsshlogin.pkg<enter>",
    "curl -o /var/root/bootstrap.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/bootstrap.sh<enter>",
    "chmod +x /var/root/bootstrap.sh<enter>",
    "/var/root/bootstrap.sh<enter>"
  ]
  cpus   = var.cpu_count
  memory = var.ram_gb * 1024
}

# Base build
build {
  name    = "base"
  sources = ["sources.parallels-iso.macOS_11_base"]

  provisioner "shell" {
    expect_disconnect = true
    pause_before      = "2m" # needed for the first provisioner to let the OS finish booting
    script            = "scripts/os_settings.sh"
  }

  provisioner "file" {
    source      = var.tools_path
    destination = "~/darwin.iso"
  }

  provisioner "shell" {
    expect_disconnect = true
    scripts = [
      "scripts/vmw_tools.sh"
    ]
  }
}

source "parallels-iso" "macOS_11_base" {
  display_name         = "macOS 11 base"
  vm_name              = "macOS_11_base"
  vmdk_name            = "macOS_11_base"
  iso_url              = "${var.iso_filename}"
  iso_checksum         = "${var.iso_file_checksum}"
  output_directory     = "output/{{build_name}}"
  ssh_username         = "${var.user_username}"
  ssh_password         = "${var.user_password}"
  shutdown_command     = "sudo shutdown -h now"
  guest_os_type        = "darwin20-64"
  cdrom_adapter_type   = "sata"
  disk_size            = "100000"
  disk_adapter_type    = "nvme"
  http_directory       = "http"
  #network_adapter_type = "e1000e"
  disk_type_id         = "0"
  ssh_timeout          = "12h"
  usb                  = "true"
  version              = "18"
  boot_wait              = var.boot_wait_iso
  boot_key_interval      = var.boot_key_interval_iso
  boot_keygroup_interval = var.boot_keygroup_interval_iso
  boot_command = [
    "<enter><wait10s>",
    "<leftSuperon><f5><leftSuperoff>",
    "<leftCtrlon><f2><leftCtrloff>",
    "u<down><down><down>",
    "<enter>",
    "<leftSuperon><f5><leftSuperoff><wait10>",
    "<leftCtrlon><f2><leftCtrloff>",
    "w<down><down>",
    "<enter>",
    "curl -o /var/root/vagrant.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/vagrant.pkg<enter>",
    "curl -o /var/root/setupsshlogin.pkg http://{{ .HTTPIP }}:{{ .HTTPPort }}/setupsshlogin.pkg<enter>",
    "curl -o /var/root/bootstrap.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/bootstrap.sh<enter>",
    "chmod +x /var/root/bootstrap.sh<enter>",
    "/var/root/bootstrap.sh<enter>"
  ]
  cpus   = var.cpu_count
  cores  = var.cpu_count
  memory = var.ram_gb * 1024
}
