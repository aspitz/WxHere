//
//  HourlyViewController.h
//  WxNow
//
//  Created by Ayal Spitz on 7/15/10.
//  Copyright 2010 MITRE Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HourlyForecastDataModel;
@class GraphView;

@interface HourlyViewController : UIViewController {
	UIView *activityView;
	UIActivityIndicatorView *activityIndicator;

	HourlyForecastDataModel *hourlyForecastDataModel;
	GraphView *graphView;
}

- (void)dataModelUpdating;

@property (retain) IBOutlet UIView *activityView;
@property (retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain) IBOutlet GraphView *graphView;

@end
