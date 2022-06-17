# profile::website allows you to deploy a fully configured, encrypted site that'll pass SSLLabs
# with an A++
# !!! STILL IN DEVELOPMENT !!!
#
class websitelite(
  $http_vhosts      = undef,
  $https_vhosts     = undef,
  $certs            = undef,
  $apache_mods      = undef,
  $blessed          = true, # "blessed" hosts may issue LE certs
  $saml_vhosts      = undef,
  $status           = false,
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

  if ( 'security' in $apache_mods ) {
    include ::websitelite::waf
  }

  include ::websitelite::monitoring
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
