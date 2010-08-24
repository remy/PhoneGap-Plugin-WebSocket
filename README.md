# WebSocket PhoneGap iPhone Plugin

PLEASE NOTE: these are early days - the initial plugin works, but it's not been tested very thoroughly yet - please help me test and make this plugin better.

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


The MIT License

Copyright (c) 2010 Remy Sharp

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
