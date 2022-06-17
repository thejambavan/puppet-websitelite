# SSO with auth_mod_mellon
# Generates new key/certs as needed, bundles metadata into XML,
# fetches IdP metadata from IdP and stores appropriately.
#
# Afterwards, metadata is available at https://<host>/saml/metadata
#
define websitelite::saml_vhost (
  $idp_host      = undef,
  $export_vars   = [],
  $ssl_no_verify = false
) {
  if $idp_host == undef {
    fail('A SAML IdP host must be provided')
  }

  ensure_resource('file', '/etc/mellon/', {
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  })

  file { "/etc/mellon/${title}":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/etc/mellon/']
  }
  file { "/etc/mellon/${title}/generate.sh":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("${module_name}/etc/mellon/generate-lite.sh.erb"),
    require => File["/etc/mellon/${title}"],
    notify  => Exec["Generate SAML metadata for ${title}"]
  }
  exec { "Generate SAML metadata for ${title}":
    command     => "/etc/mellon/${title}/generate.sh",
    cwd         => "/etc/mellon/${title}",
    path        => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    refreshonly => true,
    require     => File["/etc/mellon/${title}/generate.sh"],
    notify      => Service['httpd']
  }
  exec { "Fetch SAML IdP metadata for ${idp_host} - ${title}":
    command => "curl -fk https://${idp_host}/saml/metadata > idp-metadata.xml",
    cwd     => "/etc/mellon/${title}",
    creates => "/etc/mellon/${title}/idp-metadata.xml",
    path    => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
    require => File["/etc/mellon/${title}/generate.sh"],
    notify  => Service['httpd']
  }
  @@profile::lemonldap::import { $title:
    tag           => ["saml-sp-${idp_host}"],
    ssl_no_verify => $ssl_no_verify
  }
}

