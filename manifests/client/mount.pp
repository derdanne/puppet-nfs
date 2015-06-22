# == Function: nfs::client::mount
#
# This Function exists to
#  1. manage all mounts on a nfs client
#
# === Parameters
#
# [*server*]
#   String. Sets the ip address of the server with the nfs export
#
# [*share*]
#   String. Sets the name of the nfs share on the server
#
# [*ensure*]
#   String. Sets the ensure parameter of the mount.
#
# [*remounts*]
#   String. Sets the remounts parameter of the mount.
#
# [*atboot*]
#   String. Sets the atboot parameter of the mount.
#
# [*options_nfsv4*]
#   String. Sets the mount options for a nfs version 4 mount.
#
# [*options_nfs*]
#   String. Sets the mount options for a nfs mount.
#
# [*bindmount*]
#   String. When not undef it will create a bindmount on the node
#   for the nfs mount.
#
# [*nfstag*]
#   String. Sets the nfstag parameter of the mount.
#
# [*nfs_v4*]
#   Boolean. When set to true, it uses nfs version 4 to mount a share.
#
# === Examples
#
# class { '::nfs':
#   client_enabled => true,
#   nfs_v4_client  => true
# }
#
# nfs::client::mount { '/target/directory':
#   server        => '1.2.3.4',
#   share         => 'share_name_on_nfs_server',
#   remounts      => true,
#   atboot        => true,
#   options_nfsv4 => 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,actimeo=3'
# }
#
# === Authors
#
# * Daniel Klockenkämper <mailto:dk@marketing-factory.de>
#

define nfs::client::mount (
  $server,
  $share,
  $ensure           = 'mounted',
  $mount            = $title,
  $remounts         = false,
  $atboot           = false,
  $options_nfsv4    = $::nfs::client_nfsv4_options,
  $options_nfs      = $::nfs::client_nfs_options,
  $bindmount        = undef,
  $nfstag           = undef,
  $nfs_v4           = $::nfs::client::nfs_v4
){

  if $nfs_v4 == true {
    if $mount == undef {
      $mountname = "${::nfs::nfs_v4_mount_root}/${share}"
    } else {
      $mountname = $mount
    }

    nfs::functions::mkdir { $mountname: }
    mount { "shared ${share} by ${::clientcert} on ${mountname}":
      ensure   => $ensure,
      device   => "${server}:/${share}",
      fstype   => $::nfs::client_nfsv4_fstype,
      name     => $mountname,
      options  => $options_nfsv4,
      remounts => $remounts,
      atboot   => $atboot,
      require  => Nfs::Functions::Mkdir[$mountname]
    }

    if $bindmount != undef {
      nfs::functions::bindmount { $mountname:
        ensure     => $ensure,
        mount_name => $bindmount
      }
    }
  } else {
    if $mount == undef {
      $mountname = $share
    } else {
      $mountname = $mount
    }

    nfs::functions::mkdir { $mountname: }
    mount { "shared ${share} by ${::clientcert} on ${mountname}":
      ensure   => $ensure,
      device   => "${server}:${share}",
      fstype   => $::nfs::client_nfs_fstype,
      name     => $mountname,
      options  => $options_nfs,
      remounts => $remounts,
      atboot   => $atboot,
      require  => Nfs::Functions::Mkdir[$mountname]
    }
  }
}
