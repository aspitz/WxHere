//
//  HourForecast.h
//  WxNow
//
//  Created by Ayal Spitz on 7/9/10.
//  Copyright 2010 MITRE Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kTemp,
	kDewPoint
} ElementType;

@class Period;

@interface HourForecast : NSObject {
	Period *period;
	int temperature;
	int dewPoint;
	int percentHumidity;
}

@property (retain, nonatomic) Period *period;
@property (assign) int temperature;
@property (assign) int dewPoint;
@property (assign) int percentHumidity;

@end
