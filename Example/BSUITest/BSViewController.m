//
//  BSViewController.m
//  BSUITest
//
//  Created by vviicc on 05/26/2018.
//  Copyright (c) 2018 vviicc. All rights reserved.
//

#import "BSViewController.h"

@interface BSViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation BSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)add:(id)sender {
    self.resultLabel.text = [@(self.textField1.text.intValue + self.textField2.text.intValue) stringValue];
    
    [self.view endEditing:NO];
}

- (IBAction)clear:(id)sender {
    self.textField1.text = nil;
    self.textField2.text = nil;
    self.resultLabel.text = nil;
    
    [self.view endEditing:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
