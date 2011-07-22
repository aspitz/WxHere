//
//  HourlyForecastDataModel.m
//  WxNow
//
//  Created by Ayal Spitz on 7/9/10.
//  Copyright 2010 MITRE Corp. All rights reserved.
//

#import "HourlyForecastDataModel.h"
#import "GPSDataModel.h"
#import <CoreLocation/CoreLocation.h>
#import "DDXML.h"
#import "Period.h"
#import "HourForecast.h"

@implementation HourlyForecastDataModel

@synthesize hourlyForecast;

- (id)init{
	self = [super init];
	if (self != nil) {
		[self refresh];

		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDefaultDate:[NSDate date]];
		[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"]; // 2009-09-26T12:00:00-05:00
	}
	return self;
}

- (void) dealloc{
	[hourlyForecast release];
	[super dealloc];
}

- (void)update:(id)dataModel{
	[super update:dataModel];
	GPSDataModel *gpsDataModel = dataModel;
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://forecast.weather.gov/MapClick.php?lat=%f&lon=%f&FcstType=digitalDWML",
						   gpsDataModel.location.coordinate.latitude,
						   gpsDataModel.location.coordinate.longitude];
	DLog(@"%@", urlString);
	[self connect:urlString];
	
	[urlString release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSError *error = nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:self.receivedData options:0 error:&error];
	if (error){
		[xmlDoc release];
		[self bubbleUpError:@"HourlyForecastDataModelErrorDomain" code:0 errorString:@"There appears to be a problem getting data from NOAA right now"];
		//[self handleError:error];
		return;
	}
	DDXMLElement *rootElement = [xmlDoc rootElement];
	
	NSArray *elements = [rootElement elementsForName:@"data"];
	if ([elements count] == 0){
		[xmlDoc release];
		[self bubbleUpError:@"HourlyForecastDataModelErrorDomain" code:1 errorString:@"Unable to extract NOAA data"];
		return;
	}
	DDXMLElement *dataElement = [elements objectAtIndex:0];
    [self parseTimeLayout:dataElement];
    
	elements = [dataElement elementsForName:@"parameters"];
	if ([elements count] == 0){
		[xmlDoc release];
		[self bubbleUpError:@"HourlyForecastDataModelErrorDomain" code:1 errorString:@"Unable to extract NOAA data"];
		return;
	}
	DDXMLElement *parametersElement = [elements objectAtIndex:0];
	[self parseTemperatures:parametersElement];
	[self parseHumdity:parametersElement];
	
	self.state = Updated;
	[xmlDoc release];
	[super connectionDidFinishLoading:connection];
}

- (void)parseTimeLayout:(DDXMLElement *)dataElement{
	DLog(@"Start");
    
	NSArray *timeLayouts = [dataElement elementsForName:@"time-layout"];
	if ([timeLayouts count] == 0){
		[self bubbleUpError:@"HourlyForecastDataModelErrorDomain" code:3 errorString:@"Unable to extract NOAA time data"];
		return;
	}
	DDXMLElement *timeLayout = [timeLayouts objectAtIndex:0];

	// Read time layout key
	NSArray *elements = [timeLayout elementsForName:@"layout-key"];
	if ([elements count] == 0){
		[self bubbleUpError:@"HourlyForecastDataModelErrorDomain" code:3 errorString:@"Unable to extract NOAA time data"];
		return;
	}
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSUInteger components = (NSDayCalendarUnit | NSHourCalendarUnit | NSWeekdayCalendarUnit);
	
	//NSString *key = [[elements objectAtIndex:0] stringValue];
	
	// Read all time periods
	NSArray *timePeriods = [timeLayout elementsForName:@"start-valid-time"];
	self.hourlyForecast = [[NSMutableArray alloc]initWithCapacity:timePeriods.count];
	HourForecast *hourForecast = nil;
	NSString *timeDateString = nil;
	Period *period = nil;
	
	DLog(@"Num of time period elements: %d",timePeriods.count);
	for (DDXMLElement *timePeriod in timePeriods){
		hourForecast = [[HourForecast alloc]init];
		[self.hourlyForecast addObject:hourForecast];
		 
		timeDateString = [timePeriod stringValue];
		hourForecast.period = [[Period alloc] init];
		hourForecast.period.date = [self parseTimeDateString:timeDateString];
		hourForecast.period.dateComponents = [calendar components:components fromDate:period.date];
		DLog(@"%@", hourForecast.period);

		[hourForecast release];
	}
	
	DLog(@"End");
}

