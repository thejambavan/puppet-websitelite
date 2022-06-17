# SSO with auth_mod_mellon
# This class does per-host keygen and metadata exchange, and
# no longer does any Apache config, which is done purely in hiera:
#
# directories:
#  - path: '/'
#    provider: 'location'
#    mellon_enable: 'info'
#    mellon_endpoint_path: '/saml'
#    mellon_sp_private_key_file: "/etc/mellon/somehost/privkey.pem"
#    mellon_sp_cert_file: "/etc/mellon/somehost/cert.pem"
#    mellon_sp_metadata_file: "/etc/mellon/somehost/sp-metadata.xml"
#    mellon_idp_metadata_file: "/etc/mellon/somehost/idp-metadata.xml"
#  - path: '/private/'
#    provider: 'location'
#    auth_type: 'Mellon'
#    require: 'valid-user'
#    mellon_enable: 'auth'
#    mellon_cond:
#     - 'group sysadmins [OR]'
#     - 'uid bob'
#
class websitelite::saml(
  $defaults    = undef,
  $saml_vhosts = $::websitelite::saml_vhosts
){

  create_resources(::websitelite::saml_vhost, $saml_vhosts, $defaults)
}
