//
//  Period.h
//  WxNow
//
//  Created by Ayal Spitz on 2/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Period : NSObject {
	NSDate *date;
	NSDateComponents *dateComponents;
}

@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDateComponents *dateComponents;

@end
