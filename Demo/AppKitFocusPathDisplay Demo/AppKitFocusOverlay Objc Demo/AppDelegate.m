//
//  AppDelegate.m
//  AppKitFocusOverlay Objc Demo
//
//  Created by Darren Ford on 5/1/2022.
//

#import "AppDelegate.h"

@import AppKitFocusOverlay;

@interface AppDelegate ()
@property (nonatomic, strong) AppKitFocusOverlay* focusOverlay;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	AppKitFocusOverlay* focus = [[AppKitFocusOverlay alloc] initWithShouldRecalculateKeyViewLoop: NO];
	[self setFocusOverlay: focus];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
	return YES;
}


@end
