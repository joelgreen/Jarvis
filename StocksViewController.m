//
//  StocksViewController.m
//  Jarvis
//
//  Created by Joel Green on 1/25/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import "StocksViewController.h"
#import "ServerPostManger.h"

@interface StocksViewController ()
@property (weak, nonatomic) IBOutlet UITableView *stockTableView;
@property (weak, nonatomic) IBOutlet UITextField *textEntry;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UILabel *addStocksLabel;

@property (strong, nonatomic) NSMutableArray *stocks;
@property (strong, nonatomic) ServerPostManger *serverPostManager;

@property (weak, nonatomic) IBOutlet UILabel *bottomSolidLabel;
@end

@implementation StocksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.bottomSolidLabel.layer.borderWidth = 3;
    
    self.bottomSolidLabel.layer.borderColor = [UIColor colorWithRed:54/255.0f
                                                              green:59/255.0f
                                                               blue:63/255.0f
                                                              alpha:1].CGColor;
    self.bottomSolidLabel.backgroundColor = [UIColor colorWithRed:34/255.0f
                                                            green:34/255.0f
                                                             blue:34/255.0f
                                                            alpha:1];
    
    self.okButton.layer.cornerRadius = 0;
    self.okButton.layer.backgroundColor = [UIColor colorWithRed:241/255.0f
                                                   green:88/255.0f
                                                    blue:36/255.0f
                                                   alpha:1].CGColor;
    self.okButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
    
//    self.okButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:20];
    self.addStocksLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:22];
    self.textEntry.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
    self.addStocksLabel.textColor = [UIColor colorWithRed:225 green:225 blue:225 alpha:1];
    
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgcloud"]];
    self.stockTableView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    self.stockTableView.dataSource = self;
    self.stockTableView.delegate = self;
	// Do any additional setup after loading the view.
    [self.stockTableView reloadData];
}

- (ServerPostManger *)serverPostManager
{
    if (!_serverPostManager) {
        _serverPostManager = [[ServerPostManger alloc] init];
    }
    return _serverPostManager;
}

- (NSMutableArray *)stocks
{
    if (!_stocks) {
        _stocks = [[NSMutableArray alloc] init];
    }
    return _stocks;
}

- (IBAction)didSelectOK:(id)sender
{
    [self.serverPostManager sendStocks:self.stocks];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.text length]) {
        [self.stocks addObject:textField.text];
        textField.text = @"";
        [self.stockTableView reloadData];
    }
    NSLog(@"%@",self.stocks);
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%d",self.stocks.count);
    return self.stocks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Stocks Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Stocks Cell"];
    }
    cell.textLabel.text = [self.stocks objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
    NSLog(@"text: %@",[self.stocks objectAtIndex:indexPath.row]);

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


@end
