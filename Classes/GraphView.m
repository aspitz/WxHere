//
//  GraphView.m
//  WxNow
//
//  Created by Ayal Spitz on 7/15/10.
//  Copyright 2010 MITRE Corp. All rights reserved.
//

#import "GraphView.h"
#import "HourForecast.h"


@implementation GraphView

@synthesize debug;

@synthesize strokeGraph;
@synthesize graphStrokeColor;
@synthesize graphLineWidth;

@synthesize xAxisLabel;
@synthesize xAxisLabelFormat;
@synthesize xAxisLabelCount;
@synthesize xAxisLabelFont;
@synthesize xAxisLabelColor;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])) {
		dataArray = nil;
		
		self.debug = NO;
		
		self.strokeGraph = YES;
		self.graphStrokeColor = [UIColor blackColor].CGColor;
		self.graphLineWidth = 2.0;
		
		self.xAxisLabel = YES;
		self.xAxisLabelFormat = @"%d";
		self.xAxisLabelCount = 0;
		self.xAxisLabelFont = [UIFont systemFontOfSize:12];
		self.xAxisLabelColor = [UIColor blackColor].CGColor;
    }
    return self;
}

- (void)dealloc {
	if (dataArray != nil){
		free(dataArray);
	}

    [super dealloc];
}

- (void)setDataFromArray:(NSArray *)srcArray withKeyPath:(NSString *)keyPath
			startAtIndex:(NSUInteger)startIndex withLength:(NSUInteger)len{
	
	[srcArray retain];
	
	dataMax = -100;
	dataMin = 200;
	dataLen = len;
	
	if (dataArray != nil){
		free(dataArray);
	}
	dataArray = malloc(sizeof(CGPoint) * len);
	
	id obj;
	NSInteger element = 0;
	
	for (int i=0; i <= len; i++){
		obj = [srcArray objectAtIndex:i + startIndex];
		element = [[obj valueForKeyPath:keyPath] intValue];
		//DLog(@"[%d] temp: %d", i, element);
		
		if (element > dataMax){
			dataMax = element;
		}
		if (element < dataMin){
			dataMin = element;
		}
		
		dataArray[i] = CGPointMake(i, element);
		//DLog(@"(%f, %f)", dataArray[i].x, dataArray[i].y);
	}
	
	[srcArray release];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Set default values
	CGContextSetLineWidth(context, 1.0);
	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	
	// Transform drawing to ensure sharp drawing
	CGContextTranslateCTM(context, 0.5, 0.5);
	
	// If debuging draw red bounding box
	if (self.debug){
		CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
		CGContextStrokeRect(context, rect);
		CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	}
	
	// Draw x axis labels
	NSUInteger maxLabelWidth = 0;
	if (self.xAxisLabel){
		maxLabelWidth = [self drawXAxisLabels:context viewSize:rect.size];
	}
	
	CGRect graphRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - maxLabelWidth, rect.size.height - 1);
	
	double xScale = 0.0, yScale = 0.0;
	
	if (dataArray != nil){
		xScale = (graphRect.size.width / dataLen);
		yScale = (graphRect.size.height - 20) / (dataMax - dataMin);

		CGPoint pt;
		
		// Create graph shapes
		// Start by creating the open path of the graph
		CGMutablePathRef graphShape = CGPathCreateMutable();
		
		for (int i=0; i <= dataLen; i++){
			pt = dataArray[i];			
			pt.x *= xScale;
			pt.y = graphRect.size.height - ((pt.y - dataMin) * yScale + 10);

			if (i == 0){
				CGPathMoveToPoint(graphShape, NULL, pt.x, pt.y); //start point
			} else {
				CGPathAddLineToPoint(graphShape, NULL, pt.x, pt.y); // end path
			}
		}
		
		// Copy the open graph path and make a closed shape of the area above the graph
		CGMutablePathRef aboveGraphShape = CGPathCreateMutableCopy(graphShape);
		
		CGPathAddLineToPoint(aboveGraphShape, NULL, pt.x, 0);
		CGPathAddLineToPoint(aboveGraphShape, NULL, 0, 0); // end path
		
		CGPathCloseSubpath(aboveGraphShape);
		
		// Copy the open graph path and make a closed shape of the area bellow the graph
		CGMutablePathRef bellowGraphShape = CGPathCreateMutableCopy(graphShape);
		
		CGPathAddLineToPoint(bellowGraphShape, NULL, pt.x, graphRect.size.height);
		CGPathAddLineToPoint(bellowGraphShape, NULL, 0, graphRect.size.height); // end path
		
		CGPathCloseSubpath(bellowGraphShape);
		
		// Paint the area bellow the graph in a light gray
		/*CGContextAddPath(context, bellowGraphShape);
		CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
		CGContextFillPath(context);*/
		
		// Draw hour lines
		CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
		CGContextSetLineWidth(context, 3.0); // this is set from now on until you explicitly change it		
		
		for (int i=0; i <= dataLen; i++){			
			//CGContextBeginPath(context);
			
			CGContextMoveToPoint(context, (int)(i * xScale), 0); //start point
			CGContextAddLineToPoint(context, (int)(i * xScale), graphRect.size.height); // end path
			
			CGContextSetLineWidth(context, 1.0); // this is set from now on until you explicitly change it		
			
			CGContextStrokePath(context); // do actual stroking
		}
		
		
		// Erase the hour lines above the graph by painting the area white
		CGContextAddPath(context, aboveGraphShape);
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
		CGContextFillPath(context);

		// Stroke the graph line
		if (self.strokeGraph){
			CGContextAddPath(context, graphShape);
			CGContextSetStrokeColorWithColor(context, self.graphStrokeColor);
			CGContextSetLineWidth(context, self.graphLineWidth);	
			CGContextStrokePath(context);

			CGContextSetLineWidth(context, 1.0);
		}
		
		// Stroke the bounding rect
		CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
		CGContextStrokeRect(context, graphRect);
		
		
		CGPathRelease(graphShape);
		CGPathRelease(aboveGraphShape);
		CGPathRelease(bellowGraphShape);
	}
}

