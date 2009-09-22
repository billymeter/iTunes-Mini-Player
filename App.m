//
//  App.m
//  iTunesMini
//
//  Created by Brad Trotter on 15 Sep 2009.
//  
//	I am no Cocoa expert and still learning alot, so many things that I did here are 
//	probably not very correct. If you feel like you need to fix some of this stuff,
//	please be my guest.
//
//
//  Copyright (c) 2009, Brad Trotter
//  All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are 
//  permitted provided that the following conditions are met:
//  •	Redistributions of source code must retain the above copyright notice, this 
//		list of conditions and the following disclaimer.
//  •	Redistributions in binary form must reproduce the above copyright notice, this 
//		list of conditions and the following disclaimer in the documentation and/or other 
//		materials provided with the distribution.
//  •	Neither the name of Brad Trotter nor the names of its contributors may be used to 
//		endorse or promote products derived from this software without specific prior written 
//		permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
//  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "App.h"

@implementation App

-(void)awakeFromNib {
	
	// Using the ScriptingBridge, create an ITWindow from the iTines Bundle ID
	iTunesApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
	
	iTunesRunning = NO;
	// Checks to see if iTunes is running
	[self checkiTunes:nil];
	
	// Create a statusbar icon
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	NSBundle *bundle = [NSBundle mainBundle];
	NSImage *icon = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"itmp" ofType:@"tiff"]];
	[statusItem setImage:icon];
	[statusItem setHighlightMode:YES];
	[statusItem setTitle:@""];
	[statusItem setEnabled:YES];
	[icon release];
	
	// Set the menu for the status bar icon
	[statusItem setMenu:menu];
}


-(void)checkiTunes:(NSTimer *)tr {
	// If iTunes is running, create a timer that checks to see if iTunes zoom button was pressed
	if([iTunesApp isRunning]) {
		timer = [[NSTimer scheduledTimerWithTimeInterval:0.01
												  target:self
												selector:@selector(checkZoomStatus:)
												userInfo:nil
												 repeats:YES] retain];
		// Used to kill the other timer
		iTunesRunning = YES;
	}
	
	if(iTunesRunning){
		// iTunes is running, so we can destory the timer checking to see if iTunes is running
		[iTunesCheckTimer invalidate];
		[iTunesCheckTimer release];
		iTunesCheckTimer = nil;
	}
	
	// iTunes is not running
	if(!iTunesRunning){
		// Create a timer that will check to see if iTunes is running
		iTunesCheckTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0
															 target:self
														   selector:@selector(checkiTunes:)
														   userInfo:nil
															repeats:YES] retain];
	}
	
	}

//
// -showAboutPanel:
//

-(IBAction)showAboutPanel:(id)sender {
	// Show the about panel, I don't know why I can't get the window to steal focus 
	// from other apps. Oh well, not important.
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:sender];
}


//
// -dealloc
//

-(void)dealloc {
	// Release objects that were created
	[statusItem release];
	[timer invalidate];
	[timer release];
	[super dealloc];
}

//
// -checkZoomStatus:
//

-(void)checkZoomStatus:(NSTimer *)tr {
	// Found a lot of this stuff using F-Script, so if you don't know where I got some of this,
	// load up F-Script and browse through the iTunes classes.
	
	// the "windows" message returns a SBElementArray type with all open iTunes windows
	NSArray *iTunesWindows = [iTunesApp windows];
	// the browserWindows also returns a SBElementArray. Not quite sure what the difference
	// between this and "windows" is, but browserWindows has a method to switch to the mini player
	// which is why it's being used here
	NSArray *iTunesBrowserWindows = [iTunesApp browserWindows];
	
	// the first object is the main iTunes window
	ITWindow *mainWindow = [iTunesWindows objectAtIndex:0];
	// again, not sure what the difference is, but it has the setMinimized: method, which is the mini player
	ITBrowserWindow *browserWindow = [iTunesBrowserWindows objectAtIndex:0];
	
	// check for iTunes "zoomed" state
	int isITZoomed = [mainWindow zoomed];
	
	// attempt to keep the iTunes window from becoming the larger "zoomed" window size, not sure if it
	// works very well
	NSRect iTunesBounds = [mainWindow bounds];
	
	// asuming that if iTunes is in the "zoomed" state, the user clicked the zoom button
	if(isITZoomed) {
		// tell iTunes that it is not in the "zoomed" state
		[mainWindow setZoomed:NO];
		// attempt to restore the "pre-zoomed" window size
		[mainWindow setBounds:iTunesBounds];
		// toggle the miniplayer
		[browserWindow setMinimized:YES];
	}
	
}
@end
