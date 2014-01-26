//
//  IntroViewController.m
//  Jarvis
//
//  Created by Joel Green on 1/25/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import "IntroViewController.h"
#import "ServerPostManger.h"

#define ARC4RANDOM_MAX      0x100000000
#define RAIN_SPOTS 22

@interface IntroViewController ()
@property (weak, nonatomic) IBOutlet UIButton *weatherButton;
@property (weak, nonatomic) IBOutlet UIButton *letsGoButton;
@property (weak, nonatomic) IBOutlet UIButton *stocksButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UILabel *jarvisLabel;
@property (strong, nonatomic) IBOutlet UIButton *rssButton;
@property (weak, nonatomic) IBOutlet UILabel *bottomSolidLabel;

@property (strong, nonatomic) NSMutableDictionary *prefsDict;

@property (strong, nonatomic) ServerPostManger *serverPostManager;

@property (strong, nonatomic) UIImageView *theCloud;
@property (strong, atomic) UIImageView *theRaindrop;
@property (strong, atomic) UILabel *rainDropNumber;

@end

@implementation IntroViewController


NSInteger rainSpots[RAIN_SPOTS];
BOOL rained[RAIN_SPOTS];
int lastRained;

- (ServerPostManger *)serverPostManager
{
    if (!_serverPostManager) {
        _serverPostManager = [[ServerPostManger alloc] init];
    }
    return _serverPostManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)uuid
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    [defaults setObject:uuidStr forKey:@"uuid"];
    [defaults synchronize];
    return uuidStr;
}

- (IBAction)didPressLetsStartButton:(id)sender
{
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setObject:[self uuid] forKey:@"user"];
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    for (NSString *key in self.prefsDict){
        if ([self.prefsDict objectForKey:key]) {
            [keywords addObject:key];
        }
    }
    [requestDict setObject:keywords forKey:@"keywords[]"];
    [self.serverPostManager createUser:requestDict];
}

- (void)toggleButtonTap:(UIButton *)button forKey:(NSString *)key
{
    if ([self.prefsDict objectForKey:key]) {
        [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        button.layer.backgroundColor = [UIColor colorWithRed:255/255.0f
                                                                   green:255/255.0f
                                                                    blue:255/255.0f
                                                                   alpha:0.5].CGColor;
        [self.prefsDict setValue:NO forKey:key];
    }
    else {
        [self.prefsDict setValue:@1 forKey:key];
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.backgroundColor = [UIColor colorWithRed:0/255.0f
                                                                   green:0/255.0f
                                                                    blue:0/255.0f
                                                                   alpha:0.5].CGColor;
    }
}

- (IBAction)didTapWeatherButton:(id)sender
{
    [self toggleButtonTap:self.weatherButton forKey:@"weather"];
}

- (IBAction)didTapStocksButton:(id)sender
{
    [self toggleButtonTap:self.stocksButton forKey:@"stocks"];

}

- (IBAction)didTapEmailButton:(id)sender
{
    [self toggleButtonTap:self.emailButton forKey:@"email"];

}

- (IBAction)didTapRSSbutton:(id)sender
{
    [self toggleButtonTap:self.rssButton forKey:@"rss"];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];

    for (int i = 0; i < RAIN_SPOTS; i++) {
        rained[i] = false;
        rainSpots[i] = 44 + 10*i;
    }
    lastRained = 0;
    [self generateBinaryRaindrops];
//    for (NSString* family in [UIFont familyNames])
//    {
//        NSLog(@"%@", family);
//        
//        for (NSString* name in [UIFont fontNamesForFamilyName: family])
//        {
//            NSLog(@"  %@", name);
//        }
//    }
    self.prefsDict = [[NSMutableDictionary alloc] init];
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:52/255.0f
                                                                        green:152/255.0f
                                                                         blue:219/255.0f
                                                                        alpha:1];
    self.title = @"Title";
    
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgcloud"]];
    
    [self setButtonAttributes:self.weatherButton];
    [self setButtonAttributes:self.stocksButton];
    [self setButtonAttributes:self.emailButton];
    [self setButtonAttributes:self.rssButton];
    
    self.jarvisLabel.font = [UIFont fontWithName:@"Neou-Thin" size:50];
    self.jarvisLabel.textColor = [UIColor colorWithRed:241/255.0f
                                                 green:88/255.0f
                                                  blue:36/255.0f
                                                 alpha:1];
    
    self.bottomSolidLabel.layer.borderWidth = 3;
    
    self.bottomSolidLabel.layer.borderColor = [UIColor colorWithRed:54/255.0f
                                               green:59/255.0f
                                                blue:63/255.0f
                                               alpha:1].CGColor;
    self.bottomSolidLabel.backgroundColor = [UIColor colorWithRed:34/255.0f
                                                            green:34/255.0f
                                                             blue:34/255.0f
                                                            alpha:1];
    
