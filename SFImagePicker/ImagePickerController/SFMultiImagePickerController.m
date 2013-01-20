//
//  SFMultiImagePickerController.m
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

#import "SFMultiImagePickerController.h"
#import "SFViewControllerModel.h"
#import "SFGroupTableViewController.h"
#import "SFAssetTableViewController.h"
#import "SelectedAssetView.h"

/**
 
 http://stackoverflow.com/questions/2962162/non-fullscreen-uinavigationcontroller
 http://stackoverflow.com/questions/2526990/adding-a-uinavigationcontroller-as-a-subview-of-uiview
 
 http://stackoverflow.com/questions/8084050/when-to-use-addchildviewcontroller-vs-pushviewcontroller
 
  [      ]
  [ Nav. ]
  [      ]
  [______]
  [ sel. ]
 
 */

@interface SFMultiImagePickerController ()

@end

@implementation SFMultiImagePickerController

@synthesize delegate;

-(id) init {
    self = [super init];
    if(self) {
        model = [[SFViewControllerModel alloc] init];
        selectedAssetsThumbnails = [[NSMutableArray alloc] init];

        dragIndicator = [[SFDragIndicator alloc] init];

        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
        tapRecognizer.numberOfTouchesRequired = 1;
        tapRecognizer.cancelsTouchesInView = YES;

        pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureLongPress:)];
        pressRecognizer.numberOfTouchesRequired = 1;
        pressRecognizer.minimumPressDuration = 0.3;
        pressRecognizer.cancelsTouchesInView = YES;

    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    CGRect frm =  [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame:frm];
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor redColor];
    self.view.bounds = CGRectMake(0,0,frm.size.width,frm.size.height);
    
    UIImage *selectedOverlayImage = [UIImage imageNamed:@"Overlay.png"];
    model.selectedOverlayImage = selectedOverlayImage;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect viewRect = self.view.frame;
    CGFloat navHeight = viewRect.size.height - 90;

    // create main navigation controller to display assets
    navigationController = [[UINavigationController alloc] init];
    
//	[cancelButton release];
    
    [self addChildViewController:navigationController];
    [self.view addSubview:navigationController.view];
    navigationController.view.frame = CGRectMake(0, 0, viewRect.size.width, navHeight);
    
    
    CGRect selectedRect = CGRectMake(0, navHeight, viewRect.size.width, viewRect.size.height - navHeight);
    //create selected assets scroll view
    selectedAssetsView = [[UIScrollView alloc] initWithFrame:selectedRect];
    selectedAssetsView.contentInset = UIEdgeInsetsMake(SELECTED_THUMBS_GAP,SELECTED_THUMBS_GAP,SELECTED_THUMBS_GAP,SELECTED_THUMBS_GAP);
    selectedAssetsView.showsHorizontalScrollIndicator = NO;
    selectedAssetsView.showsVerticalScrollIndicator = NO;
    selectedAssetsView.pagingEnabled = NO;
    selectedAssetsView.bounces = NO;
    selectedAssetsView.alwaysBounceHorizontal = NO;
    selectedAssetsView.alwaysBounceVertical = NO;
    selectedAssetsView.scrollsToTop = NO;
//    selectedAssetsView.backgroundColor = [UIColor whiteColor];
    selectedAssetsView.backgroundColor = [UIColor greenColor];
    [selectedAssetsView addGestureRecognizer:tapRecognizer];
    [selectedAssetsView addGestureRecognizer:pressRecognizer];
    [self.view addSubview:selectedAssetsView];

    //empty selection prompt
    emptySelectionPrompt = [[UILabel alloc] initWithFrame:selectedRect];
    emptySelectionPrompt.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    emptySelectionPrompt.textAlignment = NSTextAlignmentCenter;
    emptySelectionPrompt.text = [NSString stringWithFormat:@"Select up to %d photos", [self getAllowedSelectionSize]];
    CALayer *layer = emptySelectionPrompt.layer;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.8;
    layer.shadowRadius = 4;
    layer.shouldRasterize = YES;
    [self.view addSubview:emptySelectionPrompt];
    
    
    // initialize assets library access
    [ALAssetsLibrary disableSharedPhotoStreamsSupport];
    model.assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    // get array of all available groups
    void (^completeBlock)(ALAssetsGroup *group, BOOL *stop) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        // finished
        if(group == nil) {
            [self performSelectorOnMainThread:@selector(groupEnummerationDone) withObject:nil waitUntilDone:YES];
//            dispatch_async( dispatch_get_main_queue(), ^(void){
//                [self groupEnummerationDone];
//            });
            return;
        }
        
        [model.assetGroups addObject: group];
        NSLog(@"Num : %d", [model.assetGroups count]);
    };
    
    void (^failureBlock)(NSError *error) = ^(NSError *error) {
        // alert ;/
        NSLog(@"error");
    };
    
    [model.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:completeBlock failureBlock:failureBlock];
    
}

