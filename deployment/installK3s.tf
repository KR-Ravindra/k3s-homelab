resource "null_resource" "Install_K3s" {
  count = length(var.hosts)

  triggers = {
    host = var.hosts[count.index]
  }

  depends_on = [null_resource.Prepare_Systems]

  provisioner "remote-exec" {
    inline = [
      "echo 'Installing K3S now for ${count.index < var.num_masters ? "master" : ""} ' ${self.triggers.host}",
      count.index < var.num_masters 
      ? "echo '${var.devops_user_password}' | sudo  bash -c 'curl -sfL https://get.k3s.io | sh -s - server --cluster-init --tls-san ${self.triggers.host} > /dev/stdout'"
      : "echo 'Workers will go next'",
    ]

    connection {
      host        = var.hosts[count.index]
      user        = lookup(var.usernames, var.hosts[count.index], var.default_username)
      password    = lookup(var.passwords, var.hosts[count.index], var.default_password)
      private_key = file(var.private_key)
      timeout     = "20s"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Installing K3S now for ${count.index < var.num_masters ? "" : "worker"} ' ${self.triggers.host}",
      count.index >= var.num_masters 
      ? "echo 'Managers are done'"
      : "echo '${var.devops_user_password}' | sudo  bash -c 'K3S_URL=https://${var.hosts[0]}:6443 K3S_TOKEN=$(sshpass -p '${var.devops_user_password}' ssh devops@${var.hosts[0]} sudo cat /var/lib/rancher/k3s/server/node-token) curl -sfL https://get.k3s.io | sh -s - agent'echo '${var.devops_user_password}' | sudo  bash -c 'K3S_URL=https://${var.hosts[0]}:6443 K3S_TOKEN=$(sshpass -p '${var.devops_user_password}' ssh devops@${var.hosts[0]} sudo cat /var/lib/rancher/k3s/server/node-token) curl -sfL https://get.k3s.io | sh -s - agent'",
    ]

    connection {
      host        = var.hosts[count.index]
      user        = lookup(var.usernames, var.hosts[count.index], var.default_username)
      password    = lookup(var.passwords, var.hosts[count.index], var.default_password)
      private_key = file(var.private_key)
      timeout     = "20s"
    }
  }
}
