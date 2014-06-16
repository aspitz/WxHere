//
//  LocationDataModel.m
//  WxHere
//
//  Created by Ayal Spitz on 11/2/09.
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

#import "LocationDataModel.h"
#import "DDXML.h"
#import <CoreLocation/CoreLocation.h>
#import "GPSDataModel.h"

@implementation LocationDataModel
@synthesize location, city, stateAbbr;

- (id)init{
	self = [super init];
	if (self != nil) {}
	return self;
}

- (void) dealloc{
	[location release];
	[city release];
	[stateAbbr release];
	[super dealloc];
}

- (void)update:(id)dataModel{
	[super update:dataModel];
	GPSDataModel *gpsDataModel = dataModel;
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.geonames.org/findNearbyPostalCodes?lat=%f&lng=%f&username=aspitz",
						   gpsDataModel.location.coordinate.latitude,
						   gpsDataModel.location.coordinate.longitude];
	DLog(@"%@", urlString);
	[self connect:urlString];
	
	[urlString release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSError *error = nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:self.receivedData options:0 error:&error];
	if (error){
		[xmlDoc release];
		[self handleError:error];
		return;
	}
	DDXMLElement *rootElement = [xmlDoc rootElement];
	NSArray *elements = [rootElement elementsForName:@"code"];
	if ([elements count] == 0){
		[xmlDoc release];
		[self bubbleUpError:@"LocationDataModelErrorDomain" code:0 errorString:@"Unable to extract data"];
		return;
	}
	DDXMLElement *code = [elements objectAtIndex:0];
	
	elements = [code elementsForName:@"name"];
	if ([elements count] == 0){
		[xmlDoc release];
		[self bubbleUpError:@"LocationDataModelErrorDomain" code:1 errorString:@"Unable to extract data"];
		return;
	}
	self.city = [[elements objectAtIndex:0] stringValue];
	
	elements = [code elementsForName:@"adminCode1"];
	if ([elements count] == 0){
		[xmlDoc release];
		[self bubbleUpError:@"LocationDataModelErrorDomain" code:2 errorString:@"Unable to extract data"];
		return;
	}
	self.stateAbbr = [[elements objectAtIndex:0] stringValue];

	self.location = [[NSString alloc]initWithFormat:@"%@, %@", self.city, self.stateAbbr];
	DLog(@"%@", self.location);
	
	self.state = Updated;
	
	[xmlDoc release];
	[super connectionDidFinishLoading:connection];
}

- (void)refresh{
	[super refresh];
	self.location = nil;
	self.city = nil;
	self.stateAbbr = nil;
}

@end
