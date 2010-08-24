(function () {

function WebSocket(url)
{
	// Callback funx
	this.onopen = null;
	this.onmessage = null;
	this.onerror = null;
	this.onclose = null;
	
	this.url = url;
	this.sockId = (++WebSocket.nextIndex);
	
	WebSocket.Sockets[this.sockId] = this;
	this.bufferedAmount = 0;
	this.readyState = WebSocket.CONNECTING;
	
	debug.log(this.sockId);
	
	PhoneGap.exec("WebSocketCommand.connect",this.url,this.sockId);
	
}

WebSocket.CONNECTING	= 0;
WebSocket.OPEN			= 1;
WebSocket.CLOSING		= 2;
WebSocket.CLOSED		= 3;


// Static Callback for ALL sockets
// sockId is used to route to the correct socket
WebSocket.__onOpen = function(sockId)
{
	var sock = WebSocket.Sockets[sockId];
	if(sock != null)
	{
		sock.readyState = WebSocket.OPEN;
		if(sock.onopen != null)
		{
			sock.onopen();
		}
	}
}

// Static Callback for ALL sockets
// sockId is used to route to the correct socket
WebSocket.__onConnecting = function(sockId)
{
	var sock = WebSocket.Sockets[sockId];
	if(sock != null)
	{
		sock.readyState = WebSocket.CONNECTING;
	}
}

// Static Callback for ALL sockets
// sockId is used to route to the correct socket
WebSocket.__onClosing = function(sockId)
{
	var sock = WebSocket.Sockets[sockId];
	if(sock != null)
	{
		sock.readyState = WebSocket.CLOSING;
	}
}

// Static Callback for ALL sockets
// sockId is used to route to the correct socket
WebSocket.__onClosed = function(sockId)
{
	var sock = WebSocket.Sockets[sockId];
	if(sock != null)
	{
		sock.readyState = WebSocket.CLOSED;
		sock.onclose();
		delete WebSocket.Sockets[sock.sockId];
		sock = null;
		
	}
}

// Static Callback for ALL sockets
// sockId is used to route to the correct socket
WebSocket.__onError = function(sockId,errMsg)
{
	var sock = WebSocket.Sockets[sockId];
	if(sock != null)
	{
		sock.onerror(errMsg);
	}
}

// Static Callback for ALL sockets
// sockId is used to route to the correct socket
WebSocket.__onMessage = function(sockId,msg)
{
  debug.log('__onMessage called');
	var sock = WebSocket.Sockets[sockId];
	if(sock != null)
	{
	  debug.log('message: ' + msg);
		sock.onmessage({data:msg});
	} else {
	  debug.log("couldn't find sock for msg [" + msg + "]");
	}
}


WebSocket.Sockets = {};
WebSocket.nextIndex = -1;

WebSocket.prototype.send = function(data)
{
	PhoneGap.exec("WebSocketCommand.send",this.sockId,data + "\r\n");
}

WebSocket.prototype.close = function()
{
	this.readyState = WebSocket.CLOSING;
}

PhoneGap.addConstructor(function() {
    if (typeof window.WebSocket == "undefined") window.WebSocket = WebSocket;
    debug.log('Setup WebSocket');
});

})();