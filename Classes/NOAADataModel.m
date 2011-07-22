//
//  NOAADataModel.m
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

#import "NOAADataModel.h"
#import "GPSDataModel.h"
#import "DDXML.h"
#import <CoreLocation/CoreLocation.h>
#import "ForecastDay.h"
#import "ForecastPeriod.h"
#import "Period.h"

@implementation NOAADataModel
@synthesize timeLayoutDictionary, multidayForecast;
@synthesize location, locationStr;


- (id)init{
	self = [super init];
	if (self != nil){
		[self refresh];
		
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDefaultDate:[NSDate date]];
		[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"]; // 2009-09-26T12:00:00-05:00
	}
	
	return self;
}

- (void)dealloc{
	[timeLayoutDictionary release];
	[multidayForecast release];
	[location release];
	[locationStr release];
	[dateFormatter release];
    [super dealloc];
}

- (void)update:(id)dataModel{
	[super update:dataModel];

	GPSDataModel *gpsDataModel = dataModel;

	self.location = gpsDataModel.location;
	
	NSString *urlStr = [[NSString alloc] 
						initWithFormat:@"http://forecast.weather.gov/MapClick.php?lat=%f&lon=%f&FcstType=dwml", 
						self.location.coordinate.latitude,
						self.location.coordinate.longitude];
	
	DLog(@"%@",urlStr);
	[self connect:urlStr];
	[urlStr release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSError *error = nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:self.receivedData options:0 error:&error];
	if (error){
		[xmlDoc release];
		[self bubbleUpError:@"NOAADataModelErrorDomain" code:0 errorString:@"There appears to be a problem getting data from NOAA right now"];
		//[self handleError:error];
		return;
	}
	DDXMLElement *rootElement = [xmlDoc rootElement];
	
	NSArray *elements = [rootElement elementsForName:@"data"];
	if ([elements count] == 0){
		[xmlDoc release];
		[self bubbleUpError:@"NOAADataModelErrorDomain" code:1 errorString:@"Unable to extract NOAA data"];
		return;
	}
	DDXMLElement *dataElement = [elements objectAtIndex:0];
	[self parseTimeLayouts:dataElement];
	
	elements = [dataElement elementsForName:@"parameters"];
	if ([elements count] == 0){
		[xmlDoc release];
		[self bubbleUpError:@"NOAADataModelErrorDomain" code:2 errorString:@"Unable to extract NOAA data"];
		return;
	}
	DDXMLElement *element = [elements objectAtIndex:0];
	
	[self parseFullForecasts:element];
	[self parseShortForecasts:element];
	[self parseTemperatures:element];
	[self parseConditions:element];
	
	self.state = Updated;
	[xmlDoc release];
	[super connectionDidFinishLoading:connection];
}

- (void)parseTimeLayouts:(DDXMLElement *)dataElement{
	DLog(@"Start");
	
	NSArray *timeLayouts = [dataElement elementsForName:@"time-layout"];
	
	for(DDXMLElement *timeLayout in timeLayouts){
		[self parseTimeLayout:timeLayout];
	}

	DLog(@"End");
}

- (void)parseTimeLayout:(DDXMLElement *)timeLayout{
	DLog(@"Start");

	// Read time layout key
	NSArray *elements = [timeLayout elementsForName:@"layout-key"];
	if ([elements count] == 0){
		[self bubbleUpError:@"NOAADataModelErrorDomain" code:3 errorString:@"Unable to extract NOAA time data"];
		return;
	}
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSUInteger components = (NSDayCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSWeekdayCalendarUnit);
	
	NSString *key = [[elements objectAtIndex:0] stringValue];
	
	// Read all time periods
	NSArray *timePeriods = [timeLayout elementsForName:@"start-valid-time"];
	NSMutableArray *periods = [[NSMutableArray alloc]init];
	Period *period;
	NSString *timeDateString = nil;
	
	for (DDXMLElement *timePeriod in timePeriods){
		timeDateString = [timePeriod stringValue];
		period = [[Period alloc] init];
		period.date = [self parseTimeDateString:timeDateString];
		period.dateComponents = [calendar components:components fromDate:period.date];
		DLog(@"%@", period);
		[periods addObject:period];
	}
	
	[self.timeLayoutDictionary setObject:periods forKey:key];
	[periods release];

	DLog(@"End");
}

