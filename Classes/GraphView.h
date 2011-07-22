//
//  GraphView.h
//  WxNow
//
//  Created by Ayal Spitz on 7/15/10.
//  Copyright 2010 MITRE Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GraphView : UIView {
	NSArray *data;
	
	CGPoint *dataArray;
	NSInteger dataMin;
	NSInteger dataMax;
	NSUInteger dataLen;
	
	BOOL debug;
	
	BOOL strokeGraph;
	CGColorRef graphStrokeColor;
	CGFloat graphLineWidth;
	
	BOOL xAxisLabel;
	NSString *xAxisLabelFormat;
	NSUInteger xAxisLabelCount;
	UIFont *xAxisLabelFont;
	CGColorRef xAxisLabelColor;
}

@property (assign) BOOL debug;

@property (assign) BOOL strokeGraph;
@property (assign) CGColorRef graphStrokeColor;
@property (assign) CGFloat graphLineWidth;

@property (assign) BOOL xAxisLabel;
@property (copy) NSString *xAxisLabelFormat;
@property (assign) NSUInteger xAxisLabelCount;
@property (retain) UIFont *xAxisLabelFont;
@property (assign) CGColorRef xAxisLabelColor;

- (void)setDataFromArray:(NSArray *)srcArray withKeyPath:(NSString *)keyPath 
			startAtIndex:(NSUInteger)startIndex withLength:(NSUInteger)len;

- (NSUInteger)drawXAxisLabels:(CGContextRef)context viewSize:(CGSize)viewSize;

@end