//    self.view.backgroundColor = [UIColor blueColor];
}

- (void)setButtonAttributes:(UIButton *)button
{
    button.layer.cornerRadius = 0;
//    button.layer.backgroundColor = [UIColor colorWithRed:52/255.0f
//                                                               green:152/255.0f
//                                                                blue:219/255.0f
//                                                               alpha:0].CGColor;
    button.layer.backgroundColor = [UIColor colorWithRed:255/255.0f
                                               green:255/255.0f
                                                blue:255/255.0f
                                               alpha:0.5].CGColor;
    button.layer.borderWidth = 0;
    button.layer.borderColor = [UIColor colorWithRed:255/255.0f
                                                           green:255/255.0f
                                                            blue:255/255.0f
                                                           alpha:0.5].CGColor;
}

- (void)setLetsGoButton:(UIButton *)button
{
    button.layer.cornerRadius = 0;
    button.layer.backgroundColor = [UIColor colorWithRed:241/255.0f
                                                   green:88/255.0f
                                                    blue:36/255.0f
                                                   alpha:1].CGColor;
    button.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
    
//    button.layer.borderWidth = 1;
//    button.layer.borderColor = [UIColor colorWithRed:44/255.0f
//                                               green:62/255.0f
//                                                blue:80/255.0f
//                                               alpha:1].CGColor;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - rain

-(void) generateBinaryRaindrops
{
    _rainDropNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 15)   ];
    if (((int)arc4random())%2) {
        _rainDropNumber.text = @"1";
    } else {
        _rainDropNumber.text = @"0";
    }
    CGRect f = _rainDropNumber.frame;
    f.origin.y = 126;
    int randX = arc4random() % RAIN_SPOTS;
    int spot = randX;
    while (rained[spot]) {
        spot = (spot + 1) % RAIN_SPOTS;
        if (spot == randX) {
            for (int i = 0; i < RAIN_SPOTS; i++) {
                rained[i] = false;
            }
            spot = (lastRained + 1) % RAIN_SPOTS;
        }
    }
    
    rained[spot] = true;
    lastRained = spot;
    f.origin.x = (float) rainSpots[spot];
    _rainDropNumber.frame = f;
    
    [self.view insertSubview:_rainDropNumber belowSubview:self.weatherButton];
    [self fallDown];
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(generateBinaryRaindrops) userInfo:nil repeats:NO];
}

-(float) randFloatBetween:(float)low and:(float)high
{
    float diff = high - low;
    float ran = arc4random();
    return (((float) ran / ARC4RANDOM_MAX) * diff) + low;
}

-(void) fallDown {
    CGRect f = _rainDropNumber.frame;
    f.origin.y += 500;
    float duration = [self randFloatBetween:1.5 and:2.1];
    //    float duration = 2.0;
    [UIView animateWithDuration:duration animations:^{
        _rainDropNumber.frame = f;
    }];
}

@end
