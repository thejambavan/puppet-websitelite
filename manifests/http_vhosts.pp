# =Class: websitelite::http_vhosts
#
# Create HTTP vhost resources
# Class: websitelite::http_vhosts
#
# Create apacha::vhost resources based on site definitions from Hiera. the Hash merge of websitelite::http_vhosts is defined in common.yaml.
class websitelite::http_vhosts(
  $defaults    = undef,
  $http_vhosts = $::websitelite::http_vhosts,
){

  create_resources(apache::vhost, $http_vhosts, $defaults)

}
