//
//  WxHereAppDelegate.h
//  WxHere
//
//  Created by Ayal Spitz on 5/8/09.
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

@class WxDataModel;

@interface WxHereAppDelegate : NSObject <UIApplicationDelegate> {
	WxDataModel *wxDataModel;

    UIWindow *window;
	UITabBarController *tabBarController;
}

@property (nonatomic, retain) WxDataModel *wxDataModel;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

- (void)addNotificationObservers;
- (NSString *)applicationDocumentsDirectory;

@end

