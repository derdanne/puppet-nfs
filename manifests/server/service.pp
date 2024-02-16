# == Class: nfs::server::service
#
# This Function exists to
#  1. manage the needed services for nfs server
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

class nfs::server::service {
  if $nfs::nfs_v4 == true {
    if $nfs::server_nfsv4_servicehelper != undef and $nfs::manage_server_servicehelper {
      $server_service_require = Service[$nfs::server_nfsv4_servicehelper]
      $nfs::server_nfsv4_servicehelper.each |$service_name| {
        service { $service_name:
          ensure     => $nfs::server_service_ensure,
          enable     => $nfs::server_service_enable,
          hasrestart => $nfs::server_service_hasrestart,
          hasstatus  => $nfs::server_service_hasstatus,
          subscribe  => [Concat[$nfs::exports_file], Augeas[$nfs::idmapd_file]],
        }
      }
    } else {
      $server_service_require = undef
    }

    if $nfs::manage_server_service {
      service { $nfs::server_service_name:
        ensure     => $nfs::server_service_ensure,
        enable     => $nfs::server_service_enable,
        hasrestart => $nfs::server_service_hasrestart,
        hasstatus  => $nfs::server_service_hasstatus,
        restart    => $nfs::server_service_restart_cmd,
        subscribe  => [Concat[$nfs::exports_file], Augeas[$nfs::idmapd_file]],
        require    => $server_service_require,
      }
    }
  } else {
    if $nfs::manage_server_service {
      service { $nfs::server_service_name:
        ensure     => $nfs::server_service_ensure,
        enable     => $nfs::server_service_enable,
        hasrestart => $nfs::server_service_hasrestart,
        hasstatus  => $nfs::server_service_hasstatus,
        restart    => $nfs::server_service_restart_cmd,
        subscribe  => Concat[$nfs::exports_file],
      }
    }
  }
}
