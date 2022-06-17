# N.T. When apache mod_security is enabled, only basic ruleset is added.
# Here we will download OWASP ruleset v3.3.0

# Class: profile::website2::waf
class websitelite::waf (

  $owasp_url = 'https://codeload.github.com/coreruleset/coreruleset/tar.gz/v3.3.0',
  $owasp_package = 'corerules-3.3.0.tar.gz',
  $owasp_path = '/etc/httpd/modsecurity.d',
  $secruleenginestate = 'DetectionOnly',

) {

  archive { $owasp_package:
    path            => "/tmp/${owasp_package}",
    source          => $owasp_url,
    extract         => true,
    extract_path    => $owasp_path,
    extract_command => 'tar xfz %s --strip-components=1',
    cleanup         => false,
    creates         => "${owasp_path}/crs-setup.conf.example",
    require         => File[$owasp_path]
  }

  file { "${owasp_path}/security_crs.conf":
    ensure => absent,
  }
  file { "${owasp_path}/crs-setup.conf":
    ensure => file,
    source => "${owasp_path}/crs-setup.conf.example"
  }

# This will create symlinks to all downloaded rules, we will probably want to remove some
  exec { 'Apply OWASP ruleset':
    command  => 'for f in ../rules/* ; do ln -s $f ; done',
    provider => shell,
    cwd      => "${owasp_path}/activated_rules",
    onlyif   => "test -d ${owasp_path}/rules"
  }

  file { "${owasp_path}/modsecurity.conf":
    ensure  => present,
    content => template("${module_name}/etc/httpd/modsecurity.conf.erb"),
  }

  file { "${owasp_path}/unicode.mapping":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/${module_name}/etc/httpd/unicode.mapping",
  }

}
