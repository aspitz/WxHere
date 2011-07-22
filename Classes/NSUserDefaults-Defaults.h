//
//  NSUserDefaults+Defaults.h
//  WxNow
//
//  Created by Ayal Spitz on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSUserDefaults (Defaults)

- (NSInteger)integerForKey:(NSString *)defaultName defaultValue:(NSInteger)defaultValue;
- (BOOL)boolForKey:(NSString *)defaultName defaultValue:(BOOL)defaultValue;

@end