- (void)parseFullForecasts:(DDXMLElement *)parameterElement{
	DLog(@"Start");

	NSArray *elements = [parameterElement elementsForName:@"wordedForecast"];
	if ([elements count] == 0){
		[self bubbleUpError:@"NOAADataModelErrorDomain" code:4 errorString:@"Unable to extract forecast data"];
		return;
	}
	DDXMLElement *fullForecasts = [elements objectAtIndex:0];
	NSString *key = [[fullForecasts attributeForName:@"time-layout"] stringValue];
	NSArray *forecasts = [fullForecasts elementsForName:@"text"];
	NSArray *periods = [self.timeLayoutDictionary objectForKey:key];
	Period *period;
	int i = 0, day = 0, hour = 0;
	ForecastDay *forecastDay = nil;
	
	NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
	dateFormater.dateStyle = NSDateFormatterFullStyle;
	
	for (DDXMLElement *forecast in forecasts){
		period = [periods objectAtIndex:i];
		day = period.dateComponents.day;
		hour = period.dateComponents.hour;
		
		if((forecastDay == nil) || (forecastDay.day != day)){
			forecastDay = [[ForecastDay alloc]init];
			forecastDay.day = day; // should probably be forecastDay.day = day - deltaDay;
			forecastDay.date = period.date;
			forecastDay.name = [dateFormater stringFromDate:period.date];
			[self.multidayForecast addObject:forecastDay];
			[forecastDay release];
		}
	
		[forecastDay period:hour].longForecast = forecast.stringValue;
		
		DLog(@"%@", forecast.stringValue);
		i++;
	}

	[dateFormater release];
	
	DLog(@"End");
}

- (void)parseShortForecasts:(DDXMLElement *)parameterElement{
	DLog(@"Start");

	NSArray *elements = [parameterElement elementsForName:@"weather"];
	if ([elements count] == 0){
		[self bubbleUpError:@"NOAADataModelErrorDomain" code:5 errorString:@"Unable to extract daily highs and lows data"];
		return;
	}
	DDXMLElement *shortForecasts = [elements objectAtIndex:0];
	NSString *key = [[shortForecasts attributeForName:@"time-layout"] stringValue];
	NSArray *forecasts = [shortForecasts elementsForName:@"weather-conditions"];
	NSArray *periods = [self.timeLayoutDictionary objectForKey:key];
	Period *period;
	int i = 0, j = 0, hour = 0, day = 0;
	ForecastDay *forecastDay = nil;
	NSString *shortForecast;
	
	for (DDXMLElement *forecast in forecasts){
		period = [periods objectAtIndex:i];
		hour = period.dateComponents.hour;
		day = period.dateComponents.day;
		shortForecast = [[forecast attributeForName:@"weather-summary"] stringValue];
		
		forecastDay = [self.multidayForecast objectAtIndex:j];
		if (forecastDay.day != day){
			j++;
			forecastDay = [self.multidayForecast objectAtIndex:j];
		}
	
		[forecastDay period:hour].shortForecast = shortForecast;
		
		DLog(@"%@", shortForecast);
		i++;
	}
	
	DLog(@"End");
}

- (void)parseConditions:(DDXMLElement *)parameterElement{
	DLog(@"Start");
	
	NSArray *elements = [parameterElement elementsForName:@"conditions-icon"];
	if ([elements count] == 0){
		[self bubbleUpError:@"NOAADataModelErrorDomain" code:5 errorString:@"Unable to extract daily conditions"];
		return;
	}
	DDXMLElement *conditionIcons = [elements objectAtIndex:0];
	NSString *key = [[conditionIcons attributeForName:@"time-layout"] stringValue];
	NSArray *conditions = [conditionIcons elementsForName:@"icon-link"];
	NSArray *periods = [self.timeLayoutDictionary objectForKey:key];
	Period *period;
	int i = 0, j = 0, hour = 0, day = 0;
	ForecastDay *forecastDay = nil;
	NSString *conditionIcon;
	NSRange nameRange;
	int length = 0;
	
	for (DDXMLElement *condition in conditions){
		period = [periods objectAtIndex:i];
		hour = period.dateComponents.hour;
		day = period.dateComponents.day;
		
		conditionIcon = [condition stringValue];
		length = [conditionIcon length];
		if (length <= 47 + 4){
			[self bubbleUpError:@"NOAADataModelErrorDomain" code:5 errorString:@"Unable to extract daily conditions"];
			return;
		}
		
		nameRange = NSMakeRange(47, length - 4 - 47);
		DLog(@"%@",conditionIcon);
		conditionIcon = [conditionIcon substringWithRange:nameRange];
		DLog(@"%@",conditionIcon);
		
		forecastDay = [self.multidayForecast objectAtIndex:j];
		if (forecastDay.day != day){
			j++;
			forecastDay = [self.multidayForecast objectAtIndex:j];
		}
		
		[forecastDay period:hour].condition = conditionIcon;
		
		DLog(@"%@", conditionIcon);
		i++;
	}
	
	DLog(@"End");
}

