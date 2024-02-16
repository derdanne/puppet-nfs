# == Class: nfs::params
#
# This class exists to
# 1. Declutter the default value assignment for class parameters.
# 2. Manage internally used module variables in a central place.
#
# Therefore, many operating system dependent differences (names, paths, ...)
# are addressed in here.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class is not intended to be used directly.
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

class nfs::params {
  #### Default values for the parameters of the main module class, init.pp

  $nfs_v4                     = false
  $nfs_v4_export_root         = '/export'
  $nfs_v4_export_root_clients = "*.${facts['networking']['domain']}(ro,fsid=root,insecure,no_subtree_check,async,root_squash)"
  $nfs_v4_mount_root          = '/srv'

  if $facts['networking']['domain'] != undef {
    $nfs_v4_idmap_domain = $facts['networking']['domain']
  } else {
    $nfs_v4_idmap_domain = 'example.org'
  }

  # Different path and package definitions
  case $facts['os']['family'] {
    'Debian': {
      $exports_file          = '/etc/exports'
      $idmapd_file           = '/etc/idmapd.conf'
      $defaults_file         = '/etc/default/nfs-common'
      $server_packages       = ['nfs-common', 'nfs-kernel-server', 'nfs4-acl-tools', 'rpcbind']
      $client_packages       = ['nfs-common', 'nfs4-acl-tools', 'rpcbind']
      $client_rpcbind_config = '/etc/default/rpcbind'
    }
    'RedHat': {
      $exports_file          = '/etc/exports'
      $idmapd_file           = '/etc/idmapd.conf'
      $defaults_file         = '/etc/sysconfig/nfs'
      $server_packages       = ['nfs-utils', 'nfs4-acl-tools', 'rpcbind']
      $client_packages       = ['nfs-utils', 'nfs4-acl-tools', 'rpcbind']
      $client_rpcbind_config = '/etc/sysconfig/rpcbind'
    }
    'Gentoo': {
      $exports_file          = '/etc/exports'
      $idmapd_file           = '/etc/idmapd.conf'
      $defaults_file         = '/etc/conf.d/nfs'
      $server_packages       = ['net-nds/rpcbind', 'net-fs/nfs-utils', 'net-libs/libnfsidmap']
      $client_packages       = ['net-nds/rpcbind', 'net-fs/nfs-utils', 'net-libs/libnfsidmap']
      $client_rpcbind_config = undef
    }
    'Suse': {
      $exports_file          = '/etc/exports'
      $idmapd_file           = '/etc/idmapd.conf'
      $server_packages       = ['nfs-kernel-server']
      $client_packages       = ['nfsidmap', 'nfs-client', 'rpcbind']
      $defaults_file         = undef
      $client_rpcbind_config = undef
    }
    'Archlinux': {
      $exports_file          = '/etc/exports'
      $idmapd_file           = '/etc/idmapd.conf'
      $server_packages       = ['nfs-utils']
      $client_packages       = ['nfs-utils', 'nfsidmap', 'rpcbind']
      $defaults_file         = undef
      $client_rpcbind_config = undef
    }
    default: {
      $exports_file          = undef
      $idmapd_file           = undef
      $defaults_file         = undef
      $server_packages       = undef
      $client_packages       = undef
      $client_rpcbind_config = undef
      notice("\"${module_name}\" provides no config directory and package default values for OS family \"${facts['os']['family']}\"")
    }
  }

