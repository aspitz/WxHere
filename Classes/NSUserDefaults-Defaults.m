//
//  NSUserDefaults+Defaults.m
//  WxNow
//
//  Created by Ayal Spitz on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSUserDefaults-Defaults.h"


@implementation NSUserDefaults (Defaults)

- (NSInteger)integerForKey:(NSString *)defaultName defaultValue:(NSInteger)defaultValue{
	if ([self objectForKey:defaultName] == nil){
		return defaultValue;
	} else {
		return [self integerForKey:defaultName];
	}
}

- (BOOL)boolForKey:(NSString *)defaultName defaultValue:(BOOL)defaultValue{
	if ([self objectForKey:defaultName] == nil){
		return defaultValue;
	} else {
		return [self boolForKey:defaultName];
	}
}

@end
