//
//  WxDataModel.m
//  WxHere
//
//  Created by Ayal Spitz on 7/31/09.
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

#import "WxDataModel.h"

#import "GPSDataModel.h"
#import "LocationDataModel.h"
#import "CurrentConditionsDataModel.h"
#import "NOAADataModel.h"
#import "HourlyForecastDataModel.h"

@implementation WxDataModel
@synthesize gpsDataModel;
@synthesize locationDataModel;
@synthesize currentConditionsDataModel;
@synthesize noaaDataModel;
//@synthesize hourlyForecastDataModel;

#pragma mark Singelton

static WxDataModel *wxDataModel = nil;

+ (WxDataModel *)dataModel{
	@synchronized(self) {
        if (wxDataModel == nil) {
            wxDataModel = [[self alloc] init]; // assignment not done here
        }
    }

    return wxDataModel;
}

#pragma mark -

- (id) init{
	self = [super init];
	if (self != nil) {
		gpsDataModel = [[GPSDataModel alloc]init];
		locationDataModel = [[LocationDataModel alloc]init];
		currentConditionsDataModel = [[CurrentConditionsDataModel alloc]init];
		noaaDataModel = [[NOAADataModel alloc]init];
		//hourlyForecastDataModel = [[HourlyForecastDataModel alloc]init];
		
		done = 0;
		
		[self addObservers];
	}
	return self;
}

- (void) dealloc{
	[gpsDataModel release];
	[locationDataModel release];
	[currentConditionsDataModel release];
	[noaaDataModel release];
	//[hourlyForecastDataModel release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Notification handeling

- (void)addObservers{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleErrorNotification:) 
												 name:@"error" 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleErrorNotification:) 
												 name:@"exception" 
											   object:nil];


	[self.gpsDataModel addObserver:self forKeyPath:@"state" options:0 context:NULL];
	[self.locationDataModel addObserver:self forKeyPath:@"state" options:0 context:NULL];
	[self.currentConditionsDataModel addObserver:self forKeyPath:@"state" options:0 context:NULL];
	[self.noaaDataModel addObserver:self forKeyPath:@"state" options:0 context:NULL];
	//[self.hourlyForecastDataModel addObserver:self forKeyPath:@"state" options:0 context:NULL];
}

- (void)handleErrorNotification:(NSNotification *)notification{
	self.state = Error;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqual:@"state"]){
		if ([object state] == Error){
			// If the state of one of the sub data models returns an error then
			//  this data model is in error state too
			self.state = Error;
		} else {
			if ([object class] == [GPSDataModel class]){
				if (self.gpsDataModel.state == Updated){
					[self.locationDataModel update:gpsDataModel];
					[self.currentConditionsDataModel update:gpsDataModel];
					[self.noaaDataModel update:gpsDataModel];
					//[self.hourlyForecastDataModel update:gpsDataModel];
				}
			} else if ([object class] == [LocationDataModel class]){
				if (self.locationDataModel.state == Updated){
					done += 1;
				}
			} else if ([object class] == [CurrentConditionsDataModel class]){
				if (self.currentConditionsDataModel.state == Updated){
					done += 2;
				}
			} else if ([object class] == [NOAADataModel class]){
				if (self.noaaDataModel.state == Updated){
					done += 4;
				}
			} else if ([object class] == [NOAADataModel class]){
				if (self.noaaDataModel.state == Updated){
					done += 8;
				}
			}
			
			if (done == 7){
				self.state = Updated;
				self.elapsedTime = [NSNumber numberWithDouble:([self.startTime timeIntervalSinceNow] * -1.0)];
			}
		}
	}
}

#pragma mark -

- (void)update:(id)dataModel{
	[super update:dataModel];
	[self.gpsDataModel update:nil];
}

- (void)refresh{
	[super refresh];
	done = 0;
	
	[gpsDataModel refresh];
	[locationDataModel refresh];
	[currentConditionsDataModel refresh];
	[noaaDataModel refresh];
	//[hourlyForecastDataModel refresh];
	
	[self update:nil];
}

@end