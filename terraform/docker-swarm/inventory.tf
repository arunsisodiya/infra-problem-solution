/*==== Ansible inventory configuration ======*/

resource "local_file" "ansible_inventory" {
  filename = format("%s-inventory", var.environment)

  content = templatefile("${path.module}/ansible/inventory.tmpl", {
    manager-private-dns   = aws_instance.swarm_manager.*.private_dns,
    manager-private-ip    = aws_instance.swarm_manager.*.private_ip,
    manager-private-id    = aws_instance.swarm_manager.*.id
    worker-private-dns    = aws_instance.swarm_worker.*.private_dns,
    worker-private-ip     = aws_instance.swarm_worker.*.private_ip,
    worker-private-id     = aws_instance.swarm_worker.*.id
    managers_ami_username = lookup(local.expanded_ec2_list_manager[0], "ami_username")
    workers_ami_username  = lookup(local.expanded_ec2_list_worker[0], "ami_username")
    bastion_instance_ip   = var.bastion_instance_ip
  })
}