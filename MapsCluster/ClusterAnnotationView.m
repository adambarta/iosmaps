//
//  ClusterAnnotationView.m
//  BlueAirMapCluster
//
//  Created by Adam Barta on 10/29/15.
//  Copyright © 2015 flatcircle. All rights reserved.
//

#import "ClusterAnnotationView.h"

#import <QuartzCore/QuartzCore.h>

@interface ClusterAnnotationView()

@property (nonatomic) UILabel *countLabel;
@property (nonatomic) UIBezierPath *circ;
@property (nonatomic) UIColor *bkg;
@property (nonatomic) UIColor *stk;

@end

@implementation ClusterAnnotationView

- (NSUInteger) quik_log_10: (NSUInteger)v
{
    return (v >= 1000000000) ? 9 : (v >= 100000000) ? 8 : (v >= 10000000) ? 7 :
    (v >= 1000000) ? 6 : (v >= 100000) ? 5 : (v >= 10000) ? 4 :
    (v >= 1000) ? 3 : (v >= 100) ? 2 : (v >= 10) ? 1 : 0;
}

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bkg = nil;
        self.stk = [UIColor whiteColor];
        self.frame = CGRectMake(0, 0, 25, 25);
        self.backgroundColor = [UIColor clearColor];
        [self setUpLabel];
        [self setCount:1];
    }
    return self;
}

-(void) setClusterbkg:(UIColor *)clusterbkg
{
    self.bkg = clusterbkg;
}

- (void)setUpLabel
{
    //NSLog(@"%s", __func__);
    _countLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.backgroundColor = [UIColor clearColor];
    
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.minimumScaleFactor = 2;
    _countLabel.numberOfLines = 1;
    _countLabel.font = [UIFont boldSystemFontOfSize:12];
    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    [self addSubview:_countLabel];
}

- (void) drawClusterIcon
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.bkg setFill];
    [self.stk setStroke];
    
    _circ = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, 5.5f, 5.5f)];
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 5.0, [[UIColor darkGrayColor] CGColor]);
    
    [_circ setLineWidth:3.f];
    
    CGContextSaveGState(context);
    
    [_circ fill];
    [_circ stroke];
    
    CGContextRestoreGState(context);
}

- (void) drawStationIcon
{
#define PINSZ 10.f
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.bkg setStroke];
    [[UIColor whiteColor] setFill];
    
    _circ = [UIBezierPath bezierPath];
    
    [_circ setLineWidth:2.f];
    
    [_circ moveToPoint:CGPointMake(self.frame.size.width/2.f, self.frame.size.height-5.f)];
    [_circ addArcWithCenter:CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f) radius:PINSZ startAngle:M_PI_4 endAngle:3.f*M_PI_4 clockwise:NO];
    [_circ closePath];
    
    
    CGContextSaveGState(context);
    
    [_circ fill];
    [_circ stroke];
    
    CGContextRestoreGState(context);
    
    [self.bkg setFill];
    
    _circ = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f) radius:PINSZ/1.5f startAngle:0.f endAngle:2.f*M_PI clockwise:YES];
    
    CGContextSaveGState(context);
    
    [_circ fill];
    
    CGContextRestoreGState(context);
#undef PINSZ
}

- (void)setupIcon
{
    switch (self.count) {
        case 1:
            [self drawStationIcon];
            break;
            
        default:
            [self drawClusterIcon];
            break;
    }
}

- (void)setCount:(NSUInteger)count
{
    _count = count;
    
    if (count == 1){
        
        self.countLabel.text = @"";
        
        self.frame = CGRectMake(0, 0, 25, 45);
        
        [self setNeedsLayout];
        [self setNeedsDisplay];
        
        return;
    }
    
    self.countLabel.text = [@(count) stringValue];
    
    float res = 30+([self quik_log_10:self.count]*10);
    self.frame = CGRectMake(0, 0, res, res);
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setUniqueLocation:(BOOL)uniqueLocation
{
    _uniqueLocation = uniqueLocation;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGRect countLabelFrame;
    CGPoint centerOffset;
    
    centerOffset = CGPointZero;
    
    countLabelFrame = self.bounds;
    
    self.countLabel.frame = countLabelFrame;
    self.centerOffset = centerOffset;
}

- (void)drawRect:(CGRect)rect {
    [self setupIcon];
}


@end

#if 0
- (NSUInteger) quik_log_10: (NSUInteger)v
{
    return (v >= 1000000000) ? 9 : (v >= 100000000) ? 8 : (v >= 10000000) ? 7 :
    (v >= 1000000) ? 6 : (v >= 100000) ? 5 : (v >= 10000) ? 4 :
    (v >= 1000) ? 3 : (v >= 100) ? 2 : (v >= 10) ? 1 : 0;
}

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bkg = [UIColor colorWithRed:0.29 green:0.64 blue:0.99 alpha:1.0];
        self.stk = [UIColor colorWithRed:0.29 green:0.81 blue:1.00 alpha:1.0];
        self.frame = CGRectMake(0, 0, 25, 25);
        self.backgroundColor = [UIColor clearColor];
        [self setUpLabel];
        [self setCount:1];
        
    }
    return self;
}

- (void)setUpLabel
{
    _countLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.backgroundColor = [UIColor clearColor];
    
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.minimumScaleFactor = 2;
    _countLabel.numberOfLines = 1;
    _countLabel.font = [UIFont boldSystemFontOfSize:12];
    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    [self addSubview:_countLabel];
}

- (void)setupIcon
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.bkg setFill];
    [self.stk setStroke];
    
    _circ = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, 5.5f, 5.5f)];
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 5.0, [[UIColor darkGrayColor] CGColor]);
    
    [_circ setLineWidth:3.f];
    
    CGContextSaveGState(context);
    
    [_circ fill];
    [_circ stroke];
    
    CGContextRestoreGState(context);
}

- (void)setCount:(NSUInteger)count
{
    _count = count;
    
    float res = 25+([self quik_log_10:self.count]*10);
    self.frame = CGRectMake(0, 0, res, res);
    
    self.countLabel.text = [@(count) stringValue];
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setUniqueLocation:(BOOL)uniqueLocation
{
    _uniqueLocation = uniqueLocation;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGRect countLabelFrame;
    CGPoint centerOffset;
    
    centerOffset = CGPointZero;
    
    countLabelFrame = self.bounds;
    
    self.countLabel.frame = countLabelFrame;
    self.centerOffset = centerOffset;
}

- (void)drawRect:(CGRect)rect {

    [self setupIcon];
}

#endif
