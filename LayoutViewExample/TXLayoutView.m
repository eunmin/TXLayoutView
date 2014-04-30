#import <QuartzCore/QuartzCore.h>
#import "TXLayoutView.h"

#pragma mark - UIView Category

#define x(view) (view).frame.origin.x
#define y(view) (view).frame.origin.y

#define width(view) (view).frame.size.width
#define height(view) (view).frame.size.height

#define right(view) (view).frame.origin.x + (view).frame.size.width
#define bottom(view) (view).frame.origin.y + (view).frame.size.height

@interface TXFn : NSObject

+ (NSArray *)map:(id (^)(id))proc array:(NSArray *)array;
+ (id)reduce:(id (^)(id, id))proc array:(NSArray *)array;
+ (id)max:(NSArray *)array;
+ (id)sum:(NSArray *)array;

@end

@implementation TXFn

+ (NSArray *)map:(id (^)(id))proc array:(NSArray *)array {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:proc(obj)];
    }];
    return result;
}

+ (id)reduce:(id (^)(id, id))proc array:(NSArray *)array {
    __block id result = nil;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = proc(result, obj);
    }];
    return result;
}

+ (id)max:(NSArray *)array {
    return [TXFn reduce:^id(id result, id item) {
        if (result == nil || [result floatValue] < [item floatValue]) {
            return item;
        }
        else {
            return result;
        }
    } array:array];
}

+ (id)sum:(NSArray *)array {
    return [TXFn reduce:^id(id result, id item) {
        if (result == nil) {
            return item;
        }
        else {
            return @([result floatValue] + [item floatValue]);
        }
    } array:array];
}

@end

@interface UIView (TXLayout)

+ (void)move:(UIView *)view origin:(CGPoint)point;
+ (void)resize:(UIView *)view size:(CGSize)size;
+ (void)resize:(UIView *)view width:(CGFloat)width;
+ (void)resize:(UIView *)view height:(CGFloat)height;

+ (CGFloat)maxSubviewWidth:(UIView *)view;
+ (CGFloat)maxSubviewHeight:(UIView *)view;
+ (CGFloat)sumSubviewWidth:(UIView *)view;
+ (CGFloat)sumSubviewHeight:(UIView *)view;

+ (void)printSubviews:(UIView *)view withTab:(NSString *)tab;

@end

@implementation UIView (TXLayout)

+ (void)move:(UIView *)view origin:(CGPoint)point {
    view.frame = CGRectMake(point.x, point.y, view.frame.size.width, view.frame.size.height);
}

+ (NSArray *)subviewWidths:(UIView *)view {
    return [TXFn map:^id(UIView *view) {
        return @(width(view));
    } array:view.subviews];
}

+ (NSArray *)subviewHeights:(UIView *)view {
    return [TXFn map:^id(UIView *view) {
        return @(height(view));
    } array:view.subviews];
}

+ (CGFloat)maxSubviewWidth:(UIView *)view {
    return [[TXFn max:[UIView subviewWidths:view]] floatValue];
}

+ (CGFloat)maxSubviewHeight:(UIView *)view {
    return [[TXFn max:[UIView subviewHeights:view]] floatValue];
}

+ (CGFloat)sumSubviewWidth:(UIView *)view {
    return [[TXFn sum:[UIView subviewWidths:view]] floatValue];
}

+ (CGFloat)sumSubviewHeight:(UIView *)view {
    return [[TXFn sum:[UIView subviewHeights:view]] floatValue];
}

+ (void)resize:(UIView *)view size:(CGSize)size {
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, size.width, size.height);
}

+ (void)resize:(UIView *)view width:(CGFloat)width {
    [UIView resize:view size:CGSizeMake(width, view.frame.size.height)];
}

+ (void)resize:(UIView *)view height:(CGFloat)height {
    [UIView resize:view size:CGSizeMake(view.frame.size.width, height)];
}

+ (void)visitPre:(void (^)(id, id))preProc post:(void (^)(id, id))postProc subviewsOf:(id)view {
    [self visitPre:preProc post:postProc subviewsOf:view withPreviousView:nil];
}

+ (void)visitPre:(void (^)(id, id))preProc post:(void (^)(id, id))postProc subviewsOf:(id)view withPreviousView:(id)previousView {
    if (preProc != nil) {
        preProc(previousView, view);
    }
    __block id previousSubview = nil;
    [((UIView *)view).subviews enumerateObjectsUsingBlock:^(id subview, NSUInteger idx, BOOL *stop) {
        [self visitPre:preProc post:postProc subviewsOf:subview withPreviousView:previousSubview];
        previousSubview = subview;
    }];
    if (postProc != nil) {
        postProc(previousView, view);
    }
}

+ (void)printSubviews:(UIView *)view withTab:(NSString *)tab {
    [view.subviews enumerateObjectsUsingBlock:^(id view, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@%@",tab, view);
        [UIView printSubviews:view withTab:[tab stringByAppendingString:@"\t"]];
    }];
}

