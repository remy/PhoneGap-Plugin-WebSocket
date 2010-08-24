//
//  WebSocket
// 
//
//  Created by Remy Sharp
//  Copyright 2010 Left Logic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneGapCommand.h"
#import "AsyncSocket.h"

 
@interface WebSocketCommand : PhoneGapCommand  {

	NSMutableArray *connectedSockets;
}

- (void) connect:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) close:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) send:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
