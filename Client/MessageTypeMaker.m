#import "MessageTypeMaker.h"

@implementation MessageTypeMaker

+ (void) setupSendMessge:(NSNumber*) data message:(OOLMessage*) message localPort:(mach_port_t) localPort remotePort:(mach_port_t) remotePort{
    // Header:
    message->header.msgh_remote_port = remotePort;
    message->header.msgh_local_port = localPort;
    message->header.msgh_bits = MACH_MSGH_BITS_SET(MACH_MSG_TYPE_COPY_SEND, MACH_MSG_TYPE_MAKE_SEND, 0, MACH_MSGH_BITS_COMPLEX);
    message->header.msgh_id = SEND;
    
    message->msgh_descriptors_count = 2;
    
    // Port descriptor:
    message->port_descriptor.name = localPort;
    message->port_descriptor.type = MACH_MSG_PORT_DESCRIPTOR;
    message->port_descriptor.disposition = MACH_MSG_TYPE_MAKE_SEND;
    
    // OOL descriptor:
    message->ool_descriptor.address = [data pointerValue];
    message->ool_descriptor.size = (mach_msg_size_t) vm_page_size;
    message->ool_descriptor.copy = MACH_MSG_VIRTUAL_COPY;
    message->ool_descriptor.deallocate = true; 
    message->ool_descriptor.type = MACH_MSG_OOL_DESCRIPTOR;
}

+ (void) setupReadyNotification:(Notification*) message localPort:(mach_port_t) localPort remotePort:(mach_port_t) remotePort{
    // Header:
    message->header.msgh_remote_port = remotePort;
    message->header.msgh_local_port = localPort;
    message->header.msgh_bits = MACH_MSGH_BITS_SET(MACH_MSG_TYPE_COPY_SEND, MACH_MSG_TYPE_MAKE_SEND, 0, MACH_MSGH_BITS_COMPLEX);
    message->header.msgh_size = sizeof(message);
    message->header.msgh_id = RETRIEVE;
    
    message->msgh_descriptors_count = 1;
    
    // Port descriptor:
    message->port_descriptor.name = localPort;
    message->port_descriptor.type = MACH_MSG_PORT_DESCRIPTOR;
    message->port_descriptor.disposition = MACH_MSG_TYPE_MAKE_SEND;
}

@end
