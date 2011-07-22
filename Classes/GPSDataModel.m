//
//  GPSDataModel.m
//  WxHere
//
//  Created by Ayal Spitz on 7/11/09.
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

#import "GPSDataModel.h"
#import <CoreLocation/CoreLocation.h>
#import "NSUserDefaults-Defaults.h"

@implementation GPSDataModel
@synthesize location;

- (id) init{
	self = [super init];
	if (self != nil) {
		// Read in 'gps_timeout_preference'
		timeout = [[NSUserDefaults standardUserDefaults] integerForKey:@"gps_timeout_preference" defaultValue:10];
		DLog(@"GPS timeout: %d", timeout);
		
		// Read in 'gps_accuracy_preference'
		minAccuracy = [[NSUserDefaults standardUserDefaults] integerForKey:@"gps_accuracy_preference" defaultValue:2500];
		DLog(@"GPS min accuracy: %d", minAccuracy);
	}
	return self;
}

- (void)dealloc{
	[locationManager release];
	[location release];
    [super dealloc];
}


- (void)update:(id)dataModel{
	DLog(@"Start");
	
	[super update:dataModel];
	
	if (locationManager == nil){
		locationManager = [[CLLocationManager alloc] init];
	}
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManager startUpdatingLocation];	

	[self performSelector:@selector(stopLocationManager:) withObject:nil afterDelay:timeout];

	DLog(@"End");
}

- (void)stopLocationManager:(id)sender{
	DLog(@"Start");
	
	if (self.state == Updating){
		self.state = Updated;
		[locationManager stopUpdatingLocation];
		[[self class] cancelPreviousPerformRequestsWithTarget: self];

		self.elapsedTime = [[NSNumber alloc] initWithDouble:fabs([self.startTime timeIntervalSinceNow])];
	}
	
	DLog(@"End");
}

#pragma mark -
#pragma mark CLLocationManagerDelegate Protocol implementation

- (void)locationManager:(CLLocationManager *)locatioManager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation{
	
	DLog(@"Star");
#ifndef DEBUG
	self.location = newLocation;
	DLog(@"%@",self.location);
										   
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
	if (locationAge > 5.0) return;
		
	if (self.location.horizontalAccuracy <= minAccuracy){
		[self stopLocationManager:nil];
	}
#else
	CLLocation *debugLocation = [[CLLocation alloc] initWithLatitude:42.3665
														   longitude:-71.2358];
	self.location = debugLocation;
	[debugLocation release];
	[self stopLocationManager:nil];
#endif
	DLog(@"End");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:@"error"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:self	userInfo:userInfo];
}

- (void)refresh{
	[super refresh];
	[locationManager release];
	locationManager = nil;
	self.location = nil;
}

@end