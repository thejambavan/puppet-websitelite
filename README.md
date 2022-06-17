# Websitelite

A puppet module called ::websitelite which is intended to support all business-specific web server configuration. It enforces several pieces of good practice including:

* SAML2 AuthN and secret exchange
* Letsencrypt certificate issuing for both "host" domains and public-facing ones
* Optional OWASP Web Application Firewall
* Enforcement of TLS-only traffic via redirect
* Notification of the [Monitoring] service of
 * Website Presence
 * TLS certificate status and renewal
 * "Status" page (including, optionally, custom status strings)

You should always start a project with ::websitelite before attempting any manual web server configuration.

## Useful tweaks
Enforcement of ProxyProtocol for things that reside solely behind HAProxy

To enable the use of ProxyProtocol (complete with exceptions for things like Icinga servers that communicate over IPv6), add the following to your node's hiera:

```
websitelite::apache_mods:
  - remoteip
```
```
apache::mod::remoteip::proxy_protocol: true
```

Exceptions will be automatically added for the instance's own local addresses, and for any Icinga servers currently in use. 
