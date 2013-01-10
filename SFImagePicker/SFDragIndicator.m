//
// Created by malczak on 1/10/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SFDragIndicator.h"


@implementation SFDragIndicator {

}

- (void)setImage:(UIImage *)value {
    super.image = value;
    self.alpha = 1.0;
}

- (void)dealloc {
    self.relatedData = nil;
}

@end