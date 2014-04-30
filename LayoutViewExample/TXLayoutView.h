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
- (void)initTXLayout { \
id layout = self; \

#define layout(args...) [TXLayoutLayoutView createIn:layout returnLayout:^(id layout){ \
[self setProperties:[TXLayoutViewPropertyParser parse:@#args] to:layout]; \

#define view(class, args...) [self setProperties:[TXLayoutViewPropertyParser parse:@#args] to:[TXLayoutContainerView create:class in:layout]]; \

#define endlayout }]; \

#define enddef } \

#define label(args...) view(UILabel.class, args) \

#define button(args...) view(UIButton.class, args) \


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


#pragma mark - TXLayoutAbstractView

@interface TXLayoutAbstractView : UIView <TXLayoutViewPropertyProtocol>

- (void)resize;

@end


#pragma mark - TXLayoutLayoutView

@interface TXLayoutLayoutView : TXLayoutAbstractView

+ (void)createIn:(id)layout returnLayout:(void (^)(id layout))returnBlock;

@end


#pragma mark - TXLayoutContainerView

@interface TXLayoutContainerView : TXLayoutAbstractView

@property (nonatomic, readonly) UIView *subview;

+ (id)create:(Class)viewClass in:(id)layout;

@end


