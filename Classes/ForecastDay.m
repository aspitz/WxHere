//
//  ForecastDay.m
//  WxHere
//
//  Created by Ayal Spitz on 10/30/09.
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

#import "ForecastDay.h"
#import "ForecastPeriod.h"

@implementation ForecastDay
@synthesize name;
@synthesize day;
@synthesize date;
@synthesize periods;

- (id) init{
	self = [super init];
	if (self != nil) {
		self.periods = [[NSMutableDictionary alloc]init];
	}
	return self;
}

- (void) dealloc{
	[name release];
	[periods release];
	[date release];
	[super dealloc];
}

- (ForecastPeriod *)period:(NSInteger)hour{
	NSString *key = [[NSString alloc]initWithFormat:@"%d",hour];
	ForecastPeriod *forecastPeriod = [periods objectForKey:key];
	
	if (forecastPeriod == nil){
		forecastPeriod = [[[ForecastPeriod alloc]init] autorelease];
		[periods setObject:forecastPeriod forKey:key];
	}

	[key release];
	
	return forecastPeriod;
}

NSInteger stringNumberSort(id m1, id m2, void *context){
	return [((NSString*)m1) compare:((NSString*)m2) options:NSNumericSearch];
}

- (ForecastPeriod *)periodAtIndex:(NSInteger)index{
	NSArray *keys = [periods allKeys];
	if (index < keys.count){
		NSArray *sortedKeys = [keys sortedArrayUsingFunction:stringNumberSort context:nil];
		NSString *key = [sortedKeys objectAtIndex:index];
		return [periods objectForKey:key];
	} else {
		return nil;
	}
}

@end