@end


#pragma  mark - NSString Category

@interface NSString (TXLayoutView)

- (NSString *)trim;

@end

@implementation NSString (TXLayoutView)

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end


#pragma mark - TXLayoutViewPropertyParser

@implementation TXLayoutViewPropertyParser

+ (NSDictionary *)parse:(NSString *)propertiesString {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    NSArray *properties = [propertiesString componentsSeparatedByString:@","];
    [properties enumerateObjectsUsingBlock:^(NSString *property, NSUInteger idx, BOOL *stop) {
        NSArray *keyValue = [[property trim] componentsSeparatedByString:@"="];
        [result setObject:[self parseValue:[keyValue[1] trim]] forKey:[keyValue[0] trim]];
    }];
    
    return result;
}

+ (NSObject *)parseValue:(NSString *)value {
    if ([value hasPrefix:@"\""]) {
        return [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
    }
    else if(isdigit([value characterAtIndex:0])) {
        return @([value floatValue]);
    }
    else {
        return value;
    }
    return value;
}

@end


#pragma mark - TXLayoutView

@interface TXLayoutView()

@property (nonatomic, strong) NSMutableDictionary *propertyViews;

@end

@implementation TXLayoutView

- (NSDictionary *)propertyViews {
    if (_propertyViews == nil) {
        _propertyViews = [[NSMutableDictionary alloc] init];
    }
    return _propertyViews;
}

- (void)setProperties:(NSDictionary *)properties to:(id)view {
    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setProperty:obj forKey:key to:view];
    }];
}

- (void)setProperty:(id)object forKey:(NSString *)key to:(id<TXLayoutViewPropertyProtocol>)view {
    if ([object isKindOfClass:[NSString class]] && [object characterAtIndex:0] == '@') {
        NSString *varKey = [object substringFromIndex:1];
        
        if ([view isKindOfClass:[TXLayoutContainerView class]] && [key isEqualToString:@"ref"]) {
            TXLayoutContainerView *containerView = (TXLayoutContainerView *)view;
            [self setValue:[containerView subview] forKey:varKey];
        }
        else {
            [view setProperty:[self valueForKey:varKey] forKey:key];
            [self addViewForProperty:varKey view:view originalKey:key];
        }
    }
    else {
        [view setProperty:object forKey:key];
    }
}

- (NSArray *)viewsForProperty:(NSString *)key {
    return [self.propertyViews valueForKey:key];
}

- (void)addViewForProperty:(NSString *)varKey view:(id)view originalKey:(NSString *)key {
    NSMutableArray *views = [self.propertyViews objectForKey:varKey];
    if (views == nil) {
        views = [[NSMutableArray alloc] init];
        [self.propertyViews setObject:views forKey:varKey];
    }
    [views addObject:@{@"view" : view, @"key" : key}];
}

- (void)draw {
    [self reposition];
    
    [UIView printSubviews:self withTab:@""];
}

// TODO : 리펙토링이 필요함
- (void)reposition {
    [UIView visitPre:^(id previousView, id view) {
        if (![view conformsToProtocol:@protocol(TXLayoutViewPropertyProtocol)]) {
            return;
        }
        
        CGFloat x = x((UIView *)view);
        CGFloat y = y((UIView *)view);
        
        TXLayoutLayoutView *superview = (TXLayoutLayoutView *)((UIView *)view).superview;
        
        if ([superview respondsToSelector:@selector(property:)] &&
            [[superview property:@"orientation"] isEqualToString:@"horizontal"]) {
            x = right((UIView *)previousView);
        }
        else {
            y = bottom((UIView *)previousView);
        }
        
        [UIView move:view origin:CGPointMake(x, y)];
        
    } post:nil subviewsOf:self];
}

@end


#pragma mark - TXLayoutAbstractView

@interface TXLayoutAbstractView()

@property (nonatomic, strong) id width;
@property (nonatomic, strong) id height;
@property (nonatomic, strong) id background;

@end

@implementation TXLayoutAbstractView

- (void)setWidth:(id)width {
    _width = width;
    
    [self resize];
}

- (void)setHeight:(id)height {
    _height = height;
    
    [self resize];
}

- (id)property:(NSString *)key {
    if ([self respondsToSelector:NSSelectorFromString(key)]) {
        return [self valueForKey:key];
    }
    else {
        return [self valueForUndefinedKey:key];
    }
    return nil;
}

- (void)setProperty:(id)object forKey:(NSString *)key {
    NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
                           [[key substringToIndex:1] capitalizedString],
                           [key substringFromIndex:1]];
    
    if ([self respondsToSelector:NSSelectorFromString(setterStr)]) {
        [self setValue:object forKey:key];
    }
    else {
        [self setValue:object forUndefinedKey:key];
    }
}

- (void)setBackground:(id)background {
    _background = background;
    
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:background]];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

