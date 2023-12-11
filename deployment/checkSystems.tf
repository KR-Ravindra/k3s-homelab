resource "null_resource" "Check_Systems" {
  count = length(var.hosts)

  triggers = {
    host = var.hosts[count.index]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'SSH connection successful to ' ${self.triggers.host}",
      "echo 'Hostname: ' $(hostname)",
      "echo 'CPU Info: ' $(lscpu | grep '^CPU(s):' | awk '{print $2}')",
      "echo 'Memory Info: ' $(free -h | grep '^Mem:' | awk '{print $2}')",
      "echo 'Disk Info: ' $(df -h --total | grep '^total' | awk '{print $2}')",
    ]
  }
  provisioner "local-exec" {
    command = <<EOF
      ping -c 1 ${self.triggers.host} > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        echo "${self.triggers.host} is online" >> online_status.txt
      else
        echo "${self.triggers.host} is offline" >> online_status.txt
      fi
    EOF
  }
  connection {
      host        = var.hosts[count.index]
      user        = lookup(var.usernames, var.hosts[count.index], var.default_username)
      password    = lookup(var.passwords, var.hosts[count.index], var.default_password)
      private_key = file(var.private_key)
      timeout     = "20s"
    }
}
