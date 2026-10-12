<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang ="en">
  <head>
    <meta http-equiv="content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="content-style-type" content="text/css" />
    <meta http-equiv="content-script-type" content="text/javascript" />
    <meta http-equiv="content-language" content="en" />
    <meta http-equiv="pragma" content="no-cache" />
    <meta http-equiv="cache-control" content="no-cache" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="Get my IP Address" />
    <meta name="keywords" content="ip address ifconfig" />
    <meta name="google-adsense-account" content="ca-pub-1687667848944125" />
    <meta name="author" content="ifconfig.tw" />
    <link rel="shortcut icon" href="/static/img/favicon.ico" />
    <link rev="made" href="mailto: {{.Email}}" />
    <title>What Is My IP Address? - Powered by ifconfig.tw</title>
    <style type="text/css">
    * {margin:0; padding:0;font-style:normal;font-weight:normal;font-family:Arial,sans-serif;font-size:13px;color:#333;}
      body{}
      #container{background:white;width:calc(100% - 22px);max-width:750px;margin:10px auto;margin-bottom:10px;border:solid 1px #888;}
      #header{min-height:50px;padding:15px 0 10px 10px;}
      #header table{width:100%;}
      h1 a{font-size:20px;margin:10px;letter-spacing:1px;text-decoration:none;color:#555;}
      #ads{height:20px;margin-bottom:15px;text-align:right;background:#777;padding-top:4px;border-left:solid 1px #888;border-right:solid 1px #888;}
      #info_area{margin:0 10px;}
      #info_table{border-collapse:collapse;margin:0 auto;line-height:20px;width:100%;table-layout:fixed;}
      #info_table tr{height:30px;}
      #info_table td{border: solid 1px #888;padding: 0px 10px;overflow-wrap:anywhere;word-break:normal;}
      .info_table_label{width:100px;}
      #table_ads{width:260px;text-align:center;}
      #middle{height:110px;clear:both;text-align:center;padding-top:20px;}
      #cli_wrap{margin:0 10px;}
      h2{height:30px;line-height:30px;font-size:18px;margin:0 5px;padding-left:5px;}
      #cli_table{border:solid 1px #888;border-collapse:collapse;width:100%;margin:0 auto;line-height:20px;table-layout:fixed;}
      #cli_table tr{height:30px;}
      #cli_table td{border-bottom: solid 1px #888;padding-top:3px;padding-bottom:3px;overflow-wrap:anywhere;word-break:normal;}
      .cli_command{width:190px;padding-left:10px;}
      .cli_arrow{width:40px;text-align:center;}
      #footer{background:#777;min-height:20px;line-height:20px;color:#ddd;text-align:center;margin-top:15px;border-top:none;}
      #ip_address{font-size:1.9em;}
      #ip_address_cell{padding:5px;height:50px;}
      
    #plungins{height:20px;float:right;}
    .plungin{float:right;}
    #button_twitter{width:100px;}
    #button_plusone{width:70px;}
    #button_facebook{width:100px;}
      #guide{margin:24px 10px;line-height:1.6;overflow-wrap:anywhere;}
      #guide h3{font-size:15px;margin:16px 5px 6px;}
      #guide p{margin:0 5px 10px;}
      #guide pre{margin:0 5px 10px;white-space:pre-wrap;overflow-wrap:anywhere;}
      #footer a{color:#fff;}
      @media (max-width:600px) {
        .info_table_label{width:80px;}
        .cli_command{width:120px;}
        .cli_arrow{width:24px;}
        h1 a{margin:0;line-height:1.4;}
      }
    </style>
  </head>
  <body>
    <div id="container" class="clearfix">
      <div id="header">
        <table>
          <tr>
            <td>
              <h1><a href="https://ifconfig.tw">What Is My IP Address? - Powered by ifconfig.tw</a></h1>
            </td>
            <td></td>
          </tr>
          <tr>
            <td></td>
            <td>
            </td>
          </tr>
        </table>
      </div>
      <div id="info_area">
        <h2>Your Connection</h2>
        <table id="info_table" summary="info">
          <tr>
            <td class="info_table_label">IP Address</td>
            <td id="ip_address_cell"><strong id="ip_address">{{.IP}}</strong></td>
          </tr>
          <tr><td class="info_table_label">Remote Host</td><td>{{.Host}}</td></tr>
          <tr><td class="info_table_label">User Agent</td><td>{{.UserAgent}}</td></tr>
          <tr><td class="info_table_label">Port</td><td>{{.Port}}</td></tr>
          <tr><td class="info_table_label">Language</td><td>{{.Lang}}</td></tr>
          <tr><td class="info_table_label">Referer</td><td>{{.Referer}}</td></tr>
          <tr><td class="info_table_label">Connection</td><td>{{.Connection}}</td></tr>
          <tr><td class="info_table_label">KeepAlive</td><td>{{.Keepalive}}</td></tr>
          <tr><td class="info_table_label">Method</td><td>{{.Method}}</td></tr>
          <tr><td class="info_table_label">Encoding</td><td>{{.Encoding}}</td></tr>
          <tr><td class="info_table_label">MIME Type</td><td>{{.Mime}}</td></tr>
          <tr><td class="info_table_label">Charset</td><td>{{.Charset}}</td></tr>
          <tr><td class="info_table_label">Via</td><td>{{.Via}}</td></tr>
          <tr><td class="info_table_label">X-Forwarded-For</td><td>{{.Forwarded}}</td></tr>
        </table>
      </div>
      <div id="middle">
      </div>
      <div id="cli_wrap">
        <h2>Command Line Interface</h2>
        <table id="cli_table" summary="cli">
          <tr><td class="cli_command">$ curl https://ifconfig.tw</td><td class="cli_arrow">&rArr;</td><td>{{.IP}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/ip</td><td class="cli_arrow">&rArr;</td><td>{{.IP}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/host</td><td class="cli_arrow">&rArr;</td><td>{{.Host}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/ua</td><td class="cli_arrow">&rArr;</td><td>{{.UserAgent}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/port</td><td class="cli_arrow">&rArr;</td><td>{{.Port}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/lang</td><td class="cli_arrow">&rArr;</td><td>{{.Lang}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/keepalive</td><td class="cli_arrow">&rArr;</td><td>{{.Keepalive}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/connection</td><td class="cli_arrow">&rArr;</td><td>{{.Connection}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/encoding</td><td class="cli_arrow">&rArr;</td><td>{{.Encoding}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/mime</td><td class="cli_arrow">&rArr;</td><td>{{.Mime}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/charset</td><td class="cli_arrow">&rArr;</td><td>{{.Charset}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/via</td><td class="cli_arrow">&rArr;</td><td>{{.Via}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/forwarded</td><td class="cli_arrow">&rArr;</td><td>{{.Forwarded}}</td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/all</td><td class="cli_arrow">&rArr;</td><td>ip_addr: {{.IP}}<br />remote_host: {{.Host}} <br />user_agent: {{.UserAgent}}<br />port: {{.Port}}<br />lang: {{.Lang}}<br />connection: {{.Connection}}<br />keep_alive: {{.Keepalive}}<br />encoding: {{.Encoding}}<br />mime: {{.Mime}}<br />charset: {{.Charset}}<br />via: {{.Via}}<br />forwarded: {{.Forwarded}}<br /></td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/all.xml</td><td class="cli_arrow">&rArr;</td><td><pre style="white-space:pre-wrap;overflow-wrap:anywhere">{{.XMLExample}}</pre></td></tr>
          <tr><td class="cli_command">$ curl https://ifconfig.tw/all.json</td><td class="cli_arrow">&rArr;</td><td><pre style="white-space:pre-wrap;overflow-wrap:anywhere">{{.JSONExample}}</pre></td></tr>
        </table>
      </div>
      <section id="guide" aria-label="About this tool">
        <h2>About this tool</h2>
        <p>ifconfig.tw is a public IP and HTTP connection checker. Use it to see the address presented by your connection, check whether a VPN changes that address, or inspect the headers a client sends. The public address may belong to a router, VPN or shared network rather than an individual device.</p>
        <h3>IPv4 and IPv6</h3>
        <p>Your browser shows the address family used for this particular connection. A network can have both IPv4 and IPv6 addresses. To check each separately with curl, use:</p>
        <pre>curl -4 https://ifconfig.tw/ip
curl -6 https://ifconfig.tw/ip</pre>
        <p>An IPv6-only check requires working IPv6 connectivity; an unsuccessful request does not prove your device has no IPv6 address.</p>
        <h3>Proxies and iCloud Private Relay</h3>
        <p>This service reports the address that reaches our server. A VPN, HTTP proxy or iCloud Private Relay can replace your network's address with a relay exit address. On supported Apple devices, Private Relay can forward unencrypted HTTP app traffic. Using curl -4 controls curl's connection, but a relay can choose a different address family for its connection to the website.</p>
        <p>For command-line checks, use HTTPS. You can also use the IPv4-only hostname:</p>
        <pre>curl -4 https://ifconfig.tw/ip
curl https://v4.ifconfig.tw/ip</pre>
        <p>A proxy or VPN may still affect the address you see. The service cannot recover an original address that a privacy relay does not disclose.</p>
        <h3>Remote Host and Port</h3>
        <p>Remote Host is a reverse DNS name associated with the public IP address. It may be empty when no name can be found, and it does not identify a person's physical location. Port is the source port seen by the service, which may be changed by a router or VPN.</p>
        <h3>Request headers</h3>
        <p>User Agent describes the client software. MIME Type shows the client's Accept header, which lists response formats it can accept. Language shows Accept-Language. These values are supplied by the client and can be changed, so they should not be treated as proof of identity.</p>
        <h3>Using the API</h3>
        <p>Use /ip for a plain IP address, /all for text fields, /all.json for JSON, or /all.xml for XML. JSON and XML use fields such as ip_addr and remote_host. Add ?format=legacy to the JSON or XML URL if you need the older field names. The API endpoints are suitable for command-line tools and contain no advertising scripts.</p>
        <p><a href="/privacy">Privacy &amp; advertising</a> · <a href="mailto:admin@ifconfig.tw">Contact</a></p>
      </section>
      <div id="footer">&copy; 2016 <a href="https://ifconfig.tw">ifconfig.tw</a> · <a href="/privacy">Privacy &amp; advertising</a></div>
    </div>
    <script>
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

      ga('create', 'UA-82067111-1', 'auto');
      ga('send', 'pageview');

    </script>
  </body>	
</html>
