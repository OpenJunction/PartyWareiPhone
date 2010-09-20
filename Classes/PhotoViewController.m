//
//  PhotoViewController.m
//  PartyWare
//
//  Created by Alexander Favaro on 8/17/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "PhotoViewController.h"
#import "ASIHTTPRequest.h"
#import "UIImageView+ImageLoading.h"

static NSTimeInterval const HIDE_BARS_AFTER = 3;

@implementation PhotoViewController

@synthesize imageView;
@synthesize captionLabel;
@synthesize activityIndicator;
@synthesize previousButton;
@synthesize nextButton;
@synthesize toolbar;

@synthesize lastTouch;

@synthesize images;

- (void)setLastTouch:(NSDate *)d {
	@synchronized (self) {
		[lastTouch release];
		lastTouch = [d retain];
	}
	self.navigationController.navigationBar.alpha = 1;
	self.toolbar.alpha = 1;
}	

- (id)init {
	return [self initWithNibName:@"PhotoViewController" bundle:[NSBundle mainBundle]];
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)dealloc {
	[images release];
	[lastTouch release];
    [super dealloc];
}

- (void)maybeHideBars {
	if ([[NSDate date] timeIntervalSinceDate:lastTouch] > HIDE_BARS_AFTER) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		 
		self.navigationController.navigationBar.alpha = 0;
		self.toolbar.alpha = 0;
		
		[UIView commitAnimations];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.lastTouch = [NSDate date];
	hideBarsTimer = [NSTimer scheduledTimerWithTimeInterval:1
													 target:self
												   selector:@selector(maybeHideBars)
												   userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[hideBarsTimer invalidate];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.imageView = nil;
	self.captionLabel = nil;
	self.activityIndicator = nil;
	self.previousButton = nil;
	self.nextButton = nil;
	self.toolbar = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	self.lastTouch = [NSDate date];
}

- (void)showActivityIndicator {
	[activityIndicator startAnimating];
}

- (void)hideActivityIndicator {
	[activityIndicator stopAnimating];
}

- (void)loadImageWithURL:(NSURL *)url {
	[self performSelectorOnMainThread:@selector(showActivityIndicator)
						   withObject:nil waitUntilDone:NO];
	[imageView loadImageWithURL:url synchronous:YES];
	[self performSelectorOnMainThread:@selector(hideActivityIndicator)
						   withObject:nil waitUntilDone:NO];
}

- (void)showImageWithIndex:(int)index {
	imageIndex = index;
	imageView.image = nil;
	NSDictionary *imageInfo = [images objectAtIndex:imageIndex];
	[self performSelectorInBackground:@selector(loadImageWithURL:)
						   withObject:[NSURL URLWithString:[imageInfo objectForKey:@"url"]]];
	self.title = [NSString stringWithFormat:@"%d of %d", imageIndex+1, [images count]];
	captionLabel.text = [imageInfo objectForKey:@"caption"];
	previousButton.enabled = (imageIndex > 0);
	nextButton.enabled = (imageIndex+1 < [images count]);
}

- (IBAction)changeImage:(id)sender {
	self.lastTouch = [NSDate date];
	if (sender == previousButton)
		[self showImageWithIndex:--imageIndex];
	else
		[self showImageWithIndex:++imageIndex];
}

@end