- (void)parseTemperatures:(DDXMLElement *)parameterElement{
	DLog(@"Star");

	NSArray *temperatures = [parameterElement elementsForName:@"temperature"];
	NSString *type = nil;
	
	for (DDXMLElement *temperatureSet in temperatures){
		type = [[temperatureSet attributeForName:@"type"] stringValue];
		[self parseTemperatures:temperatureSet isMin:[type isEqualToString:@"minimum"]];
	}

	DLog(@"End");
}

- (void)parseTemperatures:(DDXMLElement *)parameterElement isMin:(BOOL)minFlag{
	NSString *key = [[parameterElement attributeForName:@"time-layout"] stringValue];
	NSArray *values = [parameterElement elementsForName:@"value"];
	NSArray *periods = [self.timeLayoutDictionary objectForKey:key];
	Period *period;
	ForecastDay *forecastDay = nil;
	NSString *temp;
	int i = 0, j = 0, day = 0;
	
	for (DDXMLElement *value in values){
		period = [periods objectAtIndex:i];
		day = period.dateComponents.day;
		temp = [value stringValue];
		
		forecastDay = [self.multidayForecast objectAtIndex:j];
		if (forecastDay.day != day){
			j++;
			forecastDay = [self.multidayForecast objectAtIndex:j];
		}
		
		//[forecastDay periodBool:!minFlag].temp = temp;
		[forecastDay period:period.dateComponents.hour].temp = temp;
		
		DLog(@"%@", value);
		i++;
	}
}

- (NSDate *)parseTimeDateString:(NSString *)timeDateString{
	NSMutableString *mutableTimeDateString = [[NSMutableString alloc] initWithString:timeDateString];
	[mutableTimeDateString insertString:@"GMT" atIndex:19];
	NSDate *date = [dateFormatter dateFromString:mutableTimeDateString];
	[mutableTimeDateString release];
	DLog(@"%@",date);
	
	return date;
}

- (void)refresh{
	[super refresh];
	self.timeLayoutDictionary = [[NSMutableDictionary alloc]init];
	self.multidayForecast = [[NSMutableArray alloc]init];
	self.location = nil;
	self.locationStr = nil;
}

- (BOOL)hasOvernightPeriod{
	ForecastDay *forecastDay = [self.multidayForecast objectAtIndex:0];
	return (forecastDay.periods.count == 3);
}

- (ForecastPeriod *)period:(NSIndexPath *)indexPath{
	ForecastDay *forecastDay = nil;
	
	if ([self hasOvernightPeriod]){
		if (indexPath.section == 0){
			forecastDay = [self.multidayForecast objectAtIndex:0];
			return [forecastDay periodAtIndex:0];
		} else if (indexPath.section == 1){
			forecastDay = [self.multidayForecast objectAtIndex:0];
			return [forecastDay periodAtIndex:(indexPath.row + 1)];
		} else {
			forecastDay = [self.multidayForecast objectAtIndex:(indexPath.section - 1)];
			return [forecastDay periodAtIndex:indexPath.row];
		}
	}
	
	forecastDay = [self.multidayForecast objectAtIndex:indexPath.section];
	return [forecastDay periodAtIndex:indexPath.row];
}

- (NSString *)currentHighLowString{
	ForecastDay *forecastDay = [self.multidayForecast objectAtIndex:0];
	NSUInteger periodCount = [forecastDay.periods allValues].count;
	
	switch (periodCount){
		case 1:
		case 3:
			return [NSString stringWithFormat:@"Lo:%@°F", [forecastDay periodAtIndex:0].temp];
			break;
		case 2:
			return [NSString stringWithFormat:@"Hi:%@°F - Lo:%@°F", [forecastDay periodAtIndex:0].temp,
																	[forecastDay periodAtIndex:1].temp];			
			break;
		default:
			return @"Oops";
			break;
	}
}

@end

// http://forecast.weather.gov/MapClick.php?lat=42.38780&lon=-71.24220&FcstType=dwml
