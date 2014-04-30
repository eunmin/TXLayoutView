//
//  YourInfoView.m
//  LayoutViewExample
//
//  Created by eunmin on 2014. 4. 21..
//  Copyright (c) 2014년 lab335. All rights reserved.
//

#import "YourInfoView.h"

@interface YourInfoView()

@end

@implementation YourInfoView

deflayout
    layout(orientation = "virtical", width = "match_parent", height = 200)
        label(width = "wrap_content", height = 50, text = @nickname)
        layout(orientation = "horizontal", width = "match_parent", height = "wrap_content", background = "sample.png")
            label(width = @width, height = 50, text = "cccc")
            label(width = "wrap_content", height = "wrap_content", text = "111111")
        endlayout
        label(width = "wrap_content", height = "wrap_content", text = "dddddd")
        label(width = "match_parent", height = "wrap_content", text = "ttt")
        label(width = "wrap_content", height = 50, text = "123123")
        button(ref = @button1, width = "match_parent", height = 30, text = "테스트1")
        button(ref = @button2, width = "match_parent", height = 30, text = "테스트2", background = "eunmin.png")
    endlayout
enddef


// TODO : KVO로 리펙토링이 필요함
- (void)setNickname:(NSString *)nickname {
    for (id propertyView in [self viewsForProperty:@"nickname"]) {
        [self setProperty:nickname forKey:propertyView[@"key"] to:propertyView[@"view"]];
    }
    [self setNeedsDisplay];
}

- (void)setWidth:(CGFloat)width {
    for (id propertyView in [self viewsForProperty:@"width"]) {
        [self setProperty:@(width) forKey:propertyView[@"key"] to:propertyView[@"view"]];
    }
    [self setNeedsDisplay];
}

@end
