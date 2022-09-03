locals {
  public_ipv4_address  = module.worker.public_ipv4_address
  private_ipv4_address = module.worker.private_ipv4_address

  name = module.worker.name
}
