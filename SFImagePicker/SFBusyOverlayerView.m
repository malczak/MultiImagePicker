//
//  SFBusyOverlayerView.m
//  SFImagePicker
//
//  Created by malczak on 2/21/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import "SFBusyOverlayerView.h"
#import <QuartzCore/QuartzCore.h>

@interface SFBusyOverlayerView () {
    
}

@property (nonatomic, retain) IBOutlet UIView *indicatorView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;

-(void) initSubviews;

@end

@implementation SFBusyOverlayerView

-(id)init {
    self = [super init];
    if(self){
        [self initSubviews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

-(void)awakeFromNib{
    [self initSubviews];
}

-(void)initSubviews {
    CALayer *layer = self.indicatorView.layer;
    layer.cornerRadius = 4;
    layer.shouldRasterize = YES;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    CGRect frame = self.frame;
    CGSize inidicatorViewSize = self.indicatorView.bounds.size;
    
    self.indicatorView.frame = CGRectMake((frame.size.width-inidicatorViewSize.width)*0.5, (frame.size.height-inidicatorViewSize.height)*0.5, inidicatorViewSize.width, inidicatorViewSize.height);
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    if(newSuperview) {
        [self.indicator startAnimating];
    } else {
        [self.indicator stopAnimating];
    }
}

@end
