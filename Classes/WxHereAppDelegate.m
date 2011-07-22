//
//  WxHereAppDelegate.m
//  WxHere
//
//  Created by Ayal Spitz on 5/8/09.
//  Copyright (C) 2009 Ayal Spitz
// 
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//

#import "WxHereAppDelegate.h"
#import "WxDataModel.h"
#import "DataViewController.h"

@implementation WxHereAppDelegate

@synthesize wxDataModel;
@synthesize window;
@synthesize tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[self addNotificationObservers];
	self.wxDataModel = [WxDataModel dataModel];

	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"data_view_preference"]){
		NSMutableArray *viewControllerArray = [NSMutableArray arrayWithArray:tabBarController.viewControllers];
		//DataViewController *viewController = [viewControllerArray objectAtIndex:2];
		//[viewController removeObservers];
		[viewControllerArray removeObjectAtIndex:2];
		tabBarController.viewControllers = viewControllerArray;
	}
		
    // Override point for customization after app launch    
	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
	[self.wxDataModel update:nil];
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[tabBarController release];

	[window release];
	[super dealloc];
}

#pragma mark -
#pragma mark Notification handeling

- (void)addNotificationObservers{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleErrorNotification:) 
												 name:@"error" 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleExceptionNotification:) 
												 name:@"exception" 
											   object:nil];
}

- (void)handleErrorNotification:(NSNotification *)notification{
	DLog(@"%@",notification.object);
	DLog(@"%@",notification.userInfo);
	NSError *error = [notification.userInfo valueForKey:@"error"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error has occured!"
													message:error.localizedDescription
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)handleExceptionNotification:(NSNotification *)notification{
	NSException *exception = [notification.userInfo valueForKey:@"exception"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An exception has occured!"
													message:exception.reason
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}
@end