//
//  PhotosViewController.h
//  PartyWare
//
//  Created by Alexander Favaro on 8/10/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@class UploadPhotoViewController;
@class PhotoViewController;
@class PartyWareProp;
@class ThumbnailView;

@interface ThumbnailsViewController : UIViewController
<UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate,
ASIHTTPRequestDelegate, UIScrollViewDelegate> {
	
	UIScrollView *scrollView;
	UILabel *emptyLabel;
	
	PhotoViewController *photoViewController;
	
	PartyWareProp *prop;
	
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *emptyLabel;

@property (retain) PartyWareProp *prop;

- (void)addPhoto:(id)sender;

- (void)propChanged;

- (void)uploadControllerDidUploadImage:(UIImage *)image
							   withURL:(NSString *)urlString
							  thumbURL:(NSString *)thumbURL
							   caption:(NSString *)caption;
- (void)uploadControllerDidCancel;

- (void)thumbnailSelected:(ThumbnailView *)thumbView;

@end

@interface UIScrollView (Paging)

- (int)currentPageIndex;
- (int)pageCount;

- (UIImageView *)imageViewForPage:(int)pageIndex;

- (void)scrollToPage:(int)pageIndex animated:(BOOL)animated;

@end
