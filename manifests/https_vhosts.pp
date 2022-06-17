# Class: websitelite::http_vhosts
#
# Create apacha::vhost resources based on site definitions from
# Hiera. the Hash merge of websitelite::http_vhosts is defined
# in common.y aml.
#
# Do the HTTPS vhosts
#
#
class websitelite::https_vhosts(
  $defaults     = undef,
  $blessed      = $::websitelite::blessed,
  $https_vhosts = $::websitelite::https_vhosts,
){
  if $blessed {
    require ::websitelite::letsencrypt
  }

  create_resources(apache::vhost, $https_vhosts, $defaults)

}
