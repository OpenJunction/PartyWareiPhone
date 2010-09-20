//
//  PhotosViewController.m
//  PartyWare
//
//  Created by Alexander Favaro on 8/10/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "ThumbnailsViewController.h"
#import "UploadPhotoViewController.h"
#import "PhotoViewController.h"
#import "PartyWareProp.h"
#import "ASIHTTPRequest.h"
#import "ThumbnailView.h"
#import "PartyWareAppDelegate.h"

#import <assert.h>


#define SCREEN_SIZE ([UIScreen mainScreen].applicationFrame.size)

static CGFloat const THUMB_PADDING = 5;
static int const THUMBS_PER_ROW = 4;

@implementation ThumbnailsViewController

@synthesize scrollView;
@synthesize emptyLabel;

@synthesize prop;

- (void)setProp:(PartyWareProp *)p {
	[prop release];
	prop = [p retain];
	photoViewController.images = [prop objectsWithType:@"image"];
}

- (void)awakeFromNib {
	photoViewController = [[PhotoViewController alloc] init];
}

- (void)dealloc {
	[prop release];
	[photoViewController release];
    [super dealloc];
}

- (void)loadThumbnails:(NSArray *)images {
	[scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	int count = [images count];
	if (count > 0) {
		CGFloat thumbSize = (SCREEN_SIZE.width - (THUMBS_PER_ROW+1)*THUMB_PADDING) / THUMBS_PER_ROW;
		int numRows = count/THUMBS_PER_ROW + 1;
		
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,
											THUMB_PADDING + numRows*(thumbSize+THUMB_PADDING));
		
		for (int i = 0; i < count; i++) {
			int row = i / THUMBS_PER_ROW;
			int col = i % THUMBS_PER_ROW;
			
			CGRect frame = CGRectMake(THUMB_PADDING + col*(thumbSize+THUMB_PADDING),
									  THUMB_PADDING + row*(thumbSize+THUMB_PADDING),
									  thumbSize, thumbSize);
			ThumbnailView *thumbView = [[ThumbnailView alloc] initWithFrame:frame];
			thumbView.tag = i;
			thumbView.delegate = self;
			[thumbView loadThumbnailFromInfo:[images objectAtIndex:i]];
			
			[scrollView addSubview:[thumbView autorelease]];
		}
	} else {
		scrollView.contentSize = CGSizeZero;
		[scrollView addSubview:emptyLabel];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.translucent = YES;
	
	[self loadThumbnails:[prop objectsWithType:@"image"]];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.scrollView = nil;
	self.emptyLabel = nil;
}

- (void)propChanged {
	NSArray *images = [prop objectsWithType:@"image"];
	[self performSelectorOnMainThread:@selector(loadThumbnails:) withObject:images waitUntilDone:NO];
	photoViewController.images = images;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint location = [[touches anyObject] locationInView:scrollView];
	NSLog(@"touched view: %@", [scrollView hitTest:location withEvent:event]);
}

- (void)addPhoto:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Photo"
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Photo Library", @"Take Photo", nil];
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	switch (buttonIndex) {
		case 0:
			imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentModalViewController:imagePicker animated:YES];
			break;
		case 1:
			imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			[self presentModalViewController:imagePicker animated:YES];
			break;
		default:
			break;
	}
	[imagePicker release];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self dismissModalViewControllerAnimated:NO];
	
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	UploadPhotoViewController *uploadController = [[UploadPhotoViewController alloc] initWithDelegate:self image:image];
	[self presentModalViewController:[uploadController autorelease] animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)uploadControllerDidUploadImage:(UIImage *)image
							   withURL:(NSString *)urlString
							  thumbURL:(NSString *)thumbURL
							   caption:(NSString *)caption {
	[self dismissModalViewControllerAnimated:YES];
	[prop addImageWithUserID:APP_DELEGATE.userID url:urlString thumbURL:thumbURL
					 caption:caption time:(long)time(0)];
}

- (void)uploadControllerDidCancel {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)thumbnailSelected:(ThumbnailView *)thumbView {
	[self.navigationController pushViewController:photoViewController animated:YES];
	[photoViewController showImageWithIndex:thumbView.tag];
}

@end

@implementation UIScrollView (Paging)

- (int)currentPageIndex {
	return self.contentOffset.x / self.contentSize.width;
}

- (int)pageCount {
	return self.contentSize.width / self.frame.size.width;
}

- (UIImageView *)imageViewForPage:(int)pageIndex {
	CGFloat offset = pageIndex * self.frame.size.width;
	for (UIView *view in self.subviews) {
		if (view.frame.origin.x == offset &&
			[view isKindOfClass:[UIImageView class]])
			return (UIImageView *)view;
	}
	return nil;
}

- (void)scrollToPage:(int)pageIndex animated:(BOOL)animated {
	[self setContentOffset:CGPointMake(pageIndex * self.frame.size.width, 0)
				  animated:animated];
}

@end

