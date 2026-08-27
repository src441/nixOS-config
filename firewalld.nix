{config, pkgs, inputs, ...}:

{
 environment.etc."firewalld/services/sunshine.xml".text = ''
  <?xml version="1.0" encoding="utf-8"?>
  <service>
    <short>Sunshine</short>
    <description>Sunshine Game Streaming Server for Moonlight clients</description>
    <port protocol="tcp" port="47984"/>
    <port protocol="tcp" port="47989"/>
    <port protocol="tcp" port="47990"/>
    <port protocol="tcp" port="48010"/>
    <port protocol="udp" port="5353"/>
    <port protocol="udp" port="47998-48000"/>
    <port protocol="udp" port="48002"/>
    <port protocol="udp" port="48010"/>
  </service>
'';
}
