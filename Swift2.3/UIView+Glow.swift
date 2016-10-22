//
//  UIView+Glow.swift
//
//  Translated by Mohamad Nabaa on 10/22/16.
//

import UIKit
import ObjectiveC


private var GLOWVIEW_KEY = "GLOWVIEW"

extension UIView {
    var glowView: UIView? {
        get {
            return objc_getAssociatedObject(self, &GLOWVIEW_KEY) as? UIView
        }
        set(newGlowView) {
            objc_setAssociatedObject(self, &GLOWVIEW_KEY, newGlowView, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    func startGlowingWithColor(color:UIColor, intensity:CGFloat) {
        self.startGlowingWithColor(color, fromIntensity: 0.1, toIntensity: intensity, repeat: true)
    }

    func startGlowingWithColor(color:UIColor, fromIntensity:CGFloat, toIntensity:CGFloat, repeat shouldRepeat:Bool) {
        // If we're already glowing, don't bother
        if self.glowView != nil {
            return
        }

        // The glow image is taken from the current view's appearance.
        // As a side effect, if the view's content, size or shape changes,
        // the glow won't update.
        var image:UIImage






        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.mainScreen().scale); do {
            self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))

            color.setFill()
            path.fillWithBlendMode(.SourceAtop, alpha: 1.0)


            image = UIGraphicsGetImageFromCurrentImageContext()!
        }

        UIGraphicsEndImageContext()

        // Make the glowing view itself, and position it at the same
        // point as ourself. Overlay it over ourself.
        let glowView = UIImageView(image: image)
        glowView.center = self.center
        self.superview!.insertSubview(glowView, aboveSubview:self)

        // We don't want to show the image, but rather a shadow created by
        // Core Animation. By setting the shadow to white and the shadow radius to
        // something large, we get a pleasing glow.
        glowView.alpha = 0
        glowView.layer.shadowColor = color.CGColor
        glowView.layer.shadowOffset = CGSize.zero
        glowView.layer.shadowRadius = 10
        glowView.layer.shadowOpacity = 1.0

        // Create an animation that slowly fades the glow view in and out forever.
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = fromIntensity
        animation.toValue = toIntensity
        animation.repeatCount = shouldRepeat ? .infinity : 0 // HUGE_VAL = .infinity / Thanks http://stackoverflow.com/questions/7082578/cabasicanimation-unlimited-repeat-without-huge-valf
        animation.duration = 1.0
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        glowView.layer.addAnimation(animation, forKey: "pulse")


        // Finally, keep a reference to this around so it can be removed later
        self.glowView = glowView
    }

    func glowOnceAtLocation(point: CGPoint, inView view:UIView) {
        self.startGlowingWithColor(UIColor.whiteColor(), fromIntensity: 0, toIntensity: 0.6, repeat: false)

        self.glowView!.center = point
        view.addSubview(self.glowView!)

        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.stopGlowing()
        })




    }

    func glowOnce() {
        self.startGlowing()

        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.stopGlowing()
        })
    }

    // Create a pulsing, glowing view based on this one.
    func startGlowing() {
        self.startGlowingWithColor(UIColor.whiteColor(), intensity:0.6);
    }

    // Stop glowing by removing the glowing view from the superview
    // and removing the association between it and this object.
    func stopGlowing() {
        if self.glowView != nil{
            self.glowView!.removeFromSuperview()
            self.glowView = nil
        }
    }

}
