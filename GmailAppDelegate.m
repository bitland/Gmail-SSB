//
//  GmailAppDelegate.m
//  Gmail
//
//  Created by Tyler Hall on 8/26/10.
//  Copyright 2010 Click On Tyler, LLC. All rights reserved.
//

#import "GmailAppDelegate.h"
#import "GmailWindowController.h"

@implementation GmailAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingCall:) name:@"INCOMING_CALL" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingVideo:) name:@"INCOMING_VIDEO" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingChat:) name:@"INCOMING_CHAT" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unreadCountChanged:) name:@"UNREAD_COUNT_CHANGED" object:nil];
	
//	NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
//	NSMenu *editMenu = [[mainMenu itemWithTitle:@"Edit"] submenu];
//	NSMenu *spellingMenu = [[editMenu itemWithTitle:@"Spelling and Grammar"] submenu];
//	NSMenuItem *autoSpellingMenuItem = [spellingMenu itemWithTitle:@"Check Spelling While Typing"];
//	[autoSpellingMenuItem setEnabled:YES];
	
	mainWindowController = [[GmailWindowController alloc] initWithWindowNibName:@"GmailWindow"];
	[mainWindowController showWindow:self];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
	[self showMainWindow:self];
	return NO;
}

- (IBAction)showMainWindow:(id)sender {
	[[mainWindowController window] setIsVisible:YES];
}

- (void)incomingCall:(NSNotification *)notification {
	[NSApp requestUserAttention:NSCriticalRequest];
	
	if(voiceBounce) {
		NSData *iconData = [[NSImage imageNamed:@"Icon"] TIFFRepresentation];
		[[Growler sharedGrowler] growlWithTitle:@"Incoming Voice Call"
									description:@"You have an incoming Gmail voice call."
							   notificationName:@"Incoming Voice Call" 
									   iconData:iconData 
										context:@"call"];
		voiceBounce = NO;
	}
}

- (void)incomingVideo:(NSNotification *)notification {
	[NSApp requestUserAttention:NSCriticalRequest];

	if(videoBounce) {
		NSData *iconData = [[NSImage imageNamed:@"Icon"] TIFFRepresentation];
		[[Growler sharedGrowler] growlWithTitle:@"Incoming Video Call"
									description:@"You have an incoming Gmail video call."
							   notificationName:@"Incoming Video Call"
									   iconData:iconData 
										context:@"video"];
		videoBounce = NO;
	}
}

- (void)incomingChat:(NSNotification *)notification {
	if(![NSApp isActive] && chatBounce) {
		[NSApp requestUserAttention:NSInformationalRequest];
		NSData *iconData = [[NSImage imageNamed:@"Icon"] TIFFRepresentation];
		[[Growler sharedGrowler] growlWithTitle:@"New Chat Message"
									description:@"You have a new Google Talk message."
							   notificationName:@"New Chat Message"
									   iconData:iconData 
										context:@"chat"];
		chatBounce = NO;
	}
}

- (void)unreadCountChanged:(NSNotification *)notification {
	if([notification userInfo] == nil) {
		[[NSApp dockTile] setBadgeLabel:@""];
	} else {		
		int count = [[[notification userInfo] valueForKey:@"count"] intValue];
		if(count == 0)
			[[NSApp dockTile] setBadgeLabel:@""];
		else
			[[NSApp dockTile] setBadgeLabel:[NSString stringWithFormat:@"%d", count]];
	}
	
}

- (void)overlayImageNamed:(NSString *)imageName {
	float size = [[NSApp dockTile] size].width * .5;
	float offset = [[NSApp dockTile] size].width - size;
	
	NSImage *overlay = [NSImage imageNamed:@"phone"];
	NSImage *icon = [NSApp applicationIconImage];
	[icon lockFocus];
	CGContextRef ctxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGImageSourceRef source;
	source = CGImageSourceCreateWithData((CFDataRef)[overlay TIFFRepresentation], NULL);
	CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
	CGContextDrawImage(ctxt, NSMakeRect(offset, offset, size, size), maskRef);
	[icon unlockFocus];
	[NSApp setApplicationIconImage:icon];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
	[NSApp setApplicationIconImage:[NSImage imageNamed:@"Icon"]];
	voiceBounce = YES;
	videoBounce = YES;
	chatBounce = YES;
}

@end
