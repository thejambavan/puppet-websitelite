# =Class: websitelite::status
# exports status resources for icinga to collect
class websitelite::status (
  $domain        = $::fqdn,
  $prefix        = '/',
  $code          = '200',
  $string        = 'System OK',
  $servicegroups = ['linux-servers', 'websites'],
){
  @@icinga2::object::service { "${domain} status":
    host_name      => $::fqdn,
    display_name   => "${domain} app status",
    check_command  => 'http',
    check_interval => '5m',
    target         => "/etc/icinga2/conf.d/${::fqdn}.conf",
    groups         => $servicegroups,
    vars           => {
      http_vhost                     => $domain,
      http_uri                       => $prefix,
      http_ssl_force_tlsv1_or_higher => true,
      http_sni                       => true,
      http_ssl                       => true,
      http_expect                    => $code,
      http_expect_body_regex         => $string
    },
  }
}

