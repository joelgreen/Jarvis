//
//  BackgroundViewController.m
//  Jarvis
//
//  Created by Joel Green on 1/26/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import "BackgroundViewController.h"

#define ARC4RANDOM_MAX      0x100000000

@interface BackgroundViewController ()

@end

@implementation BackgroundViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tut1b.png"]];
    self.theCloud = [[UIImageView alloc] initWithFrame:CGRectMake(130, 156, 60, 58)];
    UIImage *cloudIcon = [UIImage imageNamed:@"theCloud.png"];
    [self.theCloud setImage:cloudIcon];
    [self.view addSubview:self.theCloud];
    for (int i = 0; i < 4; i++) {
        rained[i] = false;
        rainSpots[i] = 132 + 9*i;
    }
    lastRained = 0;
    [self generateRaindrops];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) generateRaindrops {
    _theRaindrop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"raindrop.png"]];
    
    CGRect f = _theRaindrop.frame;
    f.origin.y = 197;
    int randX = arc4random() % 4;
    int spot = randX;
    while (rained[spot]) {
        spot = (spot + 1) % 4;
        if (spot == randX) {
            rained[0] = false;
            rained[1] = false;
            rained[2] = false;
            rained[3] = false;
            spot = (lastRained + 1) % 4;
        }
    }
    rained[spot] = true;
    lastRained = spot;
    f.origin.x = (float) rainSpots[spot];
    _theRaindrop.frame = f;
    
    [self.view addSubview:_theRaindrop];
    [self fallDown];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(generateRaindrops) userInfo:nil repeats:NO];
}

-(float) randFloatBetween:(float)low and:(float)high
{
    float diff = high - low;
    float ran = arc4random();
    return (((float) ran / ARC4RANDOM_MAX) * diff) + low;
}

-(void) fallDown {
    CGRect f = _theRaindrop.frame;
    f.origin.y += 500;
    float duration = [self randFloatBetween:1.5 and:2.1];
    //    float duration = 2.0;
    [UIView animateWithDuration:duration animations:^{
        _theRaindrop.frame = f;
    }];
}

@end
