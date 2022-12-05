/* Description:
 The Controller object is responsible for:
   - Managing the user's I/O.
   - Proccesing the user's commands, including sending/retreiving of messages and ending the proccess.
   - Using the Authenticator services to validate the data of the exchanged messsages.
*/

#import "PortsHandler.h"
#import "Authenticator.h"
#import "MessageTypeMaker.h"

// imput size constraints.
#define INPUT_SIZE 512 

@interface Controller : NSObject

@property(readonly) NSDictionary* commandsMap; // A map from command's op-code to its name.
@property(readonly) PortsHandler* portHandler; // Provides access to the client and server ports.
@property(readonly) Authenticator* authenticator; // Provides access to data authentication service.

- (NSInteger) promptUserForCommand; // Present user with available commands and prompts for input.
- (void) proccesCommmand:(NSInteger)command; // Procces command based on user's input.
- (void) send; // Sends a message to be stored on the server.
- (void) setupUserData:(NSNumber*) data; // prompt user for data.
- (void) retrieve; // Receive a message (-blocking-).
- (void) notifyReady; // Sends a message to the server, notifying it that the client is ready to receive.
- (void) quit; // Quit the client per user's request

@end


