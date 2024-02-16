# == Class: nfs::server::package
#
# This Function exists to
#  1. install needed packages for nfs server
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

class nfs::server::package {
  if $nfs::manage_packages {
    if $nfs::manage_server_service {
      $notify_services = Service[$nfs::server_service_name]
    } else {
      $notify_services = undef
    }

    package { $nfs::server_packages:
      ensure => $nfs::server_package_ensure,
      notify => $notify_services,
    }
  }
}
