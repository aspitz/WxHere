//
//  WxAnnotation.m
//  WxHere
//
//  Created by Ayal Spitz on 5/20/09.
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

#import "WxAnnotation.h"
#import "GPSDataModel.h"
#import "CurrentConditionsDataModel.h"

@implementation WxAnnotation

@synthesize coordinate, title, subtitle;


- (id)initWithGPSDataModel:(GPSDataModel *)dataModel{
	self = [super init];
	if(nil != self) {
 		self.title = @"Current Location";
		coordinate = dataModel.location.coordinate;
	}
	return self;
}


- (void)updateCurrentConditions:(CurrentConditionsDataModel *)currentConditions{
	NSMutableString *mutableTitle = [[NSMutableString alloc] init];
	
	if (currentConditions.temperature != nil){
		[mutableTitle appendFormat:@"%@°F", currentConditions.temperature];
	}
	
	if ((currentConditions.temperature != nil) && (currentConditions.condition != nil)){
		[mutableTitle appendString:@" - "];
	}
	if (currentConditions.condition != nil){
		[mutableTitle appendString:currentConditions.condition];
	}
	
	self.title = mutableTitle;
	[mutableTitle release];
}

- (void) dealloc {
	[title release];
	[subtitle release];
	[super dealloc];
}


@end