//
//  MapViewController.m
//  WxHere
//
//  Created by Ayal Spitz on 7/31/09.
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

#import "MapViewController.h"
#import "WxDataModel.h"
#import "GPSDataModel.h"
#import "LocationDataModel.h"
#import "CurrentConditionsDataModel.h"
#import "NOAADataModel.h"
#import "WxHereAppDelegate.h"
#import "WxAnnotation.h"
#import "ForecastDay.h"
#import "ForecastPeriod.h"

@implementation MapViewController
@synthesize mapView, activityView, activityIndicator;
@synthesize navigationBar;

@synthesize navigationItem;

#pragma mark -
#pragma mark UIViewController lifecycle methods

- (id)initWithCoder:(NSCoder *)decoder{
	self = [super initWithCoder:decoder];
	if (self != nil){
		wxDataModel = [WxDataModel dataModel];		
		memoryWarning = NO;
	}
	return self;
}

- (void)dealloc {
	[mapView release];
	[activityView release];
	[activityIndicator release];
	[wxAnnotationView release];
	[wxAnnotation release];
	[navigationBar release];
	[navigationItem release];
	[wxDataModel release];
	[tweetButton release];
	[rightCalloutButton release];
		
    [super dealloc];
}

- (void)didReceiveMemoryWarning{
	DLog(@"memory warning");
	memoryWarning = YES;
	[super didReceiveMemoryWarning];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if ([keyPath isEqual:@"state"]){
		if ([object class] == [GPSDataModel class]){
			[self gpsUpdated];
		} else if ([object class] == [LocationDataModel class]){
			[self locationNameUpdated];
		} else if ([object class] == [CurrentConditionsDataModel class]){
			[self currentConditionsUpdated];
		} else if ([object class] == [NOAADataModel class]){
			[self forecastsUpdated];
		} else if ([object class] == [WxDataModel class]){
			[self dataModelUpdating];
		}
	}
}

- (void)gpsUpdated{
	DLog(@"Start");
	
	GPSDataModel *dataModel = wxDataModel.gpsDataModel;
	
	if (dataModel.state == Updated){
		// Zoom to the users location
		CLLocation *currentLocation = dataModel.location;
		CLLocationDistance distance = MAX(4*currentLocation.horizontalAccuracy, 500);
		MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, distance, distance);
		[self.mapView setRegion:region animated:YES];
		
		// If the annotation exists, make sure to release the old one
		if (wxAnnotation != nil){
			[wxAnnotation release];
			wxAnnotation = nil;
		}
		wxAnnotation = [[WxAnnotation alloc]initWithGPSDataModel:dataModel];
		
		// If the annotation view isn't on the screen then we should animate the ping drop
		BOOL animatesDrop = (wxAnnotationView == nil);

		// Lets make sure that we create an annotation view so that we have a view to add stuff to
		if (wxAnnotationView != nil){
			[wxAnnotationView release];
			wxAnnotationView = nil;
		}
		wxAnnotationView = [[MKPinAnnotationView alloc]initWithAnnotation:wxAnnotation reuseIdentifier:@"WXAnnotation"];
		wxAnnotationView.pinColor = MKPinAnnotationColorPurple;
		wxAnnotationView.animatesDrop = animatesDrop;
		// Make sure to set 'canShowCallout' to YES otherwise the callout will not show
		wxAnnotationView.canShowCallout = YES;
		
		// Make sure to add the annotation to the map
		[self.mapView addAnnotation:wxAnnotation];
		
		// Once we add the annotation to the map we can turn off the users location
		//self.mapView.showsUserLocation = NO;
		
		[self updateAnnotation];
	}
	
	DLog(@"End");
}

- (void)locationNameUpdated{
	DLog(@"Start");

	self.navigationBar.topItem.title = wxDataModel.locationDataModel.location;
	[self.navigationBar setNeedsDisplay];
	
	DLog(@"End");
}

- (void)currentConditionsUpdated{
	DLog(@"Start");	
	
	CurrentConditionsDataModel *dataModel = wxDataModel.currentConditionsDataModel;
	
	if (dataModel.state == Updated){
		[wxAnnotation updateCurrentConditions:dataModel];
		
		[wxAnnotationView setLeftCalloutAccessoryView:dataModel.conditionImage];
		[self updateAnnotation];
	}
	
	DLog(@"End");	
}

- (void)forecastsUpdated{
	DLog(@"Start");	

	NOAADataModel *dataModel = wxDataModel.noaaDataModel;
	
	if ((dataModel.state == Updated) && ([dataModel.multidayForecast count] != 0)){
		wxAnnotation.subtitle = [dataModel currentHighLowString];
		/*ForecastDay *forecastDay = [dataModel.multidayForecast objectAtIndex:0];
		NSArray *periods = [forecastDay.periods allValues];
		
		NSString *highLow;
		ForecastPeriod *period = [forecastDay periodAtIndex:0];
		if ((periods.count == 1) || (periods.count == 3)){
			highLow = [[NSString alloc] initWithFormat:@"Lo:%@°F", period.temp];
		} else if (periods.count == 2){
			ForecastPeriod *amPeriod = [forecastDay periodAtIndex:1];
			highLow = [[NSString alloc] initWithFormat:@"Hi:%@°F - Lo:%@°F", amPeriod.temp, period.temp];
		}
		
		self.wxAnnotation.subtitle = highLow;
		[highLow release];*/
		
		// Create and add the right button to the callout
		rightCalloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[wxAnnotationView setRightCalloutAccessoryView:rightCalloutButton];
		
		[self updateAnnotation];

		[self crawlViews];
	}
	
	DLog(@"End");	
}

