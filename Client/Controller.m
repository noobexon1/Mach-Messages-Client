#import "Controller.h"

@implementation Controller

- (id) init {
    self = [super init];
    if (self) {
        _commandsMap = @{@"1" : @"send", @"2" : @"retrieve", @"3" : @"quit"};
        _portHandler = [[PortsHandler alloc] init];
        _authenticator = [[Authenticator alloc] init];
    }
    return self;
}

- (NSInteger) promptUserForCommand {
    printf("Please choose a command (enter digit only):\n");
    [_commandsMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        printf("(%d) %s\n", [key intValue], [obj UTF8String]);
    }];
    NSInteger commandNumber = getchar() - '0';
    fflush(stdin); // To clean the new-line character entered by the user from stdin.
    return commandNumber;
}

- (void) proccesCommmand:(NSInteger)command {
    if (command == SEND) {
        [self send];
    } else if (command == RETRIEVE) {
        [self retrieve];
    } else if (command == QUIT) {
        [self quit];
    } else {
        printf("\n[ERROR]: Invalid command number. Please try again.\n\n");
    }
}

- (void) send {
    void* C_data = NULL;
       
    // Allocate vm for user's data.
    kern_return_t result = vm_allocate(mach_task_self(), (vm_address_t*)&C_data, vm_page_size, VM_PROT_READ | VM_PROT_WRITE);
    if (result != KERN_SUCCESS) {
        printf("\n[ERROR]: Failed to allocate virtual memory page for user's data. 0x%x\n", result);
        exit(1);
    }
    
    NSNumber* data = [NSNumber numberWithUnsignedLong:(unsigned long) C_data];
    OOLMessage message = {0};
    
    [self setupUserData:data];
    [MessageTypeMaker setupSendMessge:data message:&message localPort:[_portHandler localPort] remotePort:[_portHandler remotePort]];
    [_authenticator generateAndStoreSHA256:[NSString stringWithUTF8String: message.ool_descriptor.address]]; // To be used later for data's integrity authentication.
                
    result = mach_msg(
            &message.header,                // msg;
            MACH_SEND_MSG,                  // option;
            sizeof(message),                // send_size;
            0,                              // receive_limit;
            MACH_PORT_NULL,                 // receive_name;
            MACH_MSG_TIMEOUT_NONE,          // timeout;
            MACH_PORT_NULL                  // notify;
        );
    
    if (result != KERN_SUCCESS) {
        printf("\n[ERROR]: Message sending failed with error 0x%x\n", result);
        exit(1);
    }
    printf("\n[CLIENT]: Data was sent to be stored via bootstrap port %u.\n\n", [_portHandler remotePort]);
}

- (void) setupUserData:(NSNumber*) data {
    printf("Please type your data (max 1000 ch):\n");
    char input[INPUT_SIZE];
    fgets(input, INPUT_SIZE, stdin);
    strcpy([data pointerValue], input);
}

- (void) retrieve {
    if ([[_authenticator signatures] count] == 0) {
        printf("\n[ERROR]: You have no messages stored yet. Send something to the server first.\n\n");
    } else {
        OOLMessageReceive message = {0};
        [self notifyReady];
        
        printf("[CLIENT]: Waiting for the requested message to arrive in the message queue...\n");
        mach_msg_return_t result = mach_msg(
                &message.ool_message.header,     // msg;
                MACH_RCV_MSG,                    // option;
                0,                               // send_size;
                sizeof(message),                 // receive_limit;
                [_portHandler localPort],        // receive_name;
                MACH_MSG_TIMEOUT_NONE,           // timeout;
                MACH_PORT_NULL                   // notify;
            );
        
        if (result != KERN_SUCCESS) {
            printf("\n[ERROR]: Could not receive a message. error 0x%x\n", result);
            exit(1);
        }
        printf("[CLIENT]: New message arrived in the queue.");

        NSString* freshDataSignature = [_authenticator generateSHA256:[NSString stringWithUTF8String:message.ool_message.ool_descriptor.address]];
        [_authenticator authenticate:freshDataSignature];
        printf("\n[CLIENT]: Message data:\n%s\n", (char*) message.ool_message.ool_descriptor.address);
    }
}

- (void) notifyReady {
    printf("\n[CLIENT]: Notifying the server of retrievel request...\n");
    Notification message = {0};
    [MessageTypeMaker setupReadyNotification:&message localPort:[_portHandler localPort] remotePort:[_portHandler remotePort]];
    
    mach_msg_return_t result = mach_msg(
            &message.header,              // msg;
            MACH_SEND_MSG,                // option;
            sizeof(message),              // send_size;
            0,                            // receive_limit;
            MACH_PORT_NULL,               // receive_name;
            MACH_MSG_TIMEOUT_NONE,        // timeout;
            MACH_PORT_NULL                // notify;
        );
    
    if (result != KERN_SUCCESS) {
        printf("\n[ERROR]: Message sending failed with error 0x%x\n", result);
        exit(1);
    }
    printf("[CLIENT]: Notification sent to bootstrap server port %u.\n", [_portHandler remotePort]);
}

- (void) quit {
    printf("\nClosing client...\n");
    exit(0);
}

@end
