//
//  WebSocket
// 
//
//  Created by Remy Sharp based on GapSocket by Jesse MacFadyen
//  Copyright 2010 Left Logic. All rights reserved.
//
//

#import "WebSocketCommand.h"

NSString* const WebSocketErrorDomain = @"WebSocketErrorDomain";
NSString* const WebSocketException = @"WebSocketException";

enum {
    WebSocketTagHandshake = 0,
    WebSocketTagMessage = 1
};

@implementation WebSocketCommand

-(id)initWithWebView:(UIWebView *)theWebView
{
	if((self = (WebSocketCommand*)[super initWithWebView:theWebView]))	
	{
		connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
	}
	return self;
	
}

- (void) connect:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{	
	NSUInteger argc = [arguments count];
	if(argc > 1)
	{
		NSString* urlString = [arguments objectAtIndex:0];
		NSString* userData = [arguments objectAtIndex:1];
		
		NSURL* url = [[NSURL URLWithString:urlString] retain];
    if (![url.scheme isEqualToString:@"ws"]) {
        [NSException raise:WebSocketException format:[NSString stringWithFormat:@"Unsupported protocol %@",url.scheme]];
    }
		
		AsyncSocket* socket = [[AsyncSocket alloc] initWithDelegate:self userData:[userData longLongValue]];
		NSError* err;
		BOOL succ = [ socket connectToHost:url.host onPort:[url.port intValue] withTimeout:5 error:&err];
    
		if(succ)
		{

		}
		else 
		{
			NSString* jsString = [[NSString alloc] initWithFormat:@"WebSocket.__onError(\"%@\");",[err localizedDescription] ];
			[webView stringByEvaluatingJavaScriptFromString:jsString];
			[jsString release];
		}
		
	}
	else 
	{
		// FATAL
		return; 
	}

}

- (void) close:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{	
	// TODO: add a forceDisconnect param, otherwise we continue any read/write ops that are in progress before the close
	NSUInteger argc = [arguments count];
	
	if(argc > 0)
	{
		NSString* userData = [arguments objectAtIndex:0];
		int socketCount = [connectedSockets count];
		for(int x = 0; x < socketCount; x++)
		{
			AsyncSocket* sock = (AsyncSocket*)[connectedSockets objectAtIndex:x];
			if([ sock userData] == [userData longLongValue])
			{
				[sock disconnectAfterReadingAndWriting];
				break;
			}
		}
	}
		
}

- (void) send:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	NSUInteger argc = [arguments count];
	
	if(argc > 0)
	{
		NSString* userData = [arguments objectAtIndex:0];
		
		if(argc > 1)
		{
			NSString* message = [arguments objectAtIndex:1];
			BOOL foundSocket = NO;
			int socketCount = [connectedSockets count];
			for(int x = 0; x < socketCount; x++)
			{
				AsyncSocket* sock = (AsyncSocket*)[connectedSockets objectAtIndex:x];
				if([ sock userData] == [userData longLongValue])
				{
          // NSData *msgData = [message dataUsingEncoding:NSUTF8StringEncoding];
					NSMutableData* data = [NSMutableData data];
          [data appendBytes:"\x00" length:1];
          [data appendData:[message dataUsingEncoding:NSUTF8StringEncoding]];
          [data appendBytes:"\xFF" length:1];
          [sock writeData:data withTimeout:-1 tag:WebSocketTagMessage];
					foundSocket = YES;
					break;
				}
			}
		}
		else 
		{
			NSString* err = [NSString stringWithFormat:@"Error: Call to WebSocketCommand::send with missing message"];
			NSLog(@"%@",err);
			NSString* jsString = [[NSString alloc] initWithFormat:@"WebSocket.__onError(\"%d\",\"%@\");",userData,err ];
			[webView stringByEvaluatingJavaScriptFromString:jsString];
			[jsString release];
			[ err release ];
		}
	}
	else {
		NSLog(@"Call to WebSocketCommand::send with NO arguments!");
	}


		
}

/**
 * In the event of an error, the socket is closed.
 * You may call "unreadData" during this call-back to get the last bit of data off the socket.
 * When connecting, this delegate method may be called
 * before"onSocket:didAcceptNewSocket:" or "onSocket:didConnectToHost:".
 **/
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
  NSLog(@"Disconnecting due to socket error");
	NSString* jsString = [[NSString alloc] initWithFormat:@"WebSocket.__onError(\"%d\",\"%@\");"
						  ,[sock userData]
						  ,[err localizedDescription] ];
	[webView stringByEvaluatingJavaScriptFromString:jsString];
	[jsString release];
}

/**
 * Called when a socket disconnects with or without error.  If you want to release a socket after it disconnects,
 * do so here. It is not safe to do that during "onSocket:willDisconnectWithError:".
 * 
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * this delegate method will be called before the disconnect method returns.
 **/
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	[connectedSockets removeObject:sock];
	NSString* jsString = [[NSString alloc] initWithFormat:@"WebSocket.__onClosed(\"%d\");",[sock userData] ];
	[webView stringByEvaluatingJavaScriptFromString:jsString];
	[jsString release];
}

/**
 * Called when a socket accepts a connection.  Another socket is spawned to handle it. The new socket will have
 * the same delegate and will call "onSocket:didConnectToHost:port:".
 **/
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	[connectedSockets addObject:newSocket];
}