- (void)handleGestureTap:(UIGestureRecognizer *)recognizer {
    if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {

        SelectedAssetView *v = [self viewFromRecognizer:recognizer];
        if (v) {
            NSLog(@"Tap");
        }

    }
}

- (void)handleGestureLongPress:(UITapGestureRecognizer *)recognizer {
    if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {

        SelectedAssetView *selectedThumb;

        if ( recognizer.state == UIGestureRecognizerStateBegan ) {

            selectedThumb = [self viewFromRecognizer:recognizer];
            if (selectedThumb) {

                selectedThumb.dragged = YES;

                selectedAssetsView.scrollEnabled = NO;


                UIImage *dragIndicatorImage = [UIImage imageWithCGImage:selectedThumb.asset.thumbnail];

                CGRect frame = [recognizer.view convertRect:selectedThumb.frame toView:self.view];
                CGPoint mousePosition = [recognizer locationInView:self.view];
                float dx = frame.size.width - 5;
                float dy = frame.size.height - 5;
                frame.origin.x = mousePosition.x - dx;
                frame.origin.y = mousePosition.y - dy;

                dragIndicator.image = dragIndicatorImage;
                dragIndicator.relatedData = selectedThumb;
                dragIndicator.frame = frame;

                [self.view addSubview:dragIndicator];


                selectedAssetsView.scrollEnabled = YES;


            }
        } else
        if ( recognizer.state == UIGestureRecognizerStateChanged ) {

            CGRect frame = dragIndicator.frame;

            float dx = frame.size.width - 5;
            float dy = frame.size.height - 5;
            frame.origin.x = mousePosition.x - dx;
            frame.origin.y = mousePosition.y - dy;
            dragIndicator.frame = frame;

            // ? dragged out to delete
            CGRect selectedViewFrame = selectedAssetsView.frame;
            float distance = ( selectedViewFrame.origin.y - mousePosition.y );
            if (distance > REMOVE_DRAGGED_ELEMENT_DIST ) {
                dragIndicator.alpha = 0.4;
            } else{
                dragIndicator.alpha = 1.0;
            }

            mousePosition = [recognizer locationInView:self.view];


            // update scroll if needed
            if(autoScrollTimer == nil) {
                autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(handleAutoSizeTimer) userInfo:nil repeats:YES];
                [autoScrollTimer fire];
            }


        } else
        if ( recognizer.state == UIGestureRecognizerStateEnded ) {
            [dragIndicator removeFromSuperview];

            selectedThumb = (SelectedAssetView *)dragIndicator.relatedData;

            //check if should be removed / if not calc new index :P
            CGPoint mousePosition = [recognizer locationInView:self.view];
            CGRect selectedViewFrame = selectedAssetsView.frame;
            float distance = ( selectedViewFrame.origin.y - mousePosition.y );

            if (distance > REMOVE_DRAGGED_ELEMENT_DIST ) {
                [self userSelectedAsset:selectedThumb.asset];
                /// update somehow a table view
            } else {

                CGRect dropFrame = [selectedThumb convertRect:selectedThumb.frame toView:self.view];

                [UIView animateWithDuration:1.0 animations:^(){
                    dragIndicator.frame = dropFrame;
                } completion:^(BOOL done){
                    SelectedAssetView *thumb= (SelectedAssetView *)dragIndicator.relatedData;
                    thumb.dragged = NO;
                    dragIndicator.image = nil;
                    dragIndicator.relatedData = nil;
                }];

            }

            if(autoScrollTimer) {
                [autoScrollTimer invalidate];
            }
            autoScrollTimer = nil;

        }


    }
}