- (void)dataModelUpdating{
	DLog(@"Start");	

	if (wxDataModel.state == Updating){
		[self.activityIndicator startAnimating];
		self.activityView.alpha = 0.5;
	} else {
		[self.activityIndicator stopAnimating];
		self.activityView.alpha = 0.0;
	}

	DLog(@"End");	
}


#pragma mark -
#pragma mark UIViewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *mapType = [[NSUserDefaults standardUserDefaults]stringForKey:@"map_type_preference"];
	if ([mapType isEqualToString:@"Standard"]){
		self.mapView.mapType = MKMapTypeStandard;
	} else if ([mapType isEqualToString:@"Satellite"]){
		self.mapView.mapType = MKMapTypeSatellite;
	} else if ([mapType isEqualToString:@"Hybrid"]){
		self.mapView.mapType = MKMapTypeHybrid;
	}
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];

	[wxDataModel.gpsDataModel addObserver:self forKeyPath:@"state" options:0 context:NULL];
	[wxDataModel.locationDataModel addObserver:self forKeyPath:@"state" options:0 context:NULL];
	[wxDataModel.noaaDataModel addObserver:self forKeyPath:@"state" options:0 context:NULL];
	[wxDataModel.currentConditionsDataModel addObserver:self forKeyPath:@"state" options:0 context:NULL];
	
	[wxDataModel addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptionNew) context:nil];

	[self gpsUpdated];
	[self locationNameUpdated];
	[self currentConditionsUpdated];
	[self forecastsUpdated];
}

- (void)viewDidAppear:(BOOL)animated{
	[self dataModelUpdating];
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];

	[wxDataModel.gpsDataModel removeObserver:self forKeyPath:@"state"];
	[wxDataModel.locationDataModel removeObserver:self forKeyPath:@"state"];
	[wxDataModel.noaaDataModel removeObserver:self forKeyPath:@"state"];
	[wxDataModel.currentConditionsDataModel removeObserver:self forKeyPath:@"state"];
	
	[wxDataModel removeObserver:self forKeyPath:@"state"];
}

#pragma mark -
#pragma mark MKMapViewDelegate Protocol implementation

- (void)mapView:(MKMapView *)localMapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	WxHereAppDelegate *appDelegate = ((WxHereAppDelegate *)([UIApplication sharedApplication].delegate));
	appDelegate.tabBarController.selectedIndex = 1;
}
	
- (void)mapView:(MKMapView *)localMapView regionDidChangeAnimated:(BOOL)animated{
	[self updateAnnotation];
}

- (void)mapView:(MKMapView *)localMapView didAddAnnotationViews:(NSArray *)views{
	[self.mapView selectAnnotation:wxAnnotation animated:NO];
	
	if (memoryWarning){
		memoryWarning = NO;
		[self dataModelUpdating];
		[self gpsUpdated];
		[self locationNameUpdated];
		[self currentConditionsUpdated];
		[self forecastsUpdated];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)localMapView viewForAnnotation:(id <MKAnnotation>)annotation{
	return wxAnnotationView;
}

#pragma mark -

- (void)updateAnnotation{
	if ([self.mapView selectedAnnotations]){
		[self.mapView deselectAnnotation:wxAnnotation animated:NO];
		[self.mapView selectAnnotation:wxAnnotation animated:NO];
	}
}

- (IBAction)refreshDataModel:(id)sender{
	// Clear the annotation
	[self.mapView removeAnnotation:wxAnnotation];
	
	if (rightCalloutButton != nil){
		[rightCalloutButton release];
		rightCalloutButton = nil;
	}
	
	if (wxAnnotation != nil){
		[wxAnnotation release];
		wxAnnotation = nil;
	}
	if (wxAnnotationView != nil){
		[wxAnnotationView release];
		wxAnnotationView = nil;
	}
	
	// Clear the navigation title
	self.navigationBar.topItem.title = @"";
	[self.navigationBar setNeedsDisplay];

	// Refresh the data model
	[wxDataModel refresh];

	// Refresh the activity indicator
	[self dataModelUpdating];
}

- (void)crawlViews{
	UIApplication *app = [UIApplication sharedApplication];
	for (UIView *view in app.windows){
		[self crawlViews:view];
	}
}

- (void)crawlViews:(UIView *)view{
	DLog(@"view - %@", view);
	for(UIView *subview in [view subviews]){
		[self crawlViews:subview];
	}
}

@end