- (void)parseTemperatures:(DDXMLElement *)parametersElement{
	DLog(@"Start");
    
	NSArray *temperatures = [parametersElement elementsForName:@"temperature"];
	if ([temperatures count] == 0){
		[self bubbleUpError:@"HourlyForecastDataModelErrorDomain" code:3 errorString:@"Unable to extract NOAA time data"];
		return;
	}
	DDXMLElement *temperature = [temperatures objectAtIndex:0];
	[self parseTemperatureElements:temperature];

	temperature = [temperatures objectAtIndex:1];
	[self parseTemperatureElements:temperature];

	
	DLog(@"End");
}

- (void)parseTemperatureElements:(DDXMLElement *)temperatureElement{
	DLog(@"Start");
	
	NSString *type = [[temperatureElement attributeForName:@"type"] stringValue];
    NSString *key = nil;
	
	if ([type isEqualToString:@"hourly"]){
		key = @"temperature";
	} else if ([type isEqualToString:@"dew point"]){
		key = @"dewPoint";
	}
	
	NSArray *elements = [temperatureElement elementsForName:@"value"];
	if ([elements count] == 0){
		[self bubbleUpError:@"HourlyForecastDataModelErrorDomain" code:3 errorString:@"Unable to extract NOAA time data"];
		return;
	}
	
	HourForecast *hourForecast = nil;
	NSUInteger i = 0;
	
	DLog(@"Num of temp elements: %d",elements.count);
	for (DDXMLElement *element in elements){
		hourForecast = [self.hourlyForecast objectAtIndex:i];
		[hourForecast setValue:[NSNumber numberWithInt:[[element stringValue]intValue]] forKey:key];
		i++;
	}
	
	DLog(@"End");
}

- (void)parseHumdity:(DDXMLElement *)parametersElement{
	DLog(@"Start");
    
	NSArray *humidities = [parametersElement elementsForName:@"humidity"];
	if ([humidities count] == 0){
		[self bubbleUpError:@"HourlyForecastDataModelErrorDomain" code:3 errorString:@"Unable to extract NOAA time data"];
		return;
	}
	DDXMLElement *humidity = [humidities objectAtIndex:0];
	
	// Read time layout key
	NSArray *elements = [humidity elementsForName:@"value"];
	if ([elements count] == 0){
		[self bubbleUpError:@"HourlyForecastDataModelErrorDomain" code:3 errorString:@"Unable to extract NOAA time data"];
		return;
	}
	
	HourForecast *hourForecast = nil;
	NSUInteger i = 0;
	
	DLog(@"Num of humidity elements: %d",elements.count);
	for (DDXMLElement *element in elements){
		hourForecast = [self.hourlyForecast objectAtIndex:i];
		hourForecast.percentHumidity = [[element stringValue]intValue];
		DLog(@"humidity: %d", hourForecast.percentHumidity);
		i++;
	}
	
	DLog(@"End");
}

- (NSDate *)parseTimeDateString:(NSString *)timeDateString{
	NSMutableString *mutableTimeDateString = [[NSMutableString alloc] initWithString:timeDateString];
	[mutableTimeDateString insertString:@"GMT" atIndex:19];
	NSDate *date = [dateFormatter dateFromString:mutableTimeDateString];
	[mutableTimeDateString release];
	DLog(@"%@",date);
	
	return date;
}

- (void)parseValues:(DDXMLElement *)valuesElement{
	DLog(@"Start");

	NSArray *elements = [valuesElement elementsForName:@"value"];
	if ([elements count] == 0){
		[self bubbleUpError:@"HourlyForecastDataModelErrorDomain" code:3 errorString:@"Unable to extract NOAA time data"];
		return;
	}
	
	DLog(@"Num of elements: %d",elements.count);
	for (DDXMLElement *element in elements){
		DLog(@"Value: %@", [element stringValue]);
	}
	
	DLog(@"End");
}

- (void)refresh{
	[super refresh];
	self.hourlyForecast = [[NSMutableArray alloc]init];
}

@end
