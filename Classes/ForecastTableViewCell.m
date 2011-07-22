//
//  ForecastTableViewCell.m
//  WxHere
//
//  Created by Ayal Spitz on 1/16/10.
//  Copyright (C) 2010 Ayal Spitz
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

#import "ForecastTableViewCell.h"


@implementation ForecastTableViewCell
@synthesize conditionLabel, forecastLabel;
@synthesize tempLabel, periodImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){}
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]){}
    return self;
}

- (void)dealloc {
	[conditionLabel release];
	[forecastLabel release];
	[tempLabel release];
	[periodImageView release];
    [super dealloc];
}

@end