-(void) handleAutoSizeTimer {
    NSLog(@"autoScroll timer fired");

    if (CGPointEqualToPoint(mousePosition, CGPointZero)){
        return;
    }
    
    if(selectedAssetsView.contentSize.width > selectedAssetsView.frame.size.width) {
    

    CGPoint offset = selectedAssetsView.contentOffset;
    float cw = self.view.frame.size.width * 0.5;
    float d_ = mousePosition.x - cw;
    if (fabsf(d_) > cw - 40 ) {

//        float f = ( (cw-fabsf(d_))/40.0 - 1.0);
//        f = f * f * f + 1;

        float scrollDelta = 10;//*f;
//        NSLog(@"offset %@ and ease %f", NSStringFromCGPoint(offset), f);

        float minOffset = -(selectedAssetsView.frame.size.width - selectedAssetsView.contentSize.width - SELECTED_THUMBS_GAP);
        float maxOffset = -SELECTED_THUMBS_GAP;

        float sgn = (d_<0)?-1:1;
        offset.x = MIN( minOffset, MAX( maxOffset, offset.x + sgn * scrollDelta) );

        selectedAssetsView.contentOffset = offset;
    }
        
    }


    SelectedAssetView *selectedThumb = (SelectedAssetView *)dragIndicator.relatedData;

    //try to calc new index by only comparing with neighbours
    float scrollViewDragOffset = selectedAssetsView.contentOffset.x + mousePosition.x;
    int selectedCount = [selectedAssetsThumbnails count];
    int dragIndex = [selectedAssetsThumbnails indexOfObject:selectedThumb];

    CGRect dragRect = selectedThumb.frame;
    float offsetExtra  = dragRect.size.width * 0.5 + SELECTED_THUMBS_GAP;
    float newDropMinOffset = dragRect.origin.x - offsetExtra;
    float newDropMaxOffset = dragRect.origin.x + dragRect.size.width + offsetExtra;

    int dropIndex = dragIndex;
    int leftIndex = MAX( dragIndex-1, 0 );
    int rightIndex = MIN( dragIndex+1, selectedCount-1 );
    if ( scrollViewDragOffset < newDropMinOffset ) {
        dropIndex = leftIndex;
    } else
    if ( scrollViewDragOffset > newDropMaxOffset ) {
        dropIndex = rightIndex;
    }

    if ( dropIndex!=dragIndex ) {
        NSLog(@"New index should be %d",dropIndex);

        SelectedAssetView *thumb = [selectedAssetsThumbnails objectAtIndex:dropIndex];

        [selectedAssetsThumbnails exchangeObjectAtIndex:dragIndex withObjectAtIndex:dropIndex];

        CGRect dragFrame = selectedThumb.frame;
        CGRect dropFrame = thumb.frame;

        [UIView animateWithDuration:0.1 animations:^(){
            thumb.frame = dragFrame;
            selectedThumb.frame = dropFrame;
        } completion:^(BOOL done){
            [self layoutSelectedAssets];
//            [self layoutSelectedAssetWithOffset:CGPointMake(dropFrame.origin.x, 0)];
        }];
    }
}

- (SelectedAssetView *)viewFromRecognizer:(UIGestureRecognizer *)recognizer {
    CGPoint tapPosition = [recognizer locationInView:recognizer.view];
    for ( SelectedAssetView *selectedView in selectedAssetsThumbnails) {
        CGRect frame = selectedView.frame;
        if (CGRectContainsPoint(frame, tapPosition)) {
            NSString *name0 = [NSString stringWithUTF8String:object_getClassName(recognizer)];
            NSString *name1 = [NSString stringWithUTF8String:object_getClassName(selectedView)];
            NSLog(@"%@ detected on - %@", name0, name1);
            return selectedView;
        }
    }
    return nil;
}

- (void)groupEnummerationDone
{
    SFGroupTableViewController *groupTableViewController = [[SFGroupTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self createDefaultButtonsInNavigation:groupTableViewController.navigationItem withCancel:YES];
    groupTableViewController.delegate = self;
    groupTableViewController.model = model;
    [navigationController pushViewController:groupTableViewController animated:YES];
}

- (void)assetsEnummerationDone
{
    SFAssetTableViewController *assetTableViewController = [[SFAssetTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self createDefaultButtonsInNavigation:assetTableViewController.navigationItem withCancel:NO];
    assetTableViewController.delegate = self;
    assetTableViewController.model = model;
    [navigationController pushViewController:assetTableViewController animated:YES];
}

-(void)createDefaultButtonsInNavigation:(UINavigationItem*) navigationItem withCancel:(BOOL) cancel
{
    
    if(cancel == YES) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelImagePicker)];
        [navigationItem setLeftBarButtonItem:cancelButton];
    }

    UIBarButtonItem *acceptButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(acceptImagePicker)];
	[navigationItem setRightBarButtonItem:acceptButton];   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark -- Delegate user decisions --
-(void) cancelImagePicker
{
    if( [self.delegate respondsToSelector:@selector(sfImagePickerContollerDidCancel:)] ) {
        [self.delegate performSelector:@selector(sfImagePickerContollerDidCancel:) withObject:self];
    }
}

-(void) acceptImagePicker
{
    if( [self.delegate respondsToSelector:@selector(sfImagePickerContoller:didFinishWithInfo:)] ) {

        // selected assets NSURL's
        NSArray* info = [NSArray arrayWithArray:model.selectedAssets];
/*
        NSMutableArray *returnArray = [[[NSMutableArray alloc] init] autorelease];
        
        for(ALAsset *asset in model.sele) {
            
            NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
            [workingDictionary setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
            [workingDictionary setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
            [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
            
            [returnArray addObject:workingDictionary];
            
            [workingDictionary release];
        }
 */
        
        
        [self.delegate performSelector:@selector(sfImagePickerContoller:didFinishWithInfo:) withObject:self withObject:[NSArray arrayWithObject:info]];
    }
}



