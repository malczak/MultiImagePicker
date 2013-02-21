//
//  SFViewController.m
//  SFImagePicker
//
//  Created by malczak on 1/7/13.
//  Copyright (c) 2013 segfaultsoft. All rights reserved.
//

#import "SFViewController.h"
#import "SFMultiImagePickerController.h"
#import "SFBusyOverlayerView.h"

@interface SFViewController ()

@property (nonatomic, retain) IBOutlet UIScrollView *imageScrollView;
@property (nonatomic, retain) IBOutlet UILabel *label;

@end

@implementation SFViewController

@synthesize showPickerButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIScreen *s = [UIScreen mainScreen];
    [s scale];

    [showPickerButton addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPicker:(id)sender
{
    
    SFMultiImagePickerController *imagePicker = [[SFMultiImagePickerController alloc] init];
    imagePicker.delegate = self;
    [imagePicker setAllowedSelectionSize:20];
    [self presentViewController:imagePicker animated:YES completion:nil];    
}

#pragma mark -- sfImagePickerDelegate methods --
-(void)imagePickerContoller:(SFMultiImagePickerController *)imagePicker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"BusyOverlayerView" owner:self options:nil];
    __block SFBusyOverlayerView *busyIndicator = (SFBusyOverlayerView*)[views objectAtIndex:0];
    busyIndicator.frame = self.view.bounds;
    [self.view addSubview:busyIndicator];
    
    // create images :D
    __block NSMutableArray* images = [[NSMutableArray alloc] init];
    
    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    dispatch_async(queue, ^(void) {
        
        for (NSDictionary *imageInfo in info) {
            ALAsset *asset = [imageInfo objectForKey:SFImagePickerControllerAsset];
            
            UIImage *image = [UIImage imageWithCGImage:[asset defaultRepresentation].fullScreenImage];
            [images addObject:image];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void){
        
        
        CGSize scrollSize = self.imageScrollView.bounds.size;
        
        int numImages = info.count;
        
        self.label.text = [NSString stringWithFormat:@"Selected %d images", numImages];
        
        float X = 0;
        for (NSDictionary *imageInfo in info) {
            ALAsset *asset = [imageInfo objectForKey:SFImagePickerControllerAsset];
            
            UIImage *image = [UIImage imageWithCGImage:[asset defaultRepresentation].fullScreenImage];
            //[imageInfo objectForKey:SFImagePickerControllerFullScreenImage];
            
            CGRect frame = CGRectMake(X, 0, scrollSize.width, scrollSize.height);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = image;
            [self.imageScrollView addSubview:imageView];
            
            X += scrollSize.width;
        }
        
        self.imageScrollView.contentSize = CGSizeMake(X, scrollSize.height);
        
        [busyIndicator removeFromSuperview];
        
        });

    });
    
    
    

}

-(void)imagePickerContollerDidCancel:(SFMultiImagePickerController *)imagePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end