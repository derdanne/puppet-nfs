# == Class: nfs::server
#
# This class exists to
#  1. order the loading of classes
#  2. including all needed classes for nfs as a server
#
# === Links
#
# * {Puppet Docs: Using Parameterized Classes}[http://j.mp/nVpyWY]
#
#
# === Authors
#
# * Daniel Klockenkaemper <mailto:dk@marketing-factory.de>
#

class nfs::server (
  $ensure                       = $nfs::ensure,
  $nfs_v4                       = $nfs::nfs_v4,
  $nfs_v4_export_root           = $nfs::nfs_v4_export_root,
  $nfs_v4_export_root_clients   = $nfs::nfs_v4_export_root_clients,
  $nfs_v4_idmap_domain          = $nfs::nfs_v4_idmap_domain,
  $nfs_v4_root_export_ensure    = $nfs::nfs_v4_root_export_ensure,
  $nfs_v4_root_export_mount     = $nfs::nfs_v4_root_export_mount,
  $nfs_v4_root_export_remounts  = $nfs::nfs_v4_root_export_remounts,
  $nfs_v4_root_export_atboot    = $nfs::nfs_v4_root_export_atboot ,
  $nfs_v4_root_export_options   = $nfs::nfs_v4_root_export_options,
  $nfs_v4_root_export_bindmount = $nfs::nfs_v4_root_export_bindmount,
  $nfs_v4_root_export_tag       = $nfs::nfs_v4_root_export_tag,
) {
  anchor { 'nfs::server::begin': }
  anchor { 'nfs::server::end': }

  # package(s)
  class { 'nfs::server::package': }

  # configuration
  class { 'nfs::server::config': }

  # service(s)
  class { 'nfs::server::service': }

  if $ensure == 'present' {
    # we need the software before configuring it
    Anchor['nfs::server::begin']
    -> Class['nfs::server::package']
    -> Class['nfs::server::config']
    # we need the software and a working configuration before running a service
    Class['nfs::server::package'] -> Class['nfs::server::service']
    Class['nfs::server::config']  -> Class['nfs::server::service']
    Class['nfs::server::service'] -> Anchor['nfs::server::end']
  } else {
    # make sure all services are getting stopped before software removal
    Anchor['nfs::server::begin']
    -> Class['nfs::server::service']
    -> Class['nfs::server::package']
    -> Anchor['nfs::server::end']
  }
}
