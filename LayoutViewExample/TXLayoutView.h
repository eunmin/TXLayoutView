#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static const NSString *ref = @"ref";
static const NSString *width = @"width";
static const NSString *height = @"height";
static const NSString *align = @"align";
static const NSString *marginTop = @"marginTop";
static const NSString *marginLeft = @"marginLeft";
static const NSString *marginRight = @"marginRight";
static const NSString *marginBottom = @"marginBottom";

#define deflayout \
- (void)didAddSubview:(UIView *)subview { \
    [super didAddSubview:subview]; \
    [TXLayoutViewProperty addObserverForAllProperties:self]; \
} \
- (void)willRemoveSubview:(UIView *)subview { \
    [super willRemoveSubview:subview]; \
    [TXLayoutViewProperty removeObserverForAllProperties:self]; \
} \
- (void)initTXLayout { \
    id view = self.subview; \

#define enddef \
} \

#define layout(args...) \
[TXLayoutContainerView create:TXLayoutLayoutView.class in:view return:^(id view){ \
    [TXLayoutViewProperty setProperties:@{args} to:view context:self]; \

#define endlayout \
}]; \

#define view(class, args...) \
[TXLayoutContainerView create:class in:view return:^(id view){ \
    [TXLayoutViewProperty setProperties:@{args} to:view context:self]; \
}]; \

#define label(args...) view(UILabel.class, args) \

#define button(args...) view(UIButton.class, args) \

#define image(args...) view(UIImageView.class, args) \

#define vertical_layout(args...) layout(@"orientation" : @"vertical", args) \

#define horizontal_layout(args...) layout(@"orientation" : @"horizontal", args) \


#pragma mark - TXLayoutViewPropertyProtocol

@protocol TXLayoutViewPropertyProtocol <NSObject>

- (id)property:(NSString *)key;
- (void)setProperty:(id)object forKey:(NSString *)key;
- (NSMutableDictionary *)propertyViews;

@end


#pragma mark - TXLayoutViewProperty

@interface TXLayoutViewProperty : NSObject

+ (void)setProperties:(NSDictionary *)properties to:(id)view context:(id)context;
+ (void)setProperty:(id)object forKey:(NSString *)key to:(id<TXLayoutViewPropertyProtocol>)view context:(id)context;
+ (void)addObserverForAllProperties:(NSObject *)observer;
+ (void)removeObserverForAllProperties:(NSObject *)observer;

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


