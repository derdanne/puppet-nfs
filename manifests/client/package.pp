# == Class: nfs::client::package
#
# This Function exists to
#  1. install needed packages for nfs clients
#
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

class nfs::client::package {
  if $nfs::manage_packages {
    if $nfs::client::nfs_v4 {
      if $nfs::effective_nfsv4_client_services != undef and $nfs::manage_client_service {
        $notify_services = Service[keys($nfs::effective_nfsv4_client_services)]
      } else {
        $notify_services = undef
      }
    } else {
      if $nfs::effective_client_services != undef and $nfs::manage_client_service {
        $notify_services = Service[keys($nfs::effective_client_services)]
      } else {
        $notify_services = undef
      }
    }

    if $nfs::effective_client_packages != undef {
      package { $nfs::effective_client_packages:
        ensure => $nfs::client_package_ensure,
        notify => $notify_services,
      }
    }
  }
}
