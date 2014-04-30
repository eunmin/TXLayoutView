//
//  YourInfoView.h
//  LayoutViewExample
//
//  Created by eunmin on 2014. 4. 21..
//  Copyright (c) 2014년 lab335. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXLayoutView.h"

@interface YourInfoView : TXLayoutView

@property (nonatomic, strong) NSString *nickname;
@property (nonatomic) CGFloat width;
@property (nonatomic, readonly) UIButton *button1;
@property (nonatomic, readonly) UIButton *button2;

@end
