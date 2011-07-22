//
//  Period.m
//  WxNow
//
//  Created by Ayal Spitz on 2/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Period.h"


@implementation Period
@synthesize date, dateComponents;

- (void) dealloc{
	[date release];
	[dateComponents release];
	[super dealloc];
}

@end
