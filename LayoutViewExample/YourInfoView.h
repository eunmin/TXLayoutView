#import <UIKit/UIKit.h>
#import "TXLayoutView.h"

@interface YourInfoView : TXLayoutView

@property (nonatomic, readonly) UIView *mainView;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, readonly) UIButton *button1;
@property (nonatomic, readonly) UIButton *button2;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic) BOOL isShow;

@end
