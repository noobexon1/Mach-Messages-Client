#import "Authenticator.h"

@implementation Authenticator

- (id) init {
    self = [super init];
    if (self) {
        _signatures = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString*) generateAndStoreSHA256:(NSString*) input {
    printf("\n[CLIENT]: Encrypting data...");
    NSData* data = [input dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *sha256Data = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([data bytes], (CC_LONG)[data length], [sha256Data mutableBytes]);
    [_signatures addObject:[sha256Data base64EncodedStringWithOptions:0]];
    printf("\n[CLIENT]: Data was encrypted and stored with signature: %s", [[_signatures lastObject] UTF8String]);
    return [sha256Data base64EncodedStringWithOptions:0];
}

- (NSString*) generateSHA256:(NSString*) input {
    NSData* data = [input dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *sha256Data = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([data bytes], (CC_LONG)[data length], [sha256Data mutableBytes]);
    return [sha256Data base64EncodedStringWithOptions:0];
}

- (void) authenticate:(NSString*) freshSignature {
    NSString* signature = [_signatures firstObject];
    if ([signature isEqualToString:freshSignature]) {
        printf("\n[CLIENT]: Data integrity was confirmed against signature.");
    } else {
        printf("\n[WARNING]: Message has been tempered with. Data is NOT the same!");
    }
    [_signatures removeObjectAtIndex:0];
}
    
@end
