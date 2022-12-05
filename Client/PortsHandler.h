/* Description:
 The PortsHandler object is the first to initialize and is responsible for:
   - Allocating and storing a local port for the client and altering its rights.
   - Finding and storing of the remote server's port as named in the bootstrap server	.
 */

#include <stdio.h>
#include <stdlib.h>

#import <Foundation/Foundation.h>
#import <servers/bootstrap.h>
#import <mach/message.h>

@interface PortsHandler : NSObject

@property(readonly) mach_port_t notificationPort; // Used by the server to make sure client is alive.
@property(readonly) mach_port_t localPort; // Stores local port name.
@property(readonly) mach_port_t remotePort; // Stores server port as named in the bootstrap server.

@end

