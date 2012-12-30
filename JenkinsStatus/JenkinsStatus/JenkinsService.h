//
//  JenkinsService.h
//  JenkinsStatus
//
//  Created by Alexey Linkov on 12/29/12.
//  Copyright (c) 2012 SDWR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JenkinsService : NSObject <NSURLConnectionDelegate>

- (void)getBase;
-(id)initWithBaseURL:(NSString *)url;

@property (assign) id delegate;

@end
