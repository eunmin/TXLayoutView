#import <Foundation/Foundation.h>

#define deflayout \
- (id)initWithFrame:(CGRect)rect { \
self = [super initWithFrame:rect]; \
if(self) { [self initTXLayout]; } \
return self; \
} \
- (void)drawRect:(CGRect)rect { \
[super drawRect:rect]; \
[self draw]; \
} \
- (void)layoutSubviews { \
[super layoutSubviews]; \
} \
- (void)initTXLayout { \
id view = self; \

#define enddef } \

#define layout(args...) [TXLayoutContainerView create:TXLayoutLayoutView.class in:view return:^(id view){ \
[self setProperties:[TXLayoutViewPropertyParser parse:@#args] to:view]; \

#define endlayout }]; \

#define view(class, args...) [TXLayoutContainerView create:class in:view return:^(id view){ \
[self setProperties:[TXLayoutViewPropertyParser parse:@#args] to:view]; \
}]; \

#define label(args...) view(UILabel.class, args) \

#define button(args...) view(UIButton.class, args) \

#define image(args...) view(UIImageView.class, args) \

#define vertical_layout(args...) layout(orientation = "vertical", args) \

#define horizontal_layout(args...) layout(orientation = "horizontal", args) \


#pragma mark - TXLayoutViewPropertyProtocol

@protocol TXLayoutViewPropertyProtocol <NSObject>

- (id)property:(NSString *)key;
- (void)setProperty:(id)object forKey:(NSString *)key;

@end


#pragma mark - TXLayoutViewPropertyParser

@interface TXLayoutViewPropertyParser : NSObject

+ (NSDictionary *)parse:(NSString *)propertiesString;

@end


#pragma mark - TXLayoutView

@interface TXLayoutView : UIView

- (void)setProperties:(NSDictionary *)properties to:(id)view;
- (void)setProperty:(id)object forKey:(NSString *)key to:(id<TXLayoutViewPropertyProtocol>)view;
- (NSArray *)viewsForProperty:(NSString *)key;
- (void)draw;

@end


#pragma mark - TXLayoutContainerView

@interface TXLayoutContainerView : UIView <TXLayoutViewPropertyProtocol>

@property (nonatomic, readonly) UIView *subview;

+ (void)create:(Class)viewClass in:(id)layout return:(void (^)(id view))returnBlock;
- (void)resize;

@end


#pragma mark - TXLayoutLayoutView

@interface TXLayoutLayoutView : UIView

@end


