//
//  JarvisViewController.m
//  Jarvis
//
//  Created by Joel Green on 1/24/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import "JarvisViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "LocationManager.h"
#import "ServerPostManger.h"

@interface JarvisViewController ()

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITextView *mainTextView;
@property (strong, nonatomic) LocationManager *locationManager;
@property (strong, nonatomic) ServerPostManger *serverPostManager;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSDate *time;
@property (strong, nonatomic) NSTimer *updateTimer;

@property (weak, nonatomic) IBOutlet UILabel *jarvisLabel;


@property (weak, nonatomic) IBOutlet UIButton *alarmButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;


@end

@implementation JarvisViewController


-(NSDate *)time
{
    if (!_time) {
        _time = [[NSDate alloc] init];
    }
    _time = [NSDate date];
    return _time;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (NSString *)uuid
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"uuid"]) {
        return [defaults objectForKey:@"uuid"];
    } else {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        
        [defaults setObject:uuidStr forKey:@"uuid"];
        [defaults synchronize];
        return uuidStr;
    }
}

- (void)updateTime
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setTimeStyle:NSDateFormatterMediumStyle];
    self.timeLabel.text = [f stringFromDate:self.time];
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateTime) userInfo:Nil repeats:NO];
}

- (IBAction)connectButtonPressed:(id)sender
{
    NSDictionary *reqDict = @{@"latitude": @34.01, @"longitude" : @-118.5, @"user" : [self.serverPostManager uuid]};
    [self.serverPostManager requestCards:reqDict];
}

- (IBAction)startButtonPressed:(id)sender {
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.mainTextView.text];
    utterance.rate = 0.3;
    AVSpeechSynthesizer *syn = [[AVSpeechSynthesizer alloc] init];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-au"];
    [syn speakUtterance:utterance];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.jarvisLabel.font = [UIFont fontWithName:@"Neou-Thin" size:50];
    self.jarvisLabel.textColor = [UIColor colorWithRed:241/255.0f
                                                 green:88/255.0f
                                                  blue:36/255.0f
                                                 alpha:1];
    
    self.timeLabel.font = [UIFont fontWithName:@"GillSans-Light" size:50];
    self.timeLabel.textColor = [UIColor colorWithRed:255/255.0f
                                               green:255/255.0f
                                                blue:255/255.0f
                                               alpha:1];
    
    self.mainTextView.textColor = [UIColor colorWithRed:255/255.0f
                                                  green:255/255.0f
                                                   blue:255/255.0f
                                                  alpha:1];
    self.mainTextView.font = [UIFont fontWithName:@"Roboto-Regular" size:14];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgcloud"]];
    
    self.mainTextView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    
    
    self.bottomLabel.layer.borderWidth = 3;
    
    self.bottomLabel.layer.borderColor = [UIColor colorWithRed:54/255.0f
                                                              green:59/255.0f
                                                               blue:63/255.0f
                                                              alpha:1].CGColor;
    self.bottomLabel.backgroundColor = [UIColor colorWithRed:34/255.0f
                                                            green:34/255.0f
                                                             blue:34/255.0f
                                                            alpha:1];
    
    self.alarmButton.layer.cornerRadius = 0;
    self.alarmButton.layer.backgroundColor = [UIColor colorWithRed:241/255.0f
                                                          green:88/255.0f
                                                           blue:36/255.0f
                                                          alpha:1].CGColor;
    self.alarmButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
    
    self.settingsButton.layer.cornerRadius = 0;
    self.settingsButton.layer.backgroundColor = [UIColor colorWithRed:204/255.0f
                                                             green:204/255.0f
                                                              blue:204/255.0f
                                                             alpha:1].CGColor;
    self.settingsButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
    
    _serverPostManager = [[ServerPostManger alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedLocation:)
                                                 name:@"Location Updated"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(incomingData:)
                                                 name:@"Incoming Data"
                                               object:nil];
    
    _locationManager = [[LocationManager alloc] init];
    [self.locationManager updateLocation];
    [self updateTime];
//    [self.serverPostManager createUser];
    
//    NSLog(@"%f",AVSpeechUtteranceDefaultSpeechRate);
    
    [self playSoundNamed:@"Perspectives"];
    
    
    NSDictionary *reqDict = @{@"latitude": @34.01, @"longitude" : @-118.5, @"user" : [self.serverPostManager uuid]};
    [self.serverPostManager requestCards:reqDict];
}

- (void)incomingData:(NSNotification *)notification
{
    self.mainTextView.text = [self.serverPostManager.incoming objectForKey:@"human"];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.mainTextView.text];
    utterance.rate = 0.3;
    AVSpeechSynthesizer *syn = [[AVSpeechSynthesizer alloc] init];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-au"];
    [syn speakUtterance:utterance];
}

- (void)animate
{
    [UIView animateWithDuration:3
                     animations:^{self.view.backgroundColor = [self randomColor];}
                     completion:^(BOOL finished){[self animate];}];
}

- (UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [_audioPlayer stop];
}

- (void)updatedLocation:(NSNotification *)notification
{
    NSNumber *lat = [NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude];
    
//    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 [ServerPostManger uuid], @"user",lat, @"latitude",lon,@"longitude", nil];
    
//    NSDictionary *re = [NSDictionary dictionaryWithObjectsAndKeys:lat, @"lat",lon,@"long", nil];
    
//    [ServerPostManger requestCards:re];
    
    NSLog(@"location: %@,%@",lat,lon);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableURLRequest *)generateUrlRequest:(NSString *)urlString withDictionary:(NSDictionary *)dictionary
{
    NSMutableString *dataString = [[NSMutableString alloc] init];
    NSArray *keyArray = [dictionary allKeys];
    for (NSString *key in keyArray) {
        [dataString appendString:[NSString stringWithFormat:@"%@=%@&",key,[dictionary valueForKey:key]]];
    }
    //removes trailing &
    [dataString deleteCharactersInRange:NSMakeRange([dataString length]-1,1)];
    
    NSLog(@"%@",dataString); //for debugging
    
    NSData *postData = [dataString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    return request;
}

- (void)playSoundNamed:(NSString *)sound
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:sound
                                         ofType:@"m4a"]];
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc]
                    initWithContentsOfURL:url
                    error:&error];
    
    if (error)
    {       
        NSLog(@"Error in audioPlayer: %@",
              [error localizedDescription]);
    } else {
        [_audioPlayer prepareToPlay];
    }
    
    [_audioPlayer play];
    
}

@end
