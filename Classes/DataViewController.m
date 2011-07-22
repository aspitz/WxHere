//
//  DataViewController.m
//  WxHere
//
//  Created by Ayal Spitz on 5/19/09.
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

#import "DataViewController.h"
#import "WxDataModel.h"
#import <CoreLocation/CoreLocation.h>

@implementation DataViewController

static const NSUInteger sectionRowArray[] = { 4, 3, 5, 2, 2, 1};

- (id)initWithCoder:(NSCoder *)decoder{
	self = [super initWithCoder:decoder];
	if (self != nil){
		sectionHeaders = [[NSArray alloc]initWithObjects:@"GPS", @"Location", @"Current Condition",
						  @"Daily Forecasts", @"Hourly Forecasts", @"Overall", nil];
	}
	return self;
}

- (void)dealloc {
	[sectionHeaders release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning{
	DLog(@"memory warning");
	[super didReceiveMemoryWarning];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewWillAppear:(BOOL)animated{
	WxDataModel *dataModel = [WxDataModel dataModel];
	[dataModel addObserver:self forKeyPath:@"gpsDataModel.location" options:(NSKeyValueObservingOptionNew) context:nil];
	[dataModel addObserver:self forKeyPath:@"gpsDataModel.elapsedTime" options:(NSKeyValueObservingOptionNew) context:nil];
	[dataModel addObserver:self forKeyPath:@"locationDataModel.elapsedTime" options:(NSKeyValueObservingOptionNew) context:nil];
	[dataModel addObserver:self forKeyPath:@"currentConditionsDataModel.elapsedTime" options:(NSKeyValueObservingOptionNew) context:nil];
	[dataModel addObserver:self forKeyPath:@"noaaDataModel.elapsedTime" options:(NSKeyValueObservingOptionNew) context:nil];
	[dataModel addObserver:self forKeyPath:@"elapsedTime" options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
	WxDataModel *dataModel = [WxDataModel dataModel];
	[dataModel removeObserver:self forKeyPath:@"gpsDataModel.location"];
	[dataModel removeObserver:self forKeyPath:@"gpsDataModel.elapsedTime"];
	[dataModel removeObserver:self forKeyPath:@"locationDataModel.elapsedTime"];
	[dataModel removeObserver:self forKeyPath:@"currentConditionsDataModel.elapsedTime"];
	[dataModel removeObserver:self forKeyPath:@"noaaDataModel.elapsedTime"];
	[dataModel removeObserver:self forKeyPath:@"elapsedTime"];
}

#pragma mark -
#pragma mark UITableViewDelegate Protocol implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{ return 6; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (section < 6){
		return sectionRowArray[section];
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	WxDataModel *dataModel = [WxDataModel dataModel];
	
	switch (indexPath.section){
		case 0:
			switch (indexPath.row){
				case 0:
					cell.textLabel.text = @"Latitude";
					CLLocation *location = [dataModel valueForKeyPath:@"gpsDataModel.location"];
					cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%g°",location.coordinate.latitude];
					return cell;
				case 1:
					cell.textLabel.text = @"Longitude";
					location = [dataModel valueForKeyPath:@"gpsDataModel.location"];
					cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%g°",location.coordinate.longitude];
					return cell;
				case 2:
					cell.textLabel.text = @"Accuracy";
					location = [dataModel valueForKeyPath:@"gpsDataModel.location"];
					cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%gm",location.horizontalAccuracy];
					return cell;
				case 3:
					cell.textLabel.text = @"Elapsed";
					NSNumber *elapsedTime = [dataModel valueForKeyPath:@"gpsDataModel.elapsedTime"];
					cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%.2f sec",[elapsedTime doubleValue]];
					return cell;
			}
			break;
		case 1:
			switch (indexPath.row){
				case 0:
					cell.textLabel.text = @"City";
					cell.detailTextLabel.text = [dataModel valueForKeyPath:@"locationDataModel.city"];
					return cell;
				case 1:
					cell.textLabel.text = @"State";
					cell.detailTextLabel.text = [dataModel valueForKeyPath:@"locationDataModel.stateAbbr"];
					return cell;
				case 2:
					cell.textLabel.text = @"Elapsed";
					NSNumber *elapsedTime = [dataModel valueForKeyPath:@"locationDataModel.elapsedTime"];
					cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%.2f sec",[elapsedTime doubleValue]];
					return cell;
			}
			break;
		case 2:
			switch (indexPath.row){
				case 0:
					cell.textLabel.text = @"ICAO";
					cell.detailTextLabel.text = [dataModel valueForKeyPath:@"currentConditionsDataModel.icao"];
					return cell;
				case 1:
					cell.textLabel.text = @"Location";
					cell.detailTextLabel.text = [dataModel valueForKeyPath:@"currentConditionsDataModel.location"];
					return cell;
				case 2:
					cell.textLabel.text = @"Temp";
					NSString * value = [dataModel valueForKeyPath:@"currentConditionsDataModel.temperature"];
					if (value != nil){
						value = [[NSString alloc] initWithFormat:@"%@°F",value];
					}
					cell.detailTextLabel.text = value;
					[value release];
					return cell;
				case 3:
					cell.textLabel.text = @"Condition";
					cell.detailTextLabel.text = [dataModel valueForKeyPath:@"currentConditionsDataModel.condition"];
					return cell;
				case 4:
					cell.textLabel.text = @"Elapsed";
					NSNumber *elapsedTime = [dataModel valueForKeyPath:@"currentConditionsDataModel.elapsedTime"];
					cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%.2f sec",[elapsedTime doubleValue]];
					return cell;
			}
			break;
		case 3:
			switch (indexPath.row){
				case 0:
					cell.textLabel.text = @"Count";
					NSNumber *count = [dataModel valueForKeyPath:@"noaaDataModel.multidayForecast.@count"];
					cell.detailTextLabel.text = [count stringValue];
					return cell;
				case 1:
					cell.textLabel.text = @"Elapsed";
					NSNumber *elapsedTime = [dataModel valueForKeyPath:@"noaaDataModel.elapsedTime"];
					cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%.2f sec",[elapsedTime doubleValue]];
					return cell;
			}
			break;
		case 4:
			switch (indexPath.row){
				case 0:
					cell.textLabel.text = @"Count";
					NSNumber *count = [dataModel valueForKeyPath:@"hourlyForecastDataModel.hourlyForecast.@count"];
					cell.detailTextLabel.text = [count stringValue];
					return cell;
				case 1:
					cell.textLabel.text = @"Elapsed";
					NSNumber *elapsedTime = [dataModel valueForKeyPath:@"hourlyForecastDataModel.elapsedTime"];
					cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%.2f sec",[elapsedTime doubleValue]];
					return cell;
			}
			break;
		case 5:
			switch (indexPath.row){
				case 0:
					cell.textLabel.text = @"Elapsed";
					NSNumber *elapsedTime = [dataModel valueForKeyPath:@"elapsedTime"];
					cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%.2f sec",[elapsedTime doubleValue]];
					return cell;
			}
			break;
	}
	
	cell.textLabel.text = @"";
	cell.detailTextLabel.text = @"";
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if ((section >= 0) && (section <= 5)){ 
		return [sectionHeaders objectAtIndex:section];
	} else {
		return @"oops";
	}
}

@end
