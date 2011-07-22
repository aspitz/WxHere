//
//  NetDataModel.h
//  WxHere
//
//  Created by Ayal Spitz on 7/13/09.
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
#import "BasicDataModel.h"

@interface NetDataModel : BasicDataModel {
	NSURLRequest *urlRequest;
	NSMutableData *receivedData;
	BOOL retry;
}

@property (nonatomic, retain) NSURLRequest *urlRequest;
@property (retain) NSMutableData *receivedData;
@property (assign) BOOL retry;

- (void)connect:(NSString *)urlString;
- (void)retryConnection;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
