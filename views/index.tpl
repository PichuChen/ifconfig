<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang ="en">
  <head>
    <meta http-equiv="content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="content-style-type" content="text/css" />
    <meta http-equiv="content-script-type" content="text/javascript" />
    <meta http-equiv="content-language" content="en" />
    <meta http-equiv="pragma" content="no-cache" />
    <meta http-equiv="cache-control" content="no-cache" />
    <meta name="description" content="Get my IP Address" />
    <meta name="keywords" content="ip address ifconfig" />
    <meta name="author" content="ifconfig.tw" />
    <link rel="shortcut icon" href="/static/img/favicon.ico" />
    <link rev="made" href="mailto: {{.Email}}" />
    <title>What Is My IP Address? - Powered by ifconfig.tw</title>
    <style type="text/css">
    * {margin:0; padding:0;font-style:normal;font-weight:normal;font-family:Arial,sans-serif;font-size:13px;color:#333;}
      body{}
      #container{background:white;width:750px;margin:10px auto;margin-bottom:10px;border:solid 1px #888;}
      #header{height:50px;padding:15px 0 10px 10px;}
      #header table{width:100%;}
      h1 a{font-size:20px;margin:10px;letter-spacing:1px;text-decoration:none;color:#555;}
      #ads{height:20px;margin-bottom:15px;text-align:right;background:#777;padding-top:4px;border-left:solid 1px #888;border-right:solid 1px #888;}
      #info_area{float:left;margin-left:11px;}
      #info_table{border-collapse:collapse;margin:0 auto;line-height:20px;width:728px;table-layout:fixed;}
      #info_table tr{height:30px;}
      #info_table td{border: solid 1px #888;padding: 0px 10px;}
      .info_table_label{width:100px;}
      #table_ads{width:260px;text-align:center;}
      #middle{height:110px;clear:both;text-align:center;padding-top:20px;}
      #cli_wrap{margin:0 10px;}
      h2{height:30px;line-height:30px;font-size:18px;margin:0 5px;padding-left:5px;}
      #cli_table{border:solid 1px #888;border-collapse:collapse;width:728px;margin:0 auto;line-height:20px;table-layout:fixed;}
      #cli_table tr{height:30px;}
      #cli_table td{border-bottom: solid 1px #888;padding-top:3px;padding-bottom:3px;overflow:hidden;}
      .cli_command{width:190px;padding-left:10px;}
      .cli_arrow{width:40px;text-align:center;}
      #footer{background:#777;height:20px;line-height:20px;color:#ddd;text-align:center;margin-top:15px;border-top:none;}
      #ip_address{font-size:1.9em;}
      #ip_address_cell{padding:5px;height:50px;}
      
    #plungins{height:20px;float:right;}
    .plungin{float:right;}
    #button_twitter{width:100px;}
    #button_plusone{width:70px;}
    #button_facebook{width:100px;}
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
          <tr><td class="info_table_label">Method</td><td colspan="2">{{.Method}}</td></tr>
          <tr><td class="info_table_label">Encoding</td><td colspan="2">{{.Encoding}}</td></tr>
          <tr><td class="info_table_label">MIME Type</td><td colspan="2">{{.Mime}}</td></tr>
          <tr><td class="info_table_label">Charset</td><td colspan="2">{{.Charset}}</td></tr>
          <tr><td class="info_table_label">Via</td><td colspan="2">{{.Via}}</td></tr>
          <tr><td class="info_table_label">X-Forwarded-For</td><td colspan="2">{{.Forwarded}}</td></tr>
        </table>
      </div>
      <div id="middle">
      </div>
      <div id="cli_wrap">
        <h2>Command Line Interface</h2>
        <table id="cli_table" summary="cli">
          <tr><td class="cli_command">$ curl ifconfig.tw</td><td class="cli_arrow">&rArr;</td><td>{{.IP}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/ip</td><td class="cli_arrow">&rArr;</td><td>{{.IP}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/host</td><td class="cli_arrow">&rArr;</td><td>{{.Host}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/ua</td><td class="cli_arrow">&rArr;</td><td>{{.UserAgent}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/port</td><td class="cli_arrow">&rArr;</td><td>{{.Port}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/lang</td><td class="cli_arrow">&rArr;</td><td>{{.Lang}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/keepalive</td><td class="cli_arrow">&rArr;</td><td>{{.Keepalive}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/connection</td><td class="cli_arrow">&rArr;</td><td>{{.Connection}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/encoding</td><td class="cli_arrow">&rArr;</td><td>{{.Encoding}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/mime</td><td class="cli_arrow">&rArr;</td><td>{{.Mime}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/charset</td><td class="cli_arrow">&rArr;</td><td>{{.Charset}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/via</td><td class="cli_arrow">&rArr;</td><td>{{.Via}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/forwarded</td><td class="cli_arrow">&rArr;</td><td>{{.Forwarded}}</td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/all</td><td class="cli_arrow">&rArr;</td><td>ip_addr: {{.IP}}<br />remote_host: {{.Host}} <br />user_agent: {{.UserAgent}}<br />port: {{.Port}}<br />lang: {{.Lang}}<br />connection: {{.Connection}}<br />keep_alive: {{.Keepalive}}<br />encoding: {{.Encoding}}<br />mime: {{.Mime}}<br />charset: {{.Charset}}<br />via: {{.Via}}<br />forwarded: {{.Forwarded}}<br /></td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/all.xml</td><td class="cli_arrow">&rArr;</td><td><pre style="white-space:pre-wrap;overflow-wrap:anywhere">{{.XMLExample}}</pre></td></tr>
          <tr><td class="cli_command">$ curl ifconfig.tw/all.json</td><td class="cli_arrow">&rArr;</td><td><pre style="white-space:pre-wrap;overflow-wrap:anywhere">{{.JSONExample}}</pre></td></tr>
        </table>
      </div>
      <div id="footer">&copy; 2016 <a href="https://ifconfig.tw">ifconfig.tw</a></div>
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
