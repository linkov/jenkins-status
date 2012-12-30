//
//  JenkinsJob.h
//  JenkinsStatus
//
//  Created by Alexey Linkov on 12/30/12.
//  Copyright (c) 2012 SDWR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JenkinsJob : NSObject

@property(nonatomic,retain) NSString *status;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *healthImageURL;

-(void)loadDetails:(NSString *)baseURL;

@end
