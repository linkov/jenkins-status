//
//  JenkinsStatusView.m
//  JenkinsStatus
//
//  Created by Alexey Linkov on 12/29/12.
//  Copyright (c) 2012 SDWR. All rights reserved.
//

#define PADDING 100
#define TIGHTPADDINGTHERESHOLD 9
#define STATUSPADDING 100
#define PADDINGTIGHT 60
#define TEXTPADDING 200
#define TEXTH 25
#define TEXTVPADDING 10
#define TEXTW 300
#define CONTAINERVIEWX 750
#define CONTAINERVIEWY 500
#define CONTAINERVIEWW 500
#define ICONSIZE 48

NSString * const kModuleName = @"com.SDWR.jenkins_status";

#import "JenkinsStatusView.h"
#import "JenkinsService.h"
#import "JenkinsJob.h"

@interface JenkinsStatusView () {
    
    NSArray *jobs;
    NSTimer *timer;
    JenkinsService *serv;
    NSView *containerView;
}

@property (assign) IBOutlet NSPanel *optionsPanel;
@property (assign) IBOutlet NSTextField *jenkinsURLField;

@end

@implementation JenkinsStatusView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
        jobs = [NSArray new];
        
        ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:kModuleName];
        NSString *jenkinsURL = [defaults objectForKey:@"JenkinsURLString"];
        if (jenkinsURL.length>0) {
            
           
            
            serv = [[JenkinsService alloc]initWithBaseURL:jenkinsURL];
            serv.delegate = self;
            [serv getBase];
            
            timer = [NSTimer scheduledTimerWithTimeInterval: 10
                                                     target: self
                                                   selector: @selector(pullJenkins)
                                                   userInfo: nil
                                                    repeats: YES];
        }

        
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}


// TODO: move the list around the screen with 50 sec interval to prevent ghosting issues
- (void)animateOneFrame
{

    if (jobs.count >0) {
        
         containerView = [[NSView alloc]initWithFrame:NSMakeRect([self bounds].size.width/2-CONTAINERVIEWW/2,[self bounds].size.height/2,CONTAINERVIEWW,jobs.count*PADDING)];
        
        for (int i =0; i<jobs.count; i++) {
            
            int dynamicStatusPadding = jobs.count<=TIGHTPADDINGTHERESHOLD ? PADDING : PADDINGTIGHT;
            
            JenkinsJob *j = [jobs objectAtIndex:i];
            
            NSImage *statusImage = [[NSImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:j.status ]]];
            
            NSImageView *statusImageView = [[NSImageView alloc] initWithFrame: NSMakeRect(0,0+(dynamicStatusPadding*i),ICONSIZE,ICONSIZE)];
            statusImageView.image = statusImage;
            [statusImage release];
            
            
            NSImage *image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:j.healthImageURL]]];
            
            NSImageView *bgImageView = [[NSImageView alloc] initWithFrame: NSMakeRect(STATUSPADDING,0+(dynamicStatusPadding*i),ICONSIZE,ICONSIZE)];
            bgImageView.image = image;
            [image release];
            
            NSTextView *text = [[NSTextView alloc]initWithFrame:NSMakeRect(TEXTPADDING,0+(dynamicStatusPadding*i)+TEXTVPADDING,TEXTW,TEXTH)];
            text.font = [NSFont systemFontOfSize:20];
            text.string = j.name;
            text.backgroundColor = [NSColor blackColor];
            text.textColor = [NSColor whiteColor];
            

            [containerView addSubview:text];
            [containerView addSubview:bgImageView];
            [containerView addSubview:statusImageView];
            [statusImageView release];
            [bgImageView release];
            [text release];
        }
        
        [self addSubview:containerView];
    }


    
    return;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    if (!self.optionsPanel) {
        ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:kModuleName];
        NSString *jenkinsURL = [defaults objectForKey:@"JenkinsURLString"];
        if (jenkinsURL.length>0) {
            
            self.jenkinsURLField.stringValue = jenkinsURL;
        }
        [NSBundle loadNibNamed:@"SettingsPanel" owner:self];
    }
    return self.optionsPanel;
}


- (IBAction)closeConfig:(id)sender
{
    [[NSApplication sharedApplication] endSheet:self.optionsPanel];
    
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:kModuleName];
    [defaults setObject:self.jenkinsURLField.stringValue forKey:@"JenkinsURLString"];
    [defaults synchronize];
    
    serv = [[JenkinsService alloc]initWithBaseURL:self.jenkinsURLField.stringValue];
    serv.delegate = self;
    [serv getBase];

}

- (void) pullJenkins
{
    [containerView removeFromSuperview];
    containerView = nil;
	[serv getBase];
}


-(void)dealloc {
    
    [jobs release];
    [serv release];
    
    [super dealloc];
}




@end
