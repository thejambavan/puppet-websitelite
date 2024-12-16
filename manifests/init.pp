# profile::website allows you to deploy a fully configured, encrypted site that'll pass SSLLabs
# with an A++
# !!! STILL IN DEVELOPMENT !!!
#
class websitelite(
  $http_vhosts          = undef,
  $https_vhosts         = undef,
  $certs                = undef,
  $apache_mods          = undef,
  $blessed              = true, # "blessed" hosts may issue LE certs
  $saml_vhosts          = undef,
  $status               = false,
  $monitoring           = true,
  $extra_mods           = undef,
  $oidcclientid         = undef,
  $oidcclientsecret     = undef,
  $oidccryptopassphrase = undef,

) {
  include ::apache
  include ::letsencrypt

  # Load modules if they're listed
  if $apache_mods {
    $apache_mods.each | String $module | {
      if $module == 'php' {
        include '::php'
      }
      include "apache::mod::${module}"
    }
  }
  if $extra_mods{
    $extra_mods.each | String $mod_name, Hash $content | {

      concat { "${mod_name}.conf":
        owner  => 0,
        group  => 0,
        path   => "${apache::params::mod_dir}/${mod_name}.conf",
        mode   => $apache::file_mode,
        notify =>  Class['Apache::Service'],
      }

      concat::fragment { "web_mod_00-${mod_name}":
        target  => "${apache::params::mod_dir}/${mod_name}.conf",
        order   => '01',
        content => inline_template("# Puppet generated Module configuration for ${mod_name}\n<% @content.keys.sort.each do |key| %>  <%= key %> <%= @content[key] %>\n<% end %>"),
      }
      file {"${mod_name} symlink":
        ensure => link,
        path   => "${apache::params::mod_enable_dir}/${mod_name}.conf",
        target => "${apache::params::mod_dir}/${mod_name}.conf",
        mode   => $apache::file_mode,
        notify => Class['apache::service'],
      }
    }
  }


  if ( 'security' in $apache_mods ) {
    include ::websitelite::waf
  }
  if $monitoring {
    include ::websitelite::monitoring
  }
  if $status {
    include ::websitelite::status
  }

  include ::websitelite::http_vhosts
  if $blessed {
    include ::websitelite::letsencrypt
  }
  include ::websitelite::https_vhosts

  # SSO with auth_mod_mellon
  # Don't include mod_auth_mellon unless we actually need to
  if size($saml_vhosts) > 0 {
    include apache::mod::auth_mellon
    include ::websitelite::saml
  }
}
