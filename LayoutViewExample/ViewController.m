//
//  ViewController.m
//  LayoutViewExample
//
//  Created by eunmin on 2014. 4. 21..
//  Copyright (c) 2014년 lab335. All rights reserved.
//

#import "ViewController.h"
#import "YourInfoView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (nonatomic, strong) YourInfoView *yourInfoView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.yourInfoView = [[YourInfoView alloc] initWithFrame:CGRectMake(0, 20, 320, 320)];
    _yourInfoView.backgroundColor = [UIColor lightGrayColor];
    _yourInfoView.nickname = @"기본값";
    _yourInfoView.width = @(50);
    
//    NSLog(@"button1 : %@", _yourInfoView.button1);
//    NSLog(@"change button : %@", self.changeButton);
    
    
    [_yourInfoView.button2 addTarget:self action:@selector(clickButton2:) forControlEvents:UIControlEventTouchUpInside];
    [_yourInfoView.button1 addTarget:self action:@selector(clickButton1:) forControlEvents:UIControlEventTouchUpInside];

//    [_yourInfoView sizeToFit];
    [self.view addSubview:_yourInfoView];
    
//    NSLog(@"main view : %@", _yourInfoView.mainView);
}

- (void)clickButton1:(UIButton *)btn {
    _yourInfoView.isShow = !_yourInfoView.isShow;
}

- (void)clickButton2:(UIButton *)btn {
    NSLog(@"button2 click");
}

- (IBAction)changeText:(id)sender {
    self.yourInfoView.nickname = @"바뀐값 값 크기도 바켜라!!!!";
    self.yourInfoView.width = @(300);
    [self.yourInfoView.button1 setTitle:@"버튼1" forState:UIControlStateNormal];
}

@end
