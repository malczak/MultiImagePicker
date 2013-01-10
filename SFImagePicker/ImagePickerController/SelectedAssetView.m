//
// Created by malczak on 1/10/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SelectedAssetView.h"


@implementation SelectedAssetView {

}

-(id)init {
    self = [super init];
    if (self) {
        assetUniqueId = nil;
        asset = nil;

        imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = NO;

        [self addSubview:imageView];
    }
    return self;
}

-(id)initWithFrame:(CGRect) inFrame andAsset:(ALAsset *) inAsset {
    self = [self init];
    if (self) {

        CGRect boundsRect = CGRectMake(0, 0, inFrame.size.width, inFrame.size.height);
        self.bounds = boundsRect;
        imageView.frame = boundsRect;

        self.frame = inFrame;

        asset = inAsset;
        if (asset) {
            NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
            assetUniqueId = url.absoluteString;

            imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
        }
    }
    return self;
}

-(ALAsset *)_getAsset
{
    return asset;
}

-(NSString *)assetUID {
    return assetUniqueId;
}

- (void)dealloc {
    assetUniqueId = nil;
    asset = nil;
    imageView.image = nil;
    imageView = nil;
}

@end