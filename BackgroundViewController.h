//
//  BackgroundViewController.h
//  Jarvis
//
//  Created by Joel Green on 1/26/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackgroundViewController : UIViewController
{
    BOOL isRaining;
    NSInteger rainSpots[4];
    BOOL rained[4];
    int lastRained;
}
//@property (weak, nonatomic) IBOutlet UIButton *theCloud;
@property (strong, nonatomic) UIImageView *theCloud;
@property (strong, atomic) UIImageView *theRaindrop;
//- (IBAction)pushed:(id)sender;

@end
