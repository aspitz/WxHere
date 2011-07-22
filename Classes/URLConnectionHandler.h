//
//  URLConnectionHandler.h
//  WxNow
//
//  Created by Ayal Spitz on 5/25/09.
//  Copyright 2009 Ayal Spitz. All rights reserved.
//

@interface URLConnectionHandler : NSObject {
	NSMutableData *receivedData;
	
	NSURLRequest *urlRequest;
	
	NSInvocation *successInvocation;
	NSInvocation *failureInvocation;
}

@property (nonatomic, retain) NSMutableData *receivedData;

@property (nonatomic, retain) NSURLRequest *urlRequest;

@property (nonatomic, retain) NSInvocation *successInvocation;
@property (nonatomic, retain) NSInvocation *failureInvocation;

- (id) initWithTarget:(id)anObject successSelector:(SEL)successSelector failureSelector:(SEL)failureSelector;
- (void)connect:(NSString *)urlString;

@end
