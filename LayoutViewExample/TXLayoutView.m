#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
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

+ (void)printSubviews:(UIView *)view withTab:(NSString *)tab {
    [view.subviews enumerateObjectsUsingBlock:^(id view, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@%@",tab, view);
        [UIView printSubviews:view withTab:[tab stringByAppendingString:@"\t"]];
    }];
}

+ (CGSize)sizeBySizeToFit:(UIView *)view {
    if (view == nil) {
        return CGSizeZero;
    }
    
    CGRect frame = view.frame;
    CGSize size = CGSizeZero;
    
    [view sizeToFit];
    size = view.frame.size;
    view.frame = frame;
    
    return size;
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

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    
    [self addObserverForAllProperties];
}

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    
    [self removeObserverForAllProperties];
}

- (void)sizeToFit {
    [super sizeToFit];
    
    [UIView resize:self width:[UIView sizeBySizeToFit:[self.subviews firstObject]].width];
    [UIView resize:self height:[UIView sizeBySizeToFit:[self.subviews firstObject]].height];
    
}

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
        else if ([view isKindOfClass:[TXLayoutLayoutView class]] && [key isEqualToString:@"ref"]) {
            TXLayoutLayoutView *layoutView = (TXLayoutLayoutView *)view;
            [self setValue:layoutView forKey:varKey];
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
    if ([self.subviews count] > 0) {
        [[self.subviews firstObject] resize];
    }
    
    [UIView printSubviews:self withTab:@""];
}

