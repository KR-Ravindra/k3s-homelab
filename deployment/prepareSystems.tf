resource "null_resource" "Prepare_Systems" {
  count = length(var.hosts)

  depends_on = [null_resource.Check_Systems]

  triggers = {
    host = var.hosts[count.index]
  }


  provisioner "remote-exec" {
    inline = [
      "if [ -f /etc/redhat-release ]; then",
      "  ${var.is_root ? "" : "sudo"} systemctl stop firewalld",
      "  ${var.is_root ? "" : "sudo"} systemctl disable firewalld",
      "elif [ -f /etc/debian_version ]; then",
      "  ${var.is_root ? "" : "sudo"} systemctl disable ufw",
      "  ${var.is_root ? "" : "sudo"} ufw disable",
      "fi",
    ]

  }
  provisioner "remote-exec" {
    inline = [
      "${var.is_root ? "" : "sudo"} useradd -m devops",
      "echo 'devops:devops' | ${var.is_root ? "" : "sudo"} chpasswd",
      "${var.is_root ? "" : "sudo"} usermod -aG sudo devops",
      "${var.is_root ? "" : "sudo"} useradd -m support",
      "echo 'support:support' | ${var.is_root ? "" : "sudo"} chpasswd",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "if grep -q 'ID=ubuntu' /etc/os-release; then ${var.is_root ? "" : "sudo"} apt-get update && ${var.is_root ? "" : "sudo"} apt-get install -y ${join(" ", var.packages)}; elif grep -q 'ID=rhel' /etc/os-release; then sudo yum install -y ${join(" ", var.packages)}; elif grep -q 'ID=rhel' /etc/os-release; then ${var.is_root ? "" : "sudo"} yum install -y ${join(" ", var.packages)}; elif grep -q 'ID=rhel' /etc/os-release; then sudo yum install -y ${join(" ", var.packages)}; fi",

    ]
  }

  connection {
      host        = var.hosts[count.index]
      user        = lookup(var.usernames, var.hosts[count.index], var.default_username)
      password    = lookup(var.passwords, var.hosts[count.index], var.default_password)
      private_key = file(var.private_key)
      timeout     = "20s"
    }
}
