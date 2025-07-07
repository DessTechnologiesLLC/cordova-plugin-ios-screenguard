#import <Cordova/CDV.h>

@interface CDVScreenGuard : CDVPlugin
- (void)enable:(CDVInvokedUrlCommand*)command;
@end

@implementation CDVScreenGuard

- (void)pluginInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenCaptureChanged)
                                                 name:UIScreenCapturedDidChangeNotification
                                               object:nil];
    [self screenCaptureChanged];
}

- (void)enable:(CDVInvokedUrlCommand*)command {
    [self screenCaptureChanged];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                               messageAsString:@"Screen guard enabled"];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)screenCaptureChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        BOOL isCaptured = [UIScreen mainScreen].isCaptured;

        if (isCaptured) {
            if (![window viewWithTag:999]) {
                UIView *overlay = [[UIView alloc] initWithFrame:window.bounds];
                overlay.backgroundColor = [UIColor blackColor];
                overlay.tag = 999;
                overlay.userInteractionEnabled = NO;
                [window addSubview:overlay];
            }
        } else {
            UIView *overlay = [window viewWithTag:999];
            if (overlay) [overlay removeFromSuperview];
        }
    });
}

@end
