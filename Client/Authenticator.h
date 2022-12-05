/* Description:
 The Authenticator object provides the following encryption/decryption services to the client's Controller:
   - Generate an encrypted signature for the 'data' field of each message being sent to the server.
   - Store the above signature.
   - Authenticate new messages againt stored data.
*/

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface Authenticator : NSObject

@property(readwrite) NSMutableArray* signatures; // Holds the encrypted messages signatures of the client.

- (NSString*) generateAndStoreSHA256:(NSString*) input; // Generate an encrypted signature for a message and store it.
- (NSString*) generateSHA256:(NSString*) input; // Generate an encrypted signature for a message.
- (void) authenticate:(NSString*) freshSignature; // Authenticate data against cryptographic signature.

@end

