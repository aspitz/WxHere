//
//  MapViewController.h
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

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

@class MKMapView;
@class WxAnnotation;
@class WxDataModel;
@class MKPinAnnotationView;

@interface MapViewController : UIViewController <MKMapViewDelegate>{
	MKMapView *mapView;
	UIView *activityView;
	UIActivityIndicatorView *activityIndicator;
	UINavigationBar *navigationBar;
	UINavigationItem *navigationItem;
	UIBarButtonItem *tweetButton;

	WxAnnotation *wxAnnotation;
	MKPinAnnotationView *wxAnnotationView;
	
	WxDataModel *wxDataModel;
	UIButton *rightCalloutButton;
	
	BOOL memoryWarning;
}

@property (retain) IBOutlet MKMapView *mapView;
@property (retain) IBOutlet UIView *activityView;
@property (retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain) IBOutlet UINavigationBar *navigationBar;
@property (retain) IBOutlet UINavigationItem *navigationItem;

- (void)dataModelUpdating;

- (void)gpsUpdated;
- (void)locationNameUpdated;
- (void)currentConditionsUpdated;
- (void)forecastsUpdated;

- (IBAction)refreshDataModel:(id)sender;
- (void)updateAnnotation;

- (void)crawlViews;
- (void)crawlViews:(UIView *)view;

@end
