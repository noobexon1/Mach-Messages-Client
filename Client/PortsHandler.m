#import "PortsHandler.h"

@implementation PortsHandler

- (id) init {
    self = [super init];
    if (self) {
        // Look up for the server's port name as registered at the bootstrap server (probably launchd) and store it.
        kern_return_t result = bootstrap_look_up(bootstrap_port, "ima.good.mach.com", &_remotePort);
        if (result != KERN_SUCCESS) {
            printf("[ERROR]: Unable to locate remote server. exit code 0x%x\n", result);
            exit(1);
        }
        printf("[CLIENT]: Found server port at the bootstrap server namespace (probably launchd) by port %u.\n", _remotePort);
        
        // Allocate a new local port in the client's namespace with RECEIVE right.
        result = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &_localPort);
        if (result != KERN_SUCCESS) {
            printf("[ERROR]: Local port \"RECEIVE\" right allocation failed with exit code 0x%x\n", result);
            exit(1);
        }
        printf("[CLIENT]: Local port %u allocated at client's namespace with a \"RECEIVE\" right.\n", _localPort);
        
        // Add a SEND right to the local port created above.
        result = mach_port_insert_right(mach_task_self(), _localPort, _localPort, MACH_MSG_TYPE_MAKE_SEND);
        if (result != KERN_SUCCESS) {
            printf("[ERROR]: Local port %u was not granted SEND right. exit code 0x%x\n", _localPort, result);
            exit(1);
        }
        printf("[CLIENT]: Local port %u was granted \"SEND\" right.\n", _localPort);
    }
    return self;
}

@end
