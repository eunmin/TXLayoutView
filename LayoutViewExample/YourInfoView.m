#import "YourInfoView.h"

@implementation YourInfoView

deflayout
    virtical_layout(ref = @mainView, width = "match_parent", height = "wrap_content")
        horizontal_layout(width = "match_parent", height = "wrap_content", align = "center")
            label(ref = @titleLabel, width = "wrap_content", height = 50, text = @nickname, marginLeft = 10, hidden = @isShow)
        endlayout
        horizontal_layout(width = "match_parent", height = "wrap_content", background = "sample.png", align = "center")
            label(width = @width, height = 50, text = "cccc")
            label(width = "wrap_content", height = "wrap_content", text = "111111", marginLeft = 20, marginBottom = 10)
        endlayout
        label(width = "wrap_content", height = "wrap_content", text = "dddddd")
        horizontal_layout(width = "match_parent", height = "wrap_content", align = "right")
            label(width = "wrap_content", height = "wrap_content", text = "ttt")
            label(width = "wrap_content", height = "wrap_content", text = "123123", marginLeft = 50, marginTop = 10, marginRight = 5)
        endlayout
        button(ref = @button1, width = "match_parent", height = 30, text = "테스트1")
        button(ref = @button2, width = "match_parent", height = 30, text = "테스트2", background = "eunmin.png", marginTop = 10)
    endlayout
enddef

@end
