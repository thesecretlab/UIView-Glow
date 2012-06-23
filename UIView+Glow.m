//
//  UIView+Glow.m
//
//  Created by Jon Manning on 29/05/12.
//  Copyright (c) 2012 Secret Lab. All rights reserved.
//

#import "UIView+Glow.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

// Used to identify the associating glowing view
static char* GLOWVIEW_KEY = "GLOWVIEW";

@implementation UIView (Glow)

// Get the glowing view attached to this one.
- (UIView*) glowView {
    return objc_getAssociatedObject(self, GLOWVIEW_KEY);
}

// Attach a view to this one, which we'll use as the glowing view.
- (void) setGlowView:(UIView*)glowView {
    objc_setAssociatedObject(self, GLOWVIEW_KEY, glowView, OBJC_ASSOCIATION_RETAIN);
}

// Create a pulsing, glowing view based on this one.
- (void) startGlowing {
    
    // If we're already glowing, don't bother
    if ([self glowView])
        return;
    
    // The glow image is taken from the current view's appearance.
    // As a side effect, if the view's content, size or shape changes, 
    // the glow won't update.
    UIImage* image;
    
    UIGraphicsBeginImageContext(self.bounds.size); {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
    } UIGraphicsEndImageContext();
    
    // Make the glowing view itself, and position it at the same
    // point as ourself. Overlay it over ourself.
    UIView* glowView = [[UIImageView alloc] initWithImage:image];
    glowView.center = self.center;
    [self.superview insertSubview:glowView aboveSubview:self];
    
    // We don't want to show the image, but rather a shadow created by
    // Core Animation. By setting the shadow to white and the shadow radius to 
    // something large, we get a pleasing glow.
    glowView.alpha = 0;
    glowView.layer.shadowColor = [UIColor whiteColor].CGColor;
    glowView.layer.shadowOffset = CGSizeZero;
    glowView.layer.shadowRadius = 10;
    glowView.layer.shadowOpacity = 0.9;
    
    // Create an animation that slowly fades the glow view in and out forever.
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0.1];
    animation.toValue = [NSNumber numberWithFloat:0.6];
    animation.repeatCount = HUGE_VAL;
    animation.duration = 1.0;
    animation.autoreverses = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [glowView.layer addAnimation:animation forKey:@"pulse"];
    
    // Finally, keep a reference to this around so it can be removed later
    [self setGlowView:glowView];     
}

// Stop glowing by removing the glowing view from the superview 
// and removing the association between it and this object.
- (void) stopGlowing {
    [[self glowView] removeFromSuperview];
    [self setGlowView:nil];
}

@end
