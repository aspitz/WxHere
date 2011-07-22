//
//  NOAADataModel.h
//  WxHere
//
//  Created by Ayal Spitz on 9/8/09.
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

#import <Foundation/Foundation.h>
#import "NetDataModel.h"

@class GPSDataModel;
@class DDXMLElement;
@class CLLocation;
@class ForecastPeriod;

@interface NOAADataModel : NetDataModel{
	NSMutableDictionary *timeLayoutDictionary;
	NSMutableArray *multidayForecast;
	
	CLLocation *location;
	NSString *locationStr;
	
	NSDateFormatter *dateFormatter;
}

@property(retain) NSMutableDictionary *timeLayoutDictionary;
@property(retain) NSMutableArray *multidayForecast;

@property (retain, nonatomic) CLLocation *location;
@property(nonatomic, copy) NSString *locationStr;

- (void)parseTimeLayouts:(DDXMLElement *)dataElement;
- (void)parseTimeLayout:(DDXMLElement *)timeLayout;
- (void)parseFullForecasts:(DDXMLElement *)parameterElement;
- (void)parseShortForecasts:(DDXMLElement *)parameterElement;
- (void)parseConditions:(DDXMLElement *)parameterElement;
- (void)parseTemperatures:(DDXMLElement *)parameterElement;
- (void)parseTemperatures:(DDXMLElement *)parameterElement isMin:(BOOL)type;

- (NSDate *)parseTimeDateString:(NSString *)timeDateString;

- (BOOL)hasOvernightPeriod;
- (ForecastPeriod *)period:(NSIndexPath *)indexPath;
- (NSString *)currentHighLowString;

@end