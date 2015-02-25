# TXLayoutView
iOS를 위한 안드로이드 스타일의 가변 레이아웃

```objective-c
#import "YourInfoView.h"

@implementation YourInfoView

deflayout
    vertical_layout(ref : @"@mainView", width : @"wrap_content", height : @"wrap_content")
        vertical_layout(width : @"wrap_content", height : @"wrap_content", align : @"left center right center_vertical center ")
            label(ref : @"@titleLabel", width : @"wrap_content", height : @(50), @"text" : @"@nickname", marginLeft : @(10), @"hidden" : @"@isShow")
            label(width : @(200), height : @(20), @"text" : @"hi")
        endlayout
        horizontal_layout(width : @"match_parent", height : @"wrap_content", @"background" : @"sample.png", align : @"right bottom center center_vertical")
            label(width : @"@width", height : @(50), @"text" : @"cccc")
            label(width : @"wrap_content", height : @"wrap_content", @"text" : @"111111", marginLeft : @(20))
        endlayout
        label(width : @"wrap_content", height : @"wrap_content", @"text" : @"dddddd")
        horizontal_layout(width : @"match_parent", height : @"wrap_content", align : @"right")
            label(width : @"wrap_content", height : @"wrap_content", @"text" : @"ttt")
            label(width : @"wrap_content", height : @"wrap_content", @"text" : @"123123", marginLeft : @(50), marginTop : @(10), marginRight : @(5))
        endlayout
        button(ref : @"@button1", width : @"match_parent", height : @(30), @"text" : @"테스트1")
        button(ref : @"@button2", width : @"match_parent", height : @(30), @"text" : @"테스트2", marginTop : @(10))
    endlayout
enddef

- (UIColor *)bgColor {
    return [UIColor redColor];
}

@end
```
