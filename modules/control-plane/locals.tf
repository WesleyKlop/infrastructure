locals {
  public_ipv4_address  = module.control_plane.public_ipv4_address
  private_ipv4_address = module.control_plane.private_ipv4_address

  name = module.control_plane.name
}
