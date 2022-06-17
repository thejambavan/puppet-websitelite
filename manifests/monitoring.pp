# =Class: websitelite::monitoring
# exports monitoring resources for icinga to collect
class websitelite::monitoring (
  $http_certificate = '15',
  $domains          = [$::fqdn],
  $servicegroups    = ['linux-servers', 'websites'],
){
  $domains.each|$domain| {
    @@icinga2::object::service { "${domain}-https":
      host_name      => $::fqdn,
      display_name   => "HTTP-SSL ${domain}",
      check_command  => 'http',
      check_interval => '5m',
      target         => "/etc/icinga2/conf.d/${::fqdn}.conf",
      groups         => $servicegroups,
      vars           => {
        http_vhost                     => $domain,
        http_ssl_force_tlsv1_or_higher => true,
        http_sni                       => true,
        http_ssl                       => true,
        http_certificate               => $http_certificate,
      },
    }
  }
  @@icinga2::object::service { "${::fqdn}-http":
    host_name      => $::fqdn,
    display_name   => 'HTTP',
    check_command  => 'http',
    check_interval => '5m',
    target         => "/etc/icinga2/conf.d/${::fqdn}.conf",
    groups         => $servicegroups,
  }
}