- (void)resize {
    if ([self.width isKindOfClass:[NSNumber class]]) {
        [UIView resize:self width:[self.width floatValue]];
    }
    else if ([self.width isEqualToString:@"match_parent"]) {
        if (self.superview) {
            [UIView resize:self width:width(self.superview)];
        }
        else {
            [UIView resize:self width:width(((UIWindow *)[UIApplication sharedApplication].windows[0]))];
        }
    }
    
    if ([self.height isKindOfClass:[NSNumber class]]) {
        [UIView resize:self height:[self.height floatValue]];
    }
    else if ([self.height isEqualToString:@"match_parent"]) {
        if ([self.height isKindOfClass:[NSNumber class]]) {
            [UIView resize:self height:[self.height floatValue]];
        }
        else if ([self.height isEqualToString:@"match_parent"]) {
            [UIView resize:self width:height(((UIWindow *)[UIApplication sharedApplication].windows[0]))];
        }
    }
    
    [self sizeToFit];
}

@end


#pragma mark - TXLayoutContainerView

@implementation TXLayoutContainerView

+ (id)create:(Class)viewClass in:(id)layout {
    TXLayoutContainerView *containerView = [[TXLayoutContainerView alloc] initWithFrame:CGRectZero];
    containerView.autoresizesSubviews = YES;
    containerView.clipsToBounds = YES;
    
    // For Debug
    containerView.layer.borderColor = [UIColor redColor].CGColor;
    containerView.layer.borderWidth = 1.0f;
    
    UIView *view = nil;
    
    if (viewClass == UIButton.class) {
        view = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    else {
        view = [[viewClass alloc] init];
    }
    
    view.contentMode = UIViewContentModeScaleToFill;
    
    [containerView setSubview:view];
   
    [layout addSubview:containerView];
    
    return containerView;
}

- (id)valueForUndefinedKey:(NSString *)key {
    if ([[self subview] respondsToSelector:NSSelectorFromString(key)]) {
        return [[self subview] valueForKey:key];
    }
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
                           [[key substringToIndex:1] capitalizedString],
                           [key substringFromIndex:1]];
    
    if ([[self subview] respondsToSelector:NSSelectorFromString(setterStr)]) {
        [[self subviews] setValue:value forKey:key];
    }
}

- (void)setProperty:(id)object forKey:(NSString *)key {
    [super setProperty:object forKey:key];
    
    if ([[self subview] isKindOfClass:UIButton.class] && [key isEqualToString:@"text"]) {
        UIButton *button = (UIButton *)[self subview];
        [button setTitle:object forState:UIControlStateNormal];
    }
    
    [[self subview] sizeToFit];
    
    [self resize];
    
    [self.superview sizeToFit];
}

- (void)setSubview:(UIView *)view {
    for(UIView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    [self addSubview:view];
}

- (UIView *)subview {
    if (self.subviews.count == 0) {
        return nil;
    }
    return [self subviews][0];
}

- (void)sizeToFit {
    [super sizeToFit];
    
    if ([self.width isKindOfClass:[NSString class]] && [self.width isEqualToString:@"wrap_content"]) {
        [UIView resize:self width:width([self subview])];
    }
    
    if ([self.height isKindOfClass:[NSString class]] && [self.height isEqualToString:@"wrap_content"]) {
        [UIView resize:self height:height([self subview])];
    }

    if ([self subview]) {
        [UIView resize:[self subview] size:CGSizeMake(width(self), height(self))];
    }
}

@end

#pragma mark - TXLayoutLayoutView

@interface TXLayoutLayoutView()

@property (nonatomic, strong) NSString *orientation;

@end

@implementation TXLayoutLayoutView

+ (void)createIn:(UIView *)layout returnLayout:(void (^)(id layout))returnBlock {
    TXLayoutLayoutView *layoutView = [[TXLayoutLayoutView alloc] initWithFrame:CGRectZero];
    
    // For Debug
    layoutView.layer.borderColor = [UIColor yellowColor].CGColor;
    layoutView.layer.borderWidth = 1.0f;

    [layout addSubview:layoutView];
    
    returnBlock(layoutView);
}

- (void)setProperty:(id)object forKey:(NSString *)key {
    [super setProperty:object forKey:key];
    
    [self resize];
}

- (void)sizeToFit {
    [super sizeToFit];
    
    if ([self.width isKindOfClass:[NSString class]] && [self.width isEqualToString:@"wrap_content"]) {
        if ([[self property:@"orientation"] isEqualToString:@"virtical"]) {
            [UIView resize:self width:[UIView maxSubviewWidth:self]];
        }
        else {
            [UIView resize:self width:[UIView sumSubviewWidth:self]];
        }
    }
    
    if ([self.height isKindOfClass:[NSString class]] && [self.height isEqualToString:@"wrap_content"]) {
        if ([[self property:@"orientation"] isEqualToString:@"virtical"]) {
            [UIView resize:self height:[UIView sumSubviewHeight:self]];
        }
        else {
            [UIView resize:self height:[UIView maxSubviewHeight:self]];
        }
    }
}

@end

