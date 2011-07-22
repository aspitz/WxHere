//
//  URLConnectionHandler.m
//  WxNow
//
//  Created by Ayal Spitz on 5/25/09.
//  Copyright 2009 Ayal Spitz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLConnectionHandler.h"


@implementation URLConnectionHandler
@synthesize receivedData, urlRequest;
@synthesize successInvocation, failureInvocation;

- (id) init{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

- (id) initWithTarget:(id)anObject successSelector:(SEL)successSelector failureSelector:(SEL)failureSelector{
	self = [super init];
	if (self != nil) {
		NSMethodSignature *sig = [[anObject class] instanceMethodSignatureForSelector:successSelector];
		self.successInvocation = [NSInvocation invocationWithMethodSignature:sig];
		[self.successInvocation setTarget:anObject];
		[self.successInvocation setSelector:successSelector];
		
		sig = [[anObject class] instanceMethodSignatureForSelector:failureSelector];
		self.failureInvocation = [NSInvocation invocationWithMethodSignature:sig];
		[self.failureInvocation setTarget:anObject];
		[self.failureInvocation setSelector:failureSelector];
		
		self.receivedData = [NSMutableData data];
	}
	return self;
}

- (void)connect:(NSString *)urlString{
	urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	[self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[self.failureInvocation setArgument:&error atIndex:2];
	[self.failureInvocation retainArguments];
	[self.failureInvocation invoke];

	[connection release];
	[receivedData release];
	[successInvocation release];
	[failureInvocation release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSMutableData *data = self.receivedData;
	[self.successInvocation setArgument:&data atIndex:2];
	[self.successInvocation retainArguments];
	[self.successInvocation invoke];
	
	[connection release];
	[receivedData release];
	[successInvocation release];
	[failureInvocation release];
}

- (void)dealloc {
	[successInvocation release];
	[failureInvocation release];
	[urlRequest release];
	[super dealloc];
}

@end
