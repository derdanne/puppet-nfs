# == Function: nfs::server::export
#
# This Function exists to
#  1. manage all exported resources on a nfs server
#
# === Parameters
#
# [*clients*]
#   String or Array. Sets the allowed clients and options for the export in the exports file.
#   Defaults to <tt>localhost(ro)</tt>
#
# [*bind*]
#   String. Sets the bind options setted in /etc/fstab for the bindmounts created.
#   Defaults to <tt>rbind</tt>
#
# [*ensure*]
#   String. If enabled the mount will be created. Defaults to <tt>mounted</tt>
#
# [*remounts*]
#   String. Sets the remounts parameter of the mount.
#
# [*atboot*]
#   String. Sets the atboot parameter of the mount.
#
# [*options_nfsv4*]
#   String. Sets the mount options for a nfs version 4 exported resource mount.
#
# [*options_nfs*]
#   String. Sets the mount options for a nfs exported resource mount.
#
# [*bindmount*]
#   String. When not undef it will create a bindmount on the node
#   for the nfs mount.
#
# [*nfstag*]
#   String. Sets the nfstag parameter of the mount.
#
# [*mount*]
#   String. Sets the mountpoint the client will mount the exported resource mount on. If undef
#   it defaults to the same path as on the server
#
# [*owner*]
#   String. Sets the owner of the exported directory
#
# [*group*]
#   String. Sets the group of the exported directory
#
# [*mode*]
#   String. Sets the permissions of the exported directory.
#
# [*server*]
#   String. Sets the hostname clients will use to mount the exported resource. If undef it
#   defaults to the trusted certname
#
# === Examples
#
# class { '::nfs':
#   server_enabled             => true,
#   nfs_v4                     => true,
#   nfs_v4_export_root         => '/share',
#   nfs_v4_export_root_clients => '1.2.3.4/24(rw,fsid=root,insecure,no_subtree_check,async,no_root_squash)',
# }
#
# nfs::server::export { '/srv/nfs_exported/directory':
#   clients => '1.2.3.4/24(rw,insecure,no_subtree_check,async,no_root_squash) 5.6.7.8/24(ro)',
#   share => 'share_name_on_nfs_server',
# }
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

define nfs::server::export (
  $v3_export_name         = $name,
  $v4_export_name         = regsubst($name, '.*/(.*)', '\1' ),
  $clients                = 'localhost(ro)',
  $bind                   = 'rbind',
  # globals for this share
  # propogated to storeconfigs
  $ensure                 = 'mounted',
  $mount                  = undef,
  $remounts               = false,
  $atboot                 = false,
  $options_nfsv4          = $nfs::client_nfsv4_options,
  $options_nfs            = $nfs::client_nfs_options,
  $bindmount              = undef,
  $nfstag                 = undef,
  $owner                  = undef,
  $group                  = undef,
  $mode                   = undef,
  $server                 = $facts['clientcert'],
  $nfsv4_bindmount_enable = $nfs::nfsv4_bindmount_enable,
) {
  if $nfs::server::nfs_v4 {
    if $nfsv4_bindmount_enable {
      $export_name = $v4_export_name
      $export_title = "${nfs::server::nfs_v4_export_root}/${export_name}"
      $create_export_require = [Nfs::Functions::Nfsv4_bindmount[$name]]

      nfs::functions::nfsv4_bindmount { $name:
        ensure         => $ensure,
        v4_export_name => $export_name,
        bind           => $bind,
      }
    } else {
      $export_name = $name
      $export_title = $name
      $create_export_require = []
    }

    nfs::functions::create_export { $export_title:
      ensure  => $ensure,
      clients => $clients,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      require => $create_export_require,
    }

    if $mount != undef {
      $mount_name = $mount
    } else {
      $mount_name = $export_name
    }

    if $nfs::storeconfigs_enabled {
      @@nfs::client::mount { $mount_name:
        ensure        => $ensure,
        remounts      => $remounts,
        atboot        => $atboot,
        options_nfsv4 => $options_nfsv4,
        bindmount     => $bindmount,
        nfstag        => $nfstag,
        share         => $export_name,
        server        => $server,
      }
    }
  } else {
    if $mount != undef {
      $mount_name = $mount
    } else {
      $mount_name = $v3_export_name
    }

    nfs::functions::create_export { $v3_export_name:
      ensure  => $ensure,
      clients => $clients,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
    }

    if $nfs::storeconfigs_enabled {
      @@nfs::client::mount { $mount_name:
        ensure      => $ensure,
        remounts    => $remounts,
        atboot      => $atboot,
        options_nfs => $options_nfs,
        nfstag      => $nfstag,
        share       => $v3_export_name,
        server      => $server,
      }
    }
  }
}