- (void)addObserverForAllProperties {
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    while (outCount--) {
        objc_property_t property = properties[outCount];
        if (![self isReadOnlyProperty:property_getAttributes(property)]) {
            [self addObserver:self forKeyPath:[NSString stringWithFormat:@"%s", property_getName(property)] options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (BOOL)isReadOnlyProperty:(const char *)propertyAttributes {
    NSArray *attributes = [[NSString stringWithUTF8String:propertyAttributes] componentsSeparatedByString:@","];
    return [attributes containsObject:@"R"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [[self viewsForProperty:keyPath] enumerateObjectsUsingBlock:^(id propertyView, NSUInteger idx, BOOL *stop) {
        [self setProperty:change[NSKeyValueChangeNewKey] forKey:propertyView[@"key"] to:propertyView[@"view"]];
    }];
    
    [self setNeedsDisplay];
}

- (void)removeObserverForAllProperties {
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    while (outCount--) {
        objc_property_t property = properties[outCount];
        if (![self isReadOnlyProperty:property_getAttributes(property)]) {
            [self removeObserver:self forKeyPath:[NSString stringWithFormat:@"%s", property_getName(property)] context:nil];
        }
    }
}

@end


#pragma mark - TXLayoutContainerView

@interface TXLayoutContainerView()

@property (nonatomic, strong) id width;
@property (nonatomic, strong) id height;
@property (nonatomic, strong) NSNumber *marginTop;
@property (nonatomic, strong) NSNumber *marginLeft;
@property (nonatomic, strong) NSNumber *marginRight;
@property (nonatomic, strong) NSNumber *marginBottom;

@end

@implementation TXLayoutContainerView

- (void)setWidth:(id)width {
    _width = width;
    
    [self resize];
}

- (void)setHeight:(id)height {
    _height = height;
    
    [self resize];
}

- (void)setMarginLeft:(NSNumber *)marginLeft {
    _marginLeft = marginLeft;
    
    [self resize];
}

- (void)setMarginTop:(NSNumber *)marginTop {
    _marginTop = marginTop;
    
    [self resize];
}

+ (void)create:(Class)viewClass in:(id)layout return:(void (^)(id))returnBlock {
    TXLayoutContainerView *containerView = [[TXLayoutContainerView alloc] initWithFrame:CGRectZero];
    containerView.autoresizesSubviews = YES;
    containerView.clipsToBounds = YES;
    containerView.width = @"wrap_content";
    containerView.height = @"wrap_content";
    
    // For Debug
    //    containerView.layer.borderColor = [UIColor redColor].CGColor;
    //    containerView.layer.borderWidth = 1.0f;
    
    UIView *view = nil;
    
    if (viewClass == UIButton.class) {
        view = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    else {
        view = [[viewClass alloc] init];
    }
    
    [containerView setSubview:view];
    
    if ([layout isKindOfClass:[self class]]) {
        [[layout subview] addSubview:containerView];
    }
    else {
        [layout addSubview:containerView];
    }
    
    returnBlock(containerView);
}

- (void)resize {
    [self resizeWidth];
    [self resizeHeight];
    
    [self resizeWithMargin];
}

- (void)resizeWithMargin {
    [UIView resize:self size:CGSizeMake(width(self) + [self horizontalMargin], height(self) + [self verticalMargin])];
}

- (void)resizeWidth {
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
    else if ([self.width isEqualToString:@"wrap_content"]) {
        [UIView resize:self width:[UIView sizeBySizeToFit:[self subview]].width];
    }
}

- (void)resizeHeight {
    if ([self.height isKindOfClass:[NSNumber class]]) {
        [UIView resize:self height:[self.height floatValue]];
    }
    else if ([self.height isEqualToString:@"match_parent"]) {
        if ([self.height isKindOfClass:[NSNumber class]]) {
            [UIView resize:self height:[self.height floatValue]];
        }
        else {
            [UIView resize:self height:height(((UIWindow *)[UIApplication sharedApplication].windows[0]))];
        }
    }
    else if ([self.height isEqualToString:@"wrap_content"]) {
        [UIView resize:self height:[UIView sizeBySizeToFit:[self subview]].height];
    }
}

- (void)layoutSubviews {
    if ([self subview]) {
        [UIView resize:[self subview] size:CGSizeMake(width(self) - [self horizontalMargin], height(self) - [self verticalMargin])];
        [UIView move:[self subview] origin:CGPointMake([[self marginLeft] floatValue], [[self marginTop] floatValue])];
    }
}

- (CGFloat)horizontalMargin {
    return [[self marginLeft] floatValue] + [[self marginRight] floatValue];
}

- (CGFloat)verticalMargin {
    return [[self marginTop] floatValue] + [[self marginBottom] floatValue];
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
        [[self subview] setValue:value forKey:key];
    }
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
    
    if ([[self subview] isKindOfClass:UIButton.class] && [key isEqualToString:@"text"]) {
        UIButton *button = (UIButton *)[self subview];
        [button setTitle:object forState:UIControlStateNormal];
    }
    
    [self resize];
    
    [self setNeedsDisplay];
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

@end


#pragma mark - TXLayoutLayoutView

@interface TXLayoutLayoutView()

@property (nonatomic, strong) NSString *orientation;
@property (nonatomic, strong) NSString *align;

@end

@implementation TXLayoutLayoutView

- (void)sizeToFit {
    if ([self.orientation isEqualToString:@"horizontal"]) {
        [UIView resize:self size:CGSizeMake([UIView sumSubviewWidth:self], [UIView maxSubviewHeight:self])];
    }
    else {
        [UIView resize:self size:CGSizeMake([UIView maxSubviewWidth:self], [UIView sumSubviewHeight:self])];
    }
}

- (void)layoutSubviews {
    __block CGFloat x = 0;
    __block CGFloat y = 0;
    
    [self.subviews enumerateObjectsUsingBlock:^(TXLayoutContainerView *view, NSUInteger idx, BOOL *stop) {
        [view resize];
        
        [UIView move:view origin:CGPointMake(x, y)];
        if ([self.orientation isEqualToString:@"horizontal"]) {
            x += width(view);
        }
        else {
            y += height(view);
        }
    }];
    
    [self applyAlign];
}

- (void)applyAlign {
    NSArray *aligns = [self.align componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    __block BOOL isAppliedVerticalAlign = NO;
    __block BOOL isAppliedHorizontalAlign = NO;
    
    [aligns enumerateObjectsUsingBlock:^(NSString *align, NSUInteger idx, BOOL *stop) {
        if ([align isEqualToString:@"center"] && !isAppliedHorizontalAlign) {
            [self.subviews enumerateObjectsUsingBlock:^(TXLayoutContainerView *view, NSUInteger idx, BOOL *stop) {
                CGFloat paddingX;
                if ([self.orientation isEqualToString:@"vertical"]) {
                    paddingX = (width(self) - width(view)) / 2;
                }
                else {
                    paddingX = (width(self) - [UIView sumSubviewWidth:self]) / 2;
                }
                [UIView move:view origin:CGPointMake(x(view) + paddingX, y(view))];
            }];
            isAppliedHorizontalAlign = YES;
        }
        else if ([align isEqualToString:@"right"] && !isAppliedHorizontalAlign) {
            [self.subviews enumerateObjectsUsingBlock:^(TXLayoutContainerView *view, NSUInteger idx, BOOL *stop) {
                CGFloat paddingX;
                if ([self.orientation isEqualToString:@"vertical"]) {
                    paddingX = width(self) - width(view);
                }
                else {
                    paddingX = width(self) - [UIView sumSubviewWidth:self];
                }
                [UIView move:view origin:CGPointMake(x(view) + paddingX, y(view))];
            }];
            isAppliedHorizontalAlign = YES;
        }
        else if ([align isEqualToString:@"center_vertical"] && !isAppliedVerticalAlign) {
            [self.subviews enumerateObjectsUsingBlock:^(TXLayoutContainerView *view, NSUInteger idx, BOOL *stop) {
                CGFloat paddingY;
                if ([self.orientation isEqualToString:@"horizontal"]) {
                    paddingY = (height(self) - height(view)) / 2;
                }
                else {
                    paddingY = (height(self) - [UIView sumSubviewHeight:self]) / 2;
                }
                [UIView move:view origin:CGPointMake(x(view), y(view) + paddingY)];
            }];
            isAppliedVerticalAlign = YES;
        }
        else if ([align isEqualToString:@"bottom"] && !isAppliedVerticalAlign) {
            [self.subviews enumerateObjectsUsingBlock:^(TXLayoutContainerView *view, NSUInteger idx, BOOL *stop) {
                CGFloat paddingY;
                if ([self.orientation isEqualToString:@"horizontal"]) {
                    paddingY = height(self) - height(view);
                }
                else {
                    paddingY = height(self) - [UIView sumSubviewHeight:self];
                }
                [UIView move:view origin:CGPointMake(x(view), y(view) + paddingY)];
            }];
            isAppliedVerticalAlign = YES;
        }
        else if ([align isEqualToString:@"left"] && !isAppliedHorizontalAlign) {
            isAppliedHorizontalAlign = YES;
        }
        else if ([align isEqualToString:@"top"] && !isAppliedVerticalAlign) {
            isAppliedVerticalAlign = YES;
        }
    }];
}

@end