#pragma mark -- Allowed selection size getter/setter --
-(void)setAllowedSelectionSize:(UInt16)value {
    model.allowedSelectionSize = value;
}

-(UInt16)getAllowedSelectionSize {
    return model.allowedSelectionSize;
}


#pragma mark -- SFAssetsControllerDelegate --

-(void)userSelectedGroup:(ALAssetsGroup *)group
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    model.selectedGroup = group;
    
    void (^completeBlock)(ALAsset *result, NSUInteger index, BOOL *stop) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result == nil) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self assetsEnummerationDone];
            });
            return;
        }
        
        [model.selectedGroupAssets addObject:result];
    };
    
    [model.selectedGroup enumerateAssetsUsingBlock:completeBlock];
}

-(SelectedAssetView *)assetThumbnailFromAsset:(ALAsset *)asset {
    NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
    NSString *assetUID= url.absoluteString;

    for ( SelectedAssetView * thumb in selectedAssetsThumbnails ) {
        if ( [thumb.assetUID isEqualToString:assetUID] ) {
            return thumb;
        }
    }

    return nil;
}

-(void)userSelectedAsset:(ALAsset *)asset
{
    if(asset == nil) {
        return;
    }

    NSUInteger selectedCount = [model.selectedAssets count];


    SelectedAssetView *thumb = [self assetThumbnailFromAsset:asset];
    id url = [asset valueForProperty:ALAssetPropertyAssetURL];

    // if selected deselect
    if( nil != thumb ) {

        NSUInteger selectedIndex = [selectedAssetsThumbnails indexOfObject:thumb];
        [thumb removeFromSuperview];
        [selectedAssetsThumbnails removeObjectAtIndex:selectedIndex];
        //remove
            
        [model.selectedAssets removeObjectAtIndex:selectedIndex];

        // update
        thumb = [selectedAssetsThumbnails objectAtIndex:MIN(selectedIndex, selectedCount-2)];
        [self layoutSelectedAssetWithOffset:CGPointMake(thumb.frame.origin.x, 0)];


    } else
    if ( selectedCount < model.allowedSelectionSize) {

        emptySelectionPrompt.hidden = YES;

        CGSize thumbSize = CGSizeMake(SELECTED_THUMB_SIZE, SELECTED_THUMB_SIZE);
        
        thumb = [[SelectedAssetView alloc] initWithFrame:CGRectMake(0, 0, thumbSize.width, thumbSize.height) andAsset:asset];
        [selectedAssetsView addSubview:thumb];
        [selectedAssetsThumbnails addObject:thumb];

        [model.selectedAssets addObject:url];

        // update
        [self layoutSelectedAssetScrollToLast];

    } else {
        //show info
        emptySelectionPrompt.hidden = NO;
        emptySelectionPrompt.alpha = 0.0;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionCurveEaseInOut
                         animations:^(void) {
                             [UIView setAnimationRepeatCount:0.8f];
                             emptySelectionPrompt.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             if(finished) {
                                 emptySelectionPrompt.alpha = 1.0;
                                 emptySelectionPrompt.hidden = YES;
                             }
                         }];

    }
    

}

#pragma mark -- Upadate selected assets view --

-(void) layoutSelectedAssetScrollToLast {
    [self layoutSelectedAssets];
    float lastItemOffset = selectedAssetsView.contentSize.width - SELECTED_THUMB_SIZE;
    [selectedAssetsView scrollRectToVisible:CGRectMake(lastItemOffset, 0, SELECTED_THUMB_SIZE, SELECTED_THUMB_SIZE) animated:NO];
}

-(void) layoutSelectedAssetWithOffset:(CGPoint)offset {
    [self layoutSelectedAssets];
    [selectedAssetsView scrollRectToVisible:CGRectMake(offset.x - SELECTED_THUMBS_GAP, offset.y, SELECTED_THUMB_SIZE, SELECTED_THUMB_SIZE) animated:NO];
//    [selectedAssetsView setContentOffset:offset animated:NO];
}

-(void) layoutSelectedAssets {
    int count = [selectedAssetsThumbnails count];
    if(count) {
        float X = 0;
        int index = 0;
        UIView *thumb = nil;
        while(index<count) {
            thumb = [selectedAssetsThumbnails objectAtIndex:index];
            thumb.frame = CGRectMake( X, 0, thumb.bounds.size.width, thumb.bounds.size.height);
            X += SELECTED_THUMB_SIZE + SELECTED_THUMBS_GAP;
            index += 1;
        }
        
        selectedAssetsView.contentSize = CGSizeMake( X - SELECTED_THUMBS_GAP, thumb.frame.size.height);
    }
}

-(void)dealloc
{
    self.delegate = nil;
    model = nil;
}

@end
