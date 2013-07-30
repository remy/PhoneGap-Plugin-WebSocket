# WebSocket PhoneGap iPhone Plugin

**NOTE: this plugin is no longer required as iOS provides native WebSockets to PhoneGap as of iOS v4 - some moons ago, so you don't need this project any more**.

I'm just leaving this here for historical purposes.

## Usage

* Copy WebSocketCommand.m/h to your project.
* Copy websocket.js to your www directory.

Then use the WebSocket as according to [the specification](http://dev.w3.org/html5/websockets/).

## Known issues & untested cases

This list might be bigger than I think - but here's what I can think of:

- Doesn't support paths on ws urls, i.e. ws://example.com:8000 works, but ws://example.com/myapp:8000 won't
- I've not tested multiple sockets at all - I'm not sure what will happen
- I don't think the socket is being disconnected on exit. I would expect the app to release the socket, but on my server side I wasn't seeing the sockets being released - kinda worrying...though it might just be that I missed that.

## Credit

This was <del>written</del> hacked by me, by using the code from [cocoa-websocket](http://github.com/erichocean/cocoa-websocket) and the code from [GapSocket](http://github.com/purplecabbage/PhoneGap-Plugins/tree/master/GapSocket/).

I don't know how to write Objective-C so if this is a complete mess, I blame laziness entirely.
