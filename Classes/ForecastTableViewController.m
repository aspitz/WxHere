//
//  ForcastTableViewController.m
//  WxHere
//
//  Created by Ayal Spitz on 9/13/09.
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

#import "ForecastTableViewController.h"
#import "WxDataModel.h"
#import "NOAADataModel.h"
#import "ForecastDay.h"
#import "ForecastPeriod.h"
#import "ForecastTableViewCell.h"

@implementation ForecastTableViewController
@synthesize activityView, activityIndicator;

#pragma mark -
#pragma mark NSObject lifecycle methods

- (id)initWithCoder:(NSCoder *)decoder{
	self = [super initWithCoder:decoder];
	if (self != nil){
		noaaDataModel = [WxDataModel dataModel].noaaDataModel;
		
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Weather Icons" ofType:@"plist"];
		weatherIcons = [[NSDictionary alloc]initWithContentsOfFile:filePath];
	}
	return self;
}

- (void)dealloc {
	[activityView release];
	[activityIndicator release];
	[weatherIcons release];
	[noaaDataModel release];
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
	
	[noaaDataModel addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptionNew) context:nil];
	
	[self.view.superview addSubview:self.activityView];
	[self dataModelUpdating];
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	
	[noaaDataModel removeObserver:self forKeyPath:@"state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqual:@"state"]){
		[self dataModelUpdating];
	}
}

- (void)dataModelUpdating{
	DLog(@"Start");	
	
	if (noaaDataModel.state == Updating){
		[self.activityIndicator startAnimating];
		self.activityView.alpha = 0.5;
	} else if ((noaaDataModel.state == Updated) || (noaaDataModel.state == Error)){
		if (noaaDataModel.multidayForecast.count != 0){
			[self.tableView reloadData];
		}
		[self.activityIndicator stopAnimating];
		self.activityView.alpha = 0.0;
	}
	
	DLog(@"End");	
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSArray *multidayForecast = noaaDataModel.multidayForecast;
	NSUInteger sectionCount = 0;
	
	if (multidayForecast.count != 0){
		ForecastDay *forecastDay = [multidayForecast objectAtIndex:0];
		sectionCount = multidayForecast.count;
		
		if (forecastDay.periods.count == 3){
			sectionCount++;
		}
	}	

	return sectionCount;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *multidayForecast = noaaDataModel.multidayForecast;
	ForecastDay *forecastDay = [multidayForecast objectAtIndex:0];

	if (forecastDay.periods.count == 3){
		if (section == 0){
			return 1;
		} else if (section == 1){
			return 2;
		} else {
			forecastDay = [multidayForecast objectAtIndex:section - 1];
			return forecastDay.periods.count;
		}
	} else {
		forecastDay = [multidayForecast objectAtIndex:section];
		return forecastDay.periods.count;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)localTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ForecastCell";
    
    ForecastTableViewCell *cell = nil;
	cell = (ForecastTableViewCell *)[localTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ForecastTableViewCell"
																 owner:self
															   options:nil];
		cell = (ForecastTableViewCell *)[topLevelObjects objectAtIndex:0];
    }
    
	ForecastPeriod *forecastPeriod = [noaaDataModel period:indexPath];
	
	cell.conditionLabel.text = forecastPeriod.shortForecast;
	cell.forecastLabel.text = forecastPeriod.longForecast;
	cell.tempLabel.text = [NSString stringWithFormat:@"%@°F",forecastPeriod.temp];
	
	NSString *imageName = [weatherIcons objectForKey:forecastPeriod.condition];
	cell.periodImageView.image = [UIImage imageNamed:imageName];
	
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	ForecastDay *forecastDay = [noaaDataModel.multidayForecast objectAtIndex:0];
	NSUInteger periodCount = forecastDay.periods.count;
	
	switch (section) {
		case 0:
			switch (periodCount){
				case 1:
					return @"Tonight";
					break;
				case 2:
					return @"Today";
					break;
				case 3:
					return @"Overnight";
					break;
			}
			break;
		case 1:
			return @"Tomorrow";
			break;
	}
	
	if (section != noaaDataModel.multidayForecast.count){
		forecastDay = [noaaDataModel.multidayForecast objectAtIndex:section];
		return forecastDay.name;
	} else {
		NSDateFormatter *dateFormater = [[[NSDateFormatter alloc]init]autorelease];
		dateFormater.dateStyle = NSDateFormatterFullStyle;

		forecastDay = [noaaDataModel.multidayForecast objectAtIndex:(section - 1)];
		NSDate *date = [[[NSDate alloc]initWithTimeInterval:(60*60*24) sinceDate:forecastDay.date]autorelease];
		return [dateFormater stringFromDate:date];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	ForecastPeriod *forecastPeriod = [noaaDataModel period:indexPath];
	NSString *detailText = forecastPeriod.longForecast;
	DLog(@"%@",detailText);
	
	CGSize constrainSize = CGSizeMake(228, 400);

	UIFont *detailFont = [UIFont systemFontOfSize:14];
	
	CGFloat detailHeight = [detailText sizeWithFont:detailFont
								  constrainedToSize:constrainSize
									  lineBreakMode:UILineBreakModeWordWrap].height;

	CGFloat height = 35 + detailHeight + 13;
	
	if (height < 88.0 ){ height = 88.0; }
	
	return height;
}

@end
