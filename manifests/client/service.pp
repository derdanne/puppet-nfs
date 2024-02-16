# == Class: nfs::client::service
#
# This Function exists to
#  1. manage the needed services for nfs clients
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

class nfs::client::service {
  if $nfs::client::nfs_v4 {
    $create_services = $nfs::effective_nfsv4_client_services

    if $nfs::server_enabled {
      $subscription = [Concat[$nfs::exports_file], Augeas[$nfs::idmapd_file]]
    } else {
      if ($nfs::client_rpcbind_config != undef)
      and ($nfs::client_rpcbind_optname != undef)
      and ($nfs::client_rpcbind_opts != undef) {
        $subscription = [
          Augeas[$nfs::idmapd_file],
          Augeas[$nfs::defaults_file],
          Augeas[$nfs::client_rpcbind_config]
        ]
      } else {
        $subscription = [
          Augeas[$nfs::idmapd_file],
          Augeas[$nfs::defaults_file]
        ]
      }
    }
  } else {
    $create_services = $nfs::effective_client_services

    if $nfs::server_enabled {
      $subscription = [Concat[$nfs::exports_file]]
    } else {
      $subscription = undef
    }
  }

  $service_defaults = {
    ensure     => running,
    enable     => $nfs::client_services_enable,
    hasrestart => $nfs::client_services_hasrestart,
    hasstatus  => $nfs::client_services_hasstatus,
    subscribe  => $subscription,
  }

  if $create_services != undef and $nfs::manage_client_service {
    create_resources('service', $create_services, $service_defaults )
  }

  # Redhat ~7.5 workaround (See issue https://github.com/derdanne/puppet-nfs/issues/82)

  if $facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == '7' and versioncmp($facts['os']['release']['full'], '7.5') < 0 {
    transition { 'stop-rpcbind.service-service':
      resource   => Service['rpcbind.service'],
      prior_to   => Service['rpcbind.socket'],
      attributes => {
        ensure => stopped,
      },
    }
  }
}
