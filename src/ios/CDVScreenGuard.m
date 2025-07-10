#import <Cordova/CDV.h>

@interface CDVScreenGuard : CDVPlugin
@property (nonatomic, strong) UIView *overlayView;
@end

@implementation CDVScreenGuard

- (void)pluginInitialize {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(screenCaptureChanged)
                                                 name:UIScreenCapturedDidChangeNotification
                                               object:nil];
    [self screenCaptureChanged];
}

- (void)screenCaptureChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isCaptured = [UIScreen mainScreen].isCaptured;

        UIWindow *mainWindow = [UIApplication sharedApplication].windows.firstObject;

        if (isCaptured) {
            if (!self.overlayView) {
                self.overlayView = [[UIView alloc] initWithFrame:mainWindow.bounds];
                self.overlayView.backgroundColor = [UIColor blackColor];
                self.overlayView.tag = 999;
                self.overlayView.userInteractionEnabled = NO;
                [mainWindow addSubview:self.overlayView];
            }
        } else {
            if (self.overlayView) {
                [self.overlayView removeFromSuperview];
                self.overlayView = nil;
            }
        }
    });
}

- (void)enable:(CDVInvokedUrlCommand*)command {
    [self screenCaptureChanged];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:@"Screen guard enabled"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
