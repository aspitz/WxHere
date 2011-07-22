//
//  CurrentConditionsDataModel.m
//  WxHere
//
//  Created by Ayal Spitz on 10/25/09.
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

#import "CurrentConditionsDataModel.h"
#import "GPSDataModel.h"
#import "ICAOList.h"
#import "DDXML.h"
#import <CoreLocation/CoreLocation.h>
#import "WxHereAppDelegate.h"

@implementation CurrentConditionsDataModel
@synthesize icao;
@synthesize location, temperature, condition;
@synthesize conditionImage;

- (id)init{
	self = [super init];
	if (self != nil) {
		icaoList = [[ICAOList alloc]init];

		NSString *filePath = nil;

		filePath = [[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"];
		categoryToImageDictionary = [[NSDictionary alloc]initWithContentsOfFile:filePath];
		
		filePath = [[NSBundle mainBundle] pathForResource:@"Weather" ofType:@"plist"];
		conditionToCategoryDictionary = [[NSDictionary alloc]initWithContentsOfFile:filePath];
	}
	return self;
}

- (void) dealloc{
	[icaoList release];
	[icao release];
	[temperature release];
	[condition release];
	[conditionImage release];

	[categoryToImageDictionary release];
	[conditionToCategoryDictionary release];
	
	[super dealloc];
}

- (void)update:(id)dataModel{
	[super update:dataModel];

	GPSDataModel *gpsDataModel = dataModel;
	
	self.icao = [icaoList closestICAOtoLat:gpsDataModel.location.coordinate.latitude
									   Lon:gpsDataModel.location.coordinate.longitude];
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://www.weather.gov/xml/current_obs/%@.xml", self.icao];
	DLog(@"%@", urlString);
	[self connect:urlString];
		
	[urlString release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSError *error = nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:self.receivedData options:0 error:&error];
	if (error){
		[xmlDoc release];
		[self bubbleUpError:@"CurrentConditionsDataModelErrorDomain" code:0 errorString:@"Unable to extract data"];
		//[self handleError:error];
		return;
	}
	DDXMLElement *rootElement = [xmlDoc rootElement];
	
	DLog(@"%@",xmlDoc);
	NSArray *elements = [rootElement elementsForName:@"location"];
	if ([elements count] == 0){
		[xmlDoc release];
		[self bubbleUpError:@"CurrentConditionsDataModelErrorDomain" code:1 errorString:@"Unable to extract data"];
		return;
	}
	self.location = [[elements objectAtIndex:0] stringValue];
	
	elements = [rootElement elementsForName:@"temp_f"];
	if ([elements count] == 0){
		[xmlDoc release];
		[self bubbleUpError:@"CurrentConditionsDataModelErrorDomain" code:2 errorString:@"Unable to extract data"];
		return;
	}
	self.temperature = [[elements objectAtIndex:0] stringValue];
	self.temperature = [self.temperature substringToIndex:([self.temperature length] - 2)];

	elements = [rootElement elementsForName:@"weather"];
	if ([elements count] == 0){
		[xmlDoc release];
		[self bubbleUpError:@"CurrentConditionsDataModelErrorDomain" code:3 errorString:@"Unable to extract data"];
		return;
	}
	self.condition = [[elements objectAtIndex:0] stringValue];
	DLog(@"Current condition: %@", self.condition);
	NSString *category = [conditionToCategoryDictionary objectForKey:self.condition];
	DLog(@"Current condition category: %@", category);
	NSString *imageName = [categoryToImageDictionary objectForKey:category];
	DLog(@"Current condition image: %@", imageName);
	self.conditionImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	
	self.state = Updated;
	
	[xmlDoc release];
	[super connectionDidFinishLoading:connection];
}

#pragma mark -

- (void)refresh{
	[super refresh];
	self.icao = nil;
	self.location = nil;
	self.temperature = nil;
	self.condition = nil;
	self.conditionImage = nil;
}

@end
