# == Class: nfs::server::config
#
# This class exists to
#  1. configure nfs as a server
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

class nfs::server::config {
  concat { $nfs::exports_file:
    ensure  => present,
  }

  concat::fragment { 'nfs_exports_header':
    target  => $nfs::exports_file,
    content => "# This file is configured through the nfs::server puppet module\n",
    order   => 1;
  }

  if $nfs::nfs_v4 {
    if $nfs::nfsv4_bindmount_enable {
      concat::fragment { 'nfs_exports_root':
        target  => $nfs::exports_file,
        content => "${nfs::server::nfs_v4_export_root} ${nfs::server::nfs_v4_export_root_clients}\n",
        order   => 2,
      }
    }

    if ! defined(File[$nfs::server::nfs_v4_export_root]) {
      file { $nfs::server::nfs_v4_export_root:
        ensure => directory,
      }
    }

    if $nfs::nfs_v4_idmap_localrealms != '' {
      if $nfs::nfs_v4_idmap_localrealms =~ String {
        $_localrealms = $nfs::nfs_v4_idmap_localrealms
      } else {
        $_localrealms = join($nfs::nfs_v4_idmap_localrealms, ',')
      }
      $_aug_localrealm = "set General/Local-Realms ${_localrealms}"
    } else {
      $_aug_localrealm = undef
    }

    if $nfs::nfs_v4_idmap_cache != 0 {
      $_cache = "set General/Cache-Expiration ${nfs::nfs_v4_idmap_cache}"
    } else {
      $_cache = undef
    }

    if $nfs::manage_nfs_v4_idmap_nobody_mapping {
      $_user = "set Mapping/Nobody-User ${nfs::nfs_v4_idmap_nobody_user}"
      $_group = "set Mapping/Nobody-Group ${nfs::nfs_v4_idmap_nobody_group}"
    } else {
      $_user = undef
      $_group = undef
    }

    $changes = ["set General/Domain ${nfs::server::nfs_v4_idmap_domain}", $_aug_localrealm, $_cache, $_user, $_group]
    $filtered_changes = filter($changes) |$val| { $val =~ NotUndef }

    augeas { $nfs::idmapd_file:
      context => "/files/${nfs::idmapd_file}",
      lens    => 'Puppet.lns',
      incl    => $nfs::idmapd_file,
      changes => $filtered_changes,
    }

    if $nfs::storeconfigs_enabled {
      @@nfs::client::mount { $nfs::nfs_v4_mount_root:
        ensure        => $nfs::server::nfs_v4_root_export_ensure,
        server        => $facts['clientcert'],
        remounts      => $nfs::server::nfs_v4_root_export_remounts,
        atboot        => $nfs::server::nfs_v4_root_export_atboot,
        options_nfsv4 => $nfs::server::nfs_v4_root_export_options,
        bindmount     => $nfs::server::nfs_v4_root_export_bindmount,
        nfstag        => $nfs::server::nfs_v4_root_export_tag,
      }
    }
  }
}
