//
//  AboutViewController.m
//  WxHere
//
//  Created by Ayal Spitz on 9/25/09.
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

#import "AboutViewController.h"


@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIWebView *webView = (UIWebView *)(self.view);
	
	NSString *appVer = [NSString stringWithFormat:@"%@",
						[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
	
	NSString *imagePath = [[NSBundle mainBundle] resourcePath];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
	NSString *htmlStr = [[NSString alloc] initWithContentsOfFile:filePath
														encoding:NSASCIIStringEncoding
														   error:nil];
	
	NSString *modHtmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"VERSION" withString:appVer];
	NSData *htmlData = [modHtmlStr dataUsingEncoding:NSASCIIStringEncoding];
	[htmlStr release];
	
	if (htmlData) {
		NSString *urlString = [[NSString alloc] initWithFormat:@"file:/%@//",imagePath];
		NSURL *url = [[NSURL alloc] initWithString:urlString];
		
		[webView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:url];
		
		[url release];
		[urlString release];
	}
}

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning{
	DLog(@"memory warning");
	[super didReceiveMemoryWarning];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
	navigationType:(UIWebViewNavigationType)navigationType {
	
	NSURL *requestURL = request.URL;
	
	if (requestURL.isFileURL){
		return YES;
	} else {
		[[UIApplication sharedApplication] openURL:requestURL];
		return NO;
	}
}

@end
