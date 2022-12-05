#import "Controller.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf("[CLIENT]: Initializing...\n");
        Controller* controller = [[Controller alloc] init];

        while (1) {
            NSInteger command = [controller promptUserForCommand];
            [controller proccesCommmand:command];
        }
    }
    return 0;
}
