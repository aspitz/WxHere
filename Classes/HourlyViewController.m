//
//  HourlyViewController.m
//  WxNow
//
//  Created by Ayal Spitz on 7/15/10.
//  Copyright 2010 MITRE Corp. All rights reserved.
//

#import "HourlyViewController.h"
#import "HourlyForecastDataModel.h"
#import "WxDataModel.h"
#import "GraphView.h"


@implementation HourlyViewController
@synthesize activityView, activityIndicator;
@synthesize graphView;

#pragma mark -
#pragma mark NSObject lifecycle methods

- (id)initWithCoder:(NSCoder *)decoder{
	self = [super initWithCoder:decoder];
	if (self != nil){
		//hourlyForecastDataModel = [WxDataModel dataModel].hourlyForecastDataModel;
	}
	return self;
}

- (void)dealloc {
	[hourlyForecastDataModel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning{
	DLog(@"memory warning");
	[super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	[hourlyForecastDataModel addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptionNew) context:nil];
	
	[self.view.superview addSubview:self.activityView];
	[self dataModelUpdating];
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	
	[hourlyForecastDataModel removeObserver:self forKeyPath:@"state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqual:@"state"]){
		[self dataModelUpdating];
	}
}

- (void)dataModelUpdating{
	DLog(@"Start");	
	
	if (hourlyForecastDataModel.state == Updating){
		[self.activityIndicator startAnimating];
		self.activityView.alpha = 0.5;
	} else if ((hourlyForecastDataModel.state == Updated) || (hourlyForecastDataModel.state == Error)){
		/*if (hourlyForecastDataModel.hourlyForecast.count != 0){
			[self.tableView reloadData];
		}*/
		[self.activityIndicator stopAnimating];
		self.activityView.alpha = 0.0;

		[graphView setDataFromArray:hourlyForecastDataModel.hourlyForecast
						withKeyPath:@"temperature" startAtIndex:0 withLength:48];
		graphView.xAxisLabelFormat = @"%d°";
		
		[graphView setNeedsDisplay];
	}
	
	DLog(@"End");	
}

@end
