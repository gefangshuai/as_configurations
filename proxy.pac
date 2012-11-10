//function FindProxyForURL(url, host) { return "PROXY 192.168.0.101:3128; PROXY 192.168.0.102:3128; DIRECT"; }

function FindProxyForURL(url, host)
{
	//over gfw
	if(dnsDomainIs(host, ".facebook.com")){
		//return "PROXY 77.79.12.137:1031";
		 return "DIRECT; PROXY 192.168.0.105:3128; PROXY 77.79.12.137:1031";
	}
  //woyo
  else if (isInNet(myIpAddress(),"192.168.39.0","255.255.255.0")) {
     return "PROXY 192.168.0.105:3128";
  }
  else if (isInNet(myIpAddress(),"192.168.18.0","255.255.255.0")) {
     return "PROXY 192.168.0.105:3128";
  }
  //ashome_default
  else {
		 return "DIRECT; PROXY 192.168.0.105:3128; PROXY 77.79.12.137:1031";
  }
}
