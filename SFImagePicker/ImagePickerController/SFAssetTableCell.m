//
//  SFAssetTableCell.m
//  SFImagePicker
//
//  Created by malczak on 1/8/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import "SFAssetTableCell.h"

@implementation SFAssetTableCell

@synthesize model, delegate, dataOffset;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        dataOffset = -1;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)setDataOffset:(int)value {
    dataOffset = value;
    [self setNeedsDisplay];
}

-(int)assetOffsetFromPoint:(CGPoint)point {
    int offset = ((int)floor(point.x / (float)79));
    return  self.dataOffset + offset;
}

-(void)drawRect:(CGRect)rect {

    if(dataOffset>-1) {
        
        NSMutableArray *assets = model.selectedGroupAssets;
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -self.frame.size.height);
        
        float X = 4;
        int index = dataOffset;
        int count = MIN( dataOffset+4, [assets count] );
        while(index<count) {
            ALAsset* asset = [assets objectAtIndex:index];
            
            CGContextDrawImage(ctx, CGRectMake(X, 2, 75, 75), asset.thumbnail);

            BOOL selected = [model isSelectedAsset:asset];
            if(selected) {
                CGContextDrawImage(ctx, CGRectMake(X, 2, 75, 75), [model.selectedOverlayImage CGImage]);
            }
            
            X += 75 + 4;
            
            index+=1;
        }
    
    }

}

-(void) dealloc {
    self.dataOffset = -1;
    self.model = nil;
    self.delegate = nil;
}

@end
