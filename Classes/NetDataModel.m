//
//  NetDataModel.m
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

#import "NetDataModel.h"


@implementation NetDataModel
@synthesize receivedData, urlRequest, retry;

- (id) init{
	self = [super init];
	if (self != nil) {
		self.receivedData = [[NSMutableData alloc] init];
	}
	return self;
}

- (void) dealloc{
	[urlRequest release];
	[receivedData release];
	[super dealloc];
}

- (void)connect:(NSString *)urlString{
	self.retry = YES;

	NSURL *url = [[NSURL alloc]initWithString:urlString];
	self.urlRequest = [[NSURLRequest alloc] initWithURL:url];
	[self retryConnection];
	[url release];
}

- (void)retryConnection{
	self.startTime = [NSDate date];
	self.receivedData.length = 0;
	
	[[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self startImmediately:YES];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	self.receivedData.length = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[connection release];
	
	if (self.retry){
		self.retry = NO;
		self.receivedData.length = 0;
		[self retryConnection];
	} else {
		state = Error;
		self.receivedData = nil;
		[self handleError:error];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	self.elapsedTime = [NSNumber numberWithDouble:-[self.startTime timeIntervalSinceNow]];
	[connection release];
}

@end
