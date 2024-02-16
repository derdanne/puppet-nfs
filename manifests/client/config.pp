# == Class: nfs::client::config
#
# This Function exists to
#  1. configure nfs as a client
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

class nfs::client::config {
  if $nfs::client::nfs_v4 {
    if $nfs::defaults_file != undef {
      if $nfs::client_gssd_options != '' {
        $_gssd1_aug = ["set ${nfs::client_gssdopt_name} \"'${nfs::client_gssd_options}'\""]
      } else {
        $_gssd1_aug = undef
      }

      if $nfs::client_need_gssd {
        $_gssd2_aug = ['set NEED_GSSD yes']
      } else {
        $_gssd2_aug = undef
      }

      augeas { $nfs::defaults_file:
        context => "/files/${nfs::defaults_file}",
        changes => delete_undef_values(concat($nfs::client_idmapd_setting, $_gssd1_aug, $_gssd2_aug)),
      }
    }

    if ($nfs::client_rpcbind_config != undef) and ($nfs::client_rpcbind_optname != undef) and ($nfs::client_rpcbind_opts != undef) {
      augeas { $nfs::client_rpcbind_config:
        incl    => $nfs::client_rpcbind_config,
        lens    => 'Shellvars.lns',
        context => "/files/${nfs::client_rpcbind_config}",
        changes => "set ${nfs::client_rpcbind_optname} \"'${nfs::client_rpcbind_opts}'\"",
      }
    }

    if $nfs::client_d9_gssdopt_workaround and $nfs::client_gssd_service {
      file_line { 'rpc-gssd.service':
        path    => '/lib/systemd/system/rpc-gssd.service',
        match   => 'EnvironmentFile',
        line    => 'EnvironmentFile=-/etc/default/nfs-common',
        require => Package['nfs-common'],
      } ~> exec { 'systemctl daemon-reload':
        refreshonly => true,
        path        => '/bin',
      } ~> Service['rpc-gssd']
    }

    if ( $nfs::server_enabled == false ) or ( $nfs::server_enabled == true and $nfs::nfs_v4 == false ) {
      if $nfs::idmapd_file != undef {
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

        $changes = ["set General/Domain ${nfs::nfs_v4_idmap_domain}", $_aug_localrealm, $_cache, $_user, $_group]
        $filtered_changes = filter($changes) |$val| { $val =~ NotUndef }

        augeas { $nfs::idmapd_file:
          context => "/files/${nfs::idmapd_file}",
          lens    => 'Puppet.lns',
          incl    => $nfs::idmapd_file,
          changes => $filtered_changes,
        }
      }
    }
  }
}
