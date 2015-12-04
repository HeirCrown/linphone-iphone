//
//  UIRoundedImageView.m
//  linphone
//
//  Created by guillaume on 13/05/2014.
//
//

#import "UIRoundedImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"

@implementation UIRoundedImageView {
	UIView *borderView;
}

INIT_WITH_COMMON {
	borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	borderView.hidden = YES;
	[self addSubview:borderView];

	[self setRoundRadius];
	[self setBordered:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(orientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification"
											   object:nil];

	//	self.layer.borderWidth = 1;
	//	self.layer.borderColor = [UIColor redColor].CGColor;
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientationDidChange:(NSNotification *)k {
	[self setRoundRadius];
}

- (void)setImage:(UIImage *)image {
	[self setImage:image bordered:NO withRoundedRadius:TRUE];
}

- (void)setImage:(UIImage *)image bordered:(BOOL)bordered withRoundedRadius:(BOOL)rounded {
	// We have to scale image to layers limits so that when we round image, we have a proper circle
	[super setImage:[image scaleToSize:self.frame.size squared:YES]];
	[self setBordered:bordered];
	[self setRoundRadius];
}

- (void)setBordered:(BOOL)bordered {
	borderView.hidden = !bordered;
	if (bordered) {
		CGRect frame = self.frame;
		frame.size.height = frame.size.width = MIN(self.layer.frame.size.height, self.layer.frame.size.width);
		frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
		frame.origin.y = (self.frame.size.height - frame.size.height) / 2;
		borderView.frame = frame;
		self.layer.borderWidth = 10;
		//		[borderView.layer setCornerRadius:frame.size.height / 2];
		self.layer.borderColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"color_A.png"]].CGColor;
	} else {
		self.layer.borderWidth = 0;
	}
}

- (void)setRoundRadius {
	CALayer *imageLayer = self.layer;

	CGFloat height = imageLayer.frame.size.height;
	CGFloat width = imageLayer.frame.size.width;
	CGFloat roundRadius = MIN(width, height) / 2;

	[imageLayer setCornerRadius:roundRadius];
	[imageLayer setMasksToBounds:YES];
}

@end
