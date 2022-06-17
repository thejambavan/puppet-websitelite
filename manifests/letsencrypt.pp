# Class: websitelite::letsencrypt
class websitelite::letsencrypt(
  $defaults = undef,
  $certs    = $::websitelite::certs
){

  require ::websitelite::http_vhosts

  create_resources(letsencrypt::certonly, $certs, $defaults)
}