  # service parameters
  # params that are the same on all (known) OSes.
  $client_nfs_fstype          = 'nfs'
  $client_services_hasrestart = true
  $client_services_hasstatus  = true
  $client_gssd_options        = ''
  $server_service_hasrestart  = true
  $server_service_hasstatus   = true
  $server_service_restart_cmd = undef
  #params with OS-specific values
  case $facts['os']['family'] {
    'Debian': {
      $client_idmapd_setting      = ['set NEED_IDMAPD yes']
      $client_nfs_options         = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,nfsvers=3,actimeo=3'
      $client_services_enable     = true
      $client_nfsv4_fstype        = 'nfs4'
      $client_nfsv4_options       = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,actimeo=3'
      $nfs_v4_idmap_nobody_user   = 'nobody'
      $nfs_v4_idmap_nobody_group  = 'nogroup'
      $client_rpcbind_optname     = 'OPTIONS'

      case $facts['os']['distro']['codename'] {
        'trusty': {
          $client_services            = { 'rpcbind' => {} }
          $client_nfsv4_services      = { 'rpcbind' => {}, 'nfs-common' => { require => Service['rpcbind'] } }
          $client_gssd_service_name   = undef
          $server_nfsv4_servicehelper = undef
          $server_service_name        = 'nfs-kernel-server'
          $client_gssdopt_name        = 'RPCGSSDOPTS'
        }
        'jessie', 'wheezy': {
          $client_services            = { 'rpcbind' => {} }
          $client_nfsv4_services      = { 'rpcbind' => {}, 'nfs-common' => { require => Service['rpcbind'] } }
          $client_gssd_service_name   = undef
          $server_nfsv4_servicehelper = ['nfs-common']
          $server_service_name        = 'nfs-kernel-server'
          $client_gssdopt_name        = 'RPCGSSDOPTS'
        }
        'bullseye', 'buster', 'stretch', 'xenial', 'yakkety', 'zesty': {
          $client_services            = { 'rpcbind' => {
              ensure => 'running',
              enable => false,
            },
          }
          $client_gssd_service_name   = { 'rpc-gssd' => {
              ensure => 'running',
              enable => true,
            },
          }
          $client_nfsv4_services      = { 'rpcbind' => {
              ensure => 'running',
              enable => false,
            },
          }
          $server_nfsv4_servicehelper = ['nfs-idmapd']
          $server_service_name        = 'nfs-kernel-server'
          $client_gssdopt_name        = 'GSSDARGS'
        }
        'bionic', 'focal', 'jammy', 'kinetic': {
          $client_services            = { 'rpcbind' => {} }
          $client_gssd_service_name   = { 'rpc-gssd' => {
              ensure => 'running',
              enable => true,
            },
          }
          $client_nfsv4_services      = { 'rpcbind' => {} }
          $server_nfsv4_servicehelper = undef
          $server_service_name        = 'nfs-kernel-server'
          $client_gssdopt_name        = 'GSSDARGS'
        }
        default: {
          $client_services            = { 'rpcbind' => {} }
          $client_gssd_service_name   = { 'rpc-gssd' => {
              ensure => 'running',
              enable => true,
            },
          }
          $client_nfsv4_services      = { 'rpcbind' => {} }
          $server_nfsv4_servicehelper = ['idmapd']
          $server_service_name        = 'nfs-kernel-server'
          $client_gssdopt_name        = 'GSSDARGS'
        }
      }
    }
    'RedHat': {
      $nfs_v4_idmap_nobody_user   = 'nobody'
      $nfs_v4_idmap_nobody_group  = 'nobody'
      $client_rpcbind_optname     = 'RPCBIND_ARGS'
      case $facts['os']['release']['major'] {
        '7': {
          $client_idmapd_setting      = ['']
          $client_nfs_options         = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,nfsvers=3,actimeo=3'
          $client_services_enable     = true
          $client_gssdopt_name        = 'RPCGSSDARGS'
          if versioncmp($facts['os']['release']['full'], '7.5') < 0 {
            $client_services            = { 'rpcbind.service' => {
                ensure => 'running',
                enable => false,
              },
              'rpcbind.socket' => {
                ensure => 'running',
                enable => true,
              },
            }
          }
          else {
            $client_services            = { 'rpcbind.service' => {} }
          }
          $client_gssd_service_name   = { 'rpc-gssd' => {
              ensure => 'running',
              enable => true,
            },
          }
          $client_nfsv4_fstype        = 'nfs4'
          $client_nfsv4_options       = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,actimeo=3'
          if versioncmp($facts['os']['release']['full'], '7.5') < 0 {
            $client_nfsv4_services      = { 'rpcbind.service' => {
                ensure => 'running',
                enable => false,
              },
              'rpcbind.socket' => {
                ensure => 'running',
                enable => true,
              },
            }
          }
          else {
            $client_nfsv4_services      = { 'rpcbind' => {} }
          }
          $server_nfsv4_servicehelper = ['nfs-idmap.service']
          $server_service_name        = 'nfs-server.service'
        }
        '8': {
          $client_idmapd_setting      = ['']
          $client_nfs_options         = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,actimeo=3'
          $client_services_enable     = true
          $client_gssdopt_name        = 'RPCGSSDARGS'
          $client_services            = { 'rpcbind.service' => {} }
          $client_gssd_service_name   = { 'rpc-gssd' => {
              ensure => 'running',
              enable => true,
            },
          }
          $client_nfsv4_fstype        = 'nfs4'
          $client_nfsv4_options       = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,actimeo=3'
          $client_nfsv4_services      = { 'rpcbind' => {} }
          $server_nfsv4_servicehelper = ['nfs-idmapd.service']
          $server_service_name        = 'nfs-server.service'
        }
        '9': {
          $client_idmapd_setting      = ['']
          $client_nfs_options         = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,actimeo=3'
          $client_services_enable     = true
          $client_gssdopt_name        = 'RPCGSSDARGS'
          $client_services            = { 'rpcbind.service' => {} }
          $client_gssd_service_name   = { 'rpc-gssd' => {
              ensure => 'running',
              enable => true,
            },
          }
          $client_nfsv4_fstype        = 'nfs4'
          $client_nfsv4_options       = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,actimeo=3'
          $client_nfsv4_services      = { 'rpcbind' => {} }
          $server_nfsv4_servicehelper = ['nfs-idmapd.service']
          $server_service_name        = 'nfs-server.service'
        }
        default: {
          $client_gssdopt_name        = 'RPCGSSDARGS'
          $client_idmapd_setting      = ['']
          $client_nfs_options         = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,actimeo=3'
          $client_services_enable     = true
          $client_services            = { 'rpcbind' => {} }
          $client_gssd_service_name   = { 'rpc-gssd' => {
              ensure => 'running',
              enable => true,
            },
          }
          $client_nfsv4_fstype        = 'nfs4'
          $client_nfsv4_options       = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,actimeo=3'
          $client_nfsv4_services      = { 'rpcbind' => {}, 'rpcidmapd' => {} }
          $server_nfsv4_servicehelper = ['rpcidmapd', 'rpcbind']
          $server_service_name        = 'nfs'
        }
      }
    }
    'Gentoo': {
      $nfs_v4_idmap_nobody_user   = 'nobody'
      $nfs_v4_idmap_nobody_group  = 'nogroup'
      $client_rpcbind_optname     = 'OPTS_RPC_NFSD'
      $client_gssdopt_name        = 'RPCGSSDARGS'
      $client_idmapd_setting      = ['set NFS_NEEDED_SERVICES rpc.idmapd']
      $client_nfs_options         = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,nfsvers=3,actimeo=3'
      $client_services_enable     = true
      $client_services            = { 'rpcbind' => {} }
      $client_gssd_service_name   = undef
      $client_nfsv4_fstype        = 'nfs4'
      $client_nfsv4_options       = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,nfsvers=4,actimeo=3'
      $client_nfsv4_services      = { 'rpcbind' => {}, 'rpc.idmapd' => {} }
      $server_nfsv4_servicehelper = ['rpc.idmapd']
      $server_service_name        = 'nfs'
    }
    'Suse': {
      $nfs_v4_idmap_nobody_user   = 'nobody'
      $nfs_v4_idmap_nobody_group  = 'nobody'
      $client_rpcbind_optname     = 'RPCNFSDARGS'
      $client_gssdopt_name        = 'GSSD_OPTIONS'
      $client_idmapd_setting      = ['']
      $client_nfs_options         = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,nfsvers=3,actimeo=3'
      $client_services_enable     = true
      $client_services            = { 'rpcbind' => { before => Service['nfs'] }, 'nfs' => {} }
      $client_gssd_service_name   = undef
      $client_nfsv4_fstype        = 'nfs4'
      $client_nfsv4_options       = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,nfsvers=4,actimeo=3'
      $client_nfsv4_services      = { 'rpcbind' => { before => Service['nfs'] }, 'nfs' => {} }
      $server_nfsv4_servicehelper = undef
      $server_service_name        = 'nfsserver'
    }
    'Archlinux': {
      $nfs_v4_idmap_nobody_user   = 'nobody'
      $nfs_v4_idmap_nobody_group  = 'nobody'
      $client_rpcbind_optname     = 'RPCNFSDARGS'
      $client_gssdopt_name        = 'RPCGSSDARGS'
      $client_idmapd_setting      = ['']
      $client_nfs_options         = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,nfsvers=3,actimeo=3'
      $client_services_enable     = true
      $client_services            = { 'rpcbind' => {} }
      $client_gssd_service_name   = undef
      $client_nfsv4_fstype        = 'nfs4'
      $client_nfsv4_options       = 'tcp,nolock,rsize=32768,wsize=32768,intr,noatime,nfsvers=4,actimeo=3'
      $client_nfsv4_services      = { 'rpcbind' => {} }
      $server_nfsv4_servicehelper = ['nfs-idmapd']
      $server_service_name        = 'nfs-server.service'
    }
    default: {
      # need to explicitly set unknown params to undef to work with strict_variables=true
      $nfs_v4_idmap_nobody_user   = undef
      $nfs_v4_idmap_nobody_group  = undef
      $client_rpcbind_optname     = undef
      $client_gssdopt_name        = undef
      $client_idmapd_setting      = undef
      $client_nfs_options         = undef
      $client_nfsv4_fstype        = undef
      $client_nfsv4_options       = undef
      $client_nfsv4_services      = undef
      $client_gssd_service_name   = undef
      $server_nfsv4_servicehelper = undef
      $client_services_enable     = undef
      $server_service_name        = undef
      notice("\"${module_name}\" provides no service parameters for OS family \"${facts['os']['family']}\"")
    }
  }
}
