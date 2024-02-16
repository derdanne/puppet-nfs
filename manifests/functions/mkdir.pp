# == Function: nfs::functions::mkdir
#
# This Function exists to
#  1. manage dir creation
#
# === Parameters
#
# None
#
# === Examples
#
# This Function should not be called directly.
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

define nfs::functions::mkdir (
  $ensure = 'present',
) {
  if $ensure != 'absent' {
    exec { "mkdir_recurse_${name}":
      path    => ['/bin', '/usr/bin'],
      command => "mkdir -p ${name}",
      unless  => "test -d ${name}",
    }
  }
}
