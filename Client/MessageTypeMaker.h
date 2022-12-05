/* Description:
 The MessageTypeMaker object is responsible for:
   - Defining the different message types
   - Providing setup service for messages
*/

#import <Foundation/Foundation.h>

// User interface command codes
#define SEND 1
#define RETRIEVE 2
#define QUIT 3

// Structures of messages being exchanged.
typedef struct {
    mach_msg_header_t header;
    mach_msg_size_t msgh_descriptors_count;
    mach_msg_port_descriptor_t port_descriptor;
} Notification;

typedef struct {
    mach_msg_header_t header;
    mach_msg_size_t msgh_descriptors_count;
    mach_msg_port_descriptor_t port_descriptor;
    mach_msg_ool_descriptor_t ool_descriptor;
} OOLMessage;

typedef struct {
    OOLMessage ool_message;
    mach_msg_trailer_t trailer;
} OOLMessageReceive;

@interface MessageTypeMaker : NSObject

+ (void) setupSendMessge:(NSNumber*) data message:(OOLMessage*) message localPort:(mach_port_t) localPort remotePort:(mach_port_t) remotePort; // Sets up all of the message metadata for send.
+ (void) setupReadyNotification:(Notification*) message localPort:(mach_port_t) localPort remotePort:(mach_port_t) remotePort; // Sets up all of the message metadata for a notification operation.

@end

