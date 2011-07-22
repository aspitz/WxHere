//
//  BasicDataModel.m
//  WxHere
//
//  Created by Ayal Spitz on 7/13/09.
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

#import "BasicDataModel.h"


@implementation BasicDataModel
@synthesize state;
@synthesize startTime, elapsedTime;


- (id)init{
	self = [super init];
	if (self != nil){ self.state = Neutral; }
	
	return self;
}

- (void) dealloc{
	[startTime release];
	[elapsedTime release];
	[super dealloc];
}

- (void)bubbleUpError:(NSString *)domain code:(NSInteger)code errorString:(NSString *)errorString{
	NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:errorString, NSLocalizedDescriptionKey, nil];
	NSError *error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
	[self handleError:error];
	[userInfo release];
}

- (void)handleError:(NSError *)error{
	self.state = Error;
	NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:error, @"error", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:self	userInfo:userInfo];
	[userInfo release];
}

- (void)handleException:(NSException *)exception{
	self.state = Error;
	NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:exception, @"exception", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"exception" object:self	userInfo:userInfo];
	[userInfo release];
}

- (void)update:(id)dataModel{
	self.startTime = [NSDate date];
	self.state = Updating;
}

- (void)refresh{
	self.state = Neutral;
}

@end
