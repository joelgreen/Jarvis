//
//  JarvisViewController.m
//  Jarvis
//
//  Created by Joel Green on 1/24/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import "JarvisViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LocationManager.h"
#import "ServerPostManger.h"

@interface JarvisViewController ()

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITextView *mainTextView;
@property (strong, nonatomic) LocationManager *locationManager;
@property (strong, nonatomic) ServerPostManger *serverPostManager;

@end

@implementation JarvisViewController



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

- (IBAction)connectButtonPressed:(id)sender
{
    NSDictionary *reqDict = @{@"latitude": @34.01, @"longitude" : @-118.5, @"user" : [self.serverPostManager uuid]};
    [self.serverPostManager requestCards:reqDict];
    
//    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 [self uuid], @"id",@"b", @"password", nil];
//    
//    NSMutableURLRequest *request = [self generateUrlRequest:@"http://jarvisupdate.com/CreateUser.php"
//                                                          withDictionary:requestDict];
//    
//    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
//    if(conn) {
//        NSLog(@"Connection Successful in connectButtonPressed");
//    }
//    else {
//        NSLog(@"Connection could not be made in connectButtonPressed");
//    }

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
    
    self.view.backgroundColor = [UIColor redColor];
//    [self animate];
    
    self.mainTextView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
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
    
//    [self.serverPostManager createUser];
    
//    NSLog(@"%f",AVSpeechUtteranceDefaultSpeechRate);
}

- (void)incomingData:(NSNotification *)notification
{
    self.mainTextView.text = [self.serverPostManager.incoming objectForKey:@"human"];
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

@end