/**
 * Called when a socket is about to connect. This method should return YES to continue, or NO to abort.
 * If aborted, will result in AsyncSocketCanceledError.
 * 
 * If the connectToHost:onPort:error: method was called, the delegate will be able to access and configure the
 * CFReadStream and CFWriteStream as desired prior to connection.
 *
 * If the connectToAddress:error: method was called, the delegate will be able to access and configure the
 * CFSocket and CFSocketNativeHandle (BSD socket) as desired prior to connection. You will be able to access and
 * configure the CFReadStream and CFWriteStream in the onSocket:didConnectToHost:port: method.
 **/
- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
	return YES;
}

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
  NSString* requestOrigin = [NSString stringWithFormat:@"http://localhost"]; // set to localhost rather than host var
  
  NSString *requestPath = @"/"; // FIXME total hack
  // if (url.query) {
  //   requestPath = [requestPath stringByAppendingFormat:@"?%@", url.query];
  // }
  NSString* getRequest = [NSString stringWithFormat:@"GET %@ HTTP/1.1\r\n"
                                                     "Upgrade: WebSocket\r\n"
                                                     "Connection: Upgrade\r\n"
                                                     "Host: %@\r\n"
                                                     "Origin: %@\r\n"
                                                     "\r\n",
                                                      requestPath,host,requestOrigin];
  [sock writeData:[getRequest dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:WebSocketTagHandshake];

	// but we're not open yet...
	[connectedSockets addObject:sock];
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
  if (tag == WebSocketTagHandshake) {
      NSString* response = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
      if ([response hasPrefix:@"HTTP/1.1 101 Web Socket Protocol Handshake\r\nUpgrade: WebSocket\r\nConnection: Upgrade\r\n"]) {
          NSString* jsString = [[NSString alloc] initWithFormat:@"WebSocket.__onOpen(\"%d\");",[sock userData] ];        	
        	[webView stringByEvaluatingJavaScriptFromString:jsString];
        	[jsString release];
          
          [sock readDataToData:[NSData dataWithBytes:"\xFF" length:1] withTimeout:-1 tag:WebSocketTagMessage];
      } else {
          // TODO fix onError to match real error codes
      		NSString* jsString = [[NSString alloc] initWithFormat:@"WebSocket.__onError(\"%d\",\"%@\");",[sock userData] , @"Error could not complete handshake" ];
      		[webView stringByEvaluatingJavaScriptFromString:jsString];
      		[jsString release];
      }
  } else if (tag == WebSocketTagMessage) {
      char firstByte = 0xFF;
      [data getBytes:&firstByte length:1];
      if (firstByte != 0x00) return; // Discard message
      NSString* msg = [[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(1, [data length]-2)] encoding:NSUTF8StringEncoding] autorelease];
  
    	if(msg)
    	{
    	  // needs to escape to be able to pass strings back to the PhoneGap WebSocket
    	  NSString *escaped = [msg stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        
    		NSString* jsString = [[NSString alloc] initWithFormat:@"WebSocket.__onMessage(\"%d\",\"%@\");",[sock userData] , escaped ];

    		[webView stringByEvaluatingJavaScriptFromString:jsString];
    		[jsString release];
    	}
    	else
    	{
    		NSLog(@"Error converting received data into UTF-8 String");
    		NSString* jsString = [[NSString alloc] initWithFormat:@"WebSocket.__onError(\"%d\",\"%@\");",[sock userData] , @"Error converting received data into UTF-8 String" ];
    		[webView stringByEvaluatingJavaScriptFromString:jsString];
    		[jsString release];
    	}

      [sock readDataToData:[NSData dataWithBytes:"\xFF" length:1] withTimeout:-1 tag:WebSocketTagMessage];
  }
}

/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(CFIndex)partialLength tag:(long)tag
{
	
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	if (tag == WebSocketTagHandshake) {
      [sock readDataToData:[@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:WebSocketTagHandshake];
  }
}

/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(CFIndex)partialLength tag:(long)tag
{
	
}

/**
 * Called if a read operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the read's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the read will timeout as usual.
 * 
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been read so far for the read operation.
 * 
 * Note that this method may be called multiple times for a single read if you return positive numbers.
 **/
/*
- (NSTimeInterval)onSocket:(AsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
				   elapsed:(NSTimeInterval)elapsed
				 bytesDone:(CFIndex)length;
 */

/**
 * Called if a write operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the write will timeout as usual.
 * 
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been written so far for the write operation.
 * 
 * Note that this method may be called multiple times for a single write if you return positive numbers.
 **/
/*
- (NSTimeInterval)onSocket:(AsyncSocket *)sock
 shouldTimeoutWriteWithTag:(long)tag
				   elapsed:(NSTimeInterval)elapsed
				 bytesDone:(CFIndex)length;
 */

/**
 * Called after the socket has successfully completed SSL/TLS negotiation.
 * This method is not called unless you use the provided startTLS method.
 * 
 * If a SSL/TLS negotiation fails (invalid certificate, etc) then the socket will immediately close,
 * and the onSocket:willDisconnectWithError: delegate method will be called with the specific SSL error code.
 **/
- (void)onSocketDidSecure:(AsyncSocket *)sock
{
	
}

@end
