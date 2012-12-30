//
//  JenkinsJob.m
//  JenkinsStatus
//
//  Created by Alexey Linkov on 12/30/12.
//  Copyright (c) 2012 SDWR. All rights reserved.
//

#import "JenkinsJob.h"

@interface JenkinsJob () {
    
    NSString *bURL;
    
}

@property (nonatomic,retain) NSMutableData *receivedData;

@end

@implementation JenkinsJob

-(void)loadDetails:(NSString *)baseURL {
    
    bURL = baseURL;
    [self get:self.name];
    
}

- (void)get: (NSString *)urlString {
 	
    NSMutableData *dt = [[NSMutableData alloc] init];
 	self.receivedData = dt;
    [dt release];
 	
    NSURLRequest *request = [[NSURLRequest alloc]
 							 initWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@/job/%@/api/json",bURL,urlString]]
 							 cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
 							 timeoutInterval: 10
 							 ];
    
    NSURLConnection *connection = [[NSURLConnection alloc]
 								   initWithRequest:request
 								   delegate:self
 								   startImmediately:YES];

 	
 	[connection release];
    [request release];
    
}

-(void)parseJSON {
    
    NSError* errorInfo;
    NSDictionary *parsedJSON = [NSJSONSerialization JSONObjectWithData:self.receivedData options:kNilOptions error:&errorInfo];
    
    
    NSArray *jobs = [parsedJSON objectForKey:@"healthReport"];
    NSDictionary *health = [jobs objectAtIndex:0];
    
    self.healthImageURL = [NSString stringWithFormat:@"%@/images/48x48/%@",bURL,[health objectForKey:@"iconUrl"]];
}

// TODO: remove connection code from model
#pragma mark NSURLConnection delegate methods
- (NSURLRequest *)connection:(NSURLConnection *)connection
 			 willSendRequest:(NSURLRequest *)request
 			redirectResponse:(NSURLResponse *)redirectResponse {
    return request;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
 	
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.receivedData appendData:data];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    [[NSAlert alertWithError:error] runModal];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self parseJSON];
}


-(void)dealloc {
    
    [_receivedData release];
    [_status release];
    [_name release];
    [_healthImageURL release];
    
    [super dealloc];
    
}


@end