- (NSUInteger)drawXAxisLabels:(CGContextRef)context viewSize:(CGSize)viewSize{
	NSMutableArray *labelArray = nil;
	NSUInteger maxLabelWidth = 0;
	NSInteger labelDataStep = 0;
	
	NSUInteger textWidth = 0;
	CGSize textSize;
	NSString *label = nil;
	
	if (self.xAxisLabelCount == 0){
		self.xAxisLabelCount = (viewSize.height - 20) / (self.xAxisLabelFont.pointSize + 2);
	}
	
	labelDataStep = ((dataMax - dataMin) / self.xAxisLabelCount);
	labelArray = [[NSMutableArray alloc]initWithCapacity:self.xAxisLabelCount];
	
	for (int i=0; i<self.xAxisLabelCount; i++){
		label = [NSString stringWithFormat:self.xAxisLabelFormat, (int)(dataMax - (i * labelDataStep))];
		[labelArray addObject:label];
		textSize = [label sizeWithFont:self.xAxisLabelFont];
		textWidth = textSize.width + 15;
		if (textWidth > maxLabelWidth){
			maxLabelWidth = textWidth;
		}
	}

	CGPoint pt;
	NSUInteger labelStep = ((viewSize.height - 20) / (self.xAxisLabelCount - 1));
	NSUInteger graphWidth = viewSize.width - maxLabelWidth;
	NSUInteger y = 0;
	
	for (int i=0; i<self.xAxisLabelCount; i++){
		y = (i * labelStep) + 10;
		
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, graphWidth, y);
		CGContextAddLineToPoint(context, graphWidth + 5, y);
		
		CGContextSetFillColorWithColor(context, xAxisLabelColor);
		
		CGContextStrokePath(context);
		label = [labelArray objectAtIndex:i];
		textSize = [label sizeWithFont:self.xAxisLabelFont];
		pt = CGPointMake(graphWidth + 10, y - (textSize.height / 2));
		[label drawAtPoint:pt withFont:self.xAxisLabelFont];
	}
	
	[labelArray release];
	
	return maxLabelWidth;
}

@end
