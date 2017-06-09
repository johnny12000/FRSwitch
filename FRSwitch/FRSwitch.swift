//
//  FRSwitch.swift
//
//  Created by Nikola Ristic on 3/5/16.
//  Copyright © 2016 nr. All rights reserved.
//

import UIKit
import QuartzCore

open class FRSwitch: UIControl {
    let initialFrame = CGRect(x: 0, y: 0, width: 61, height: 22)
    var arc: CAShapeLayer?
    // public

    /*
    *   Set (without animation) whether the switch is on or off
    */
    @IBInspectable open var on: Bool {
        get {
            return switchValue
        }
        set {
            switchValue = newValue
            self.setOn(newValue, animated: false)
        }
    }

    /*
    *	Sets the background color that shows when the switch off and actively being touched.
    *   Defaults to light gray.
    */
    @IBInspectable open var activeColor: UIColor = UIColor.gray {
        willSet {
            if self.on && !self.isTracking {
                backgroundView.backgroundColor = newValue
            }
        }
    }

    /*
    *	Sets the background color when the switch is off.
    *   Defaults to clear color.
    */
    @IBInspectable open var inactiveColor: UIColor = UIColor.black {
        willSet {
            if !self.on && !self.isTracking {
                backgroundView.backgroundColor = newValue
            }
        }
    }

    /*
    *   Sets the background color that shows when the switch is on.
    *   Defaults to green.
    */
    @IBInspectable open var onTintColor: UIColor = UIColor.green {
        willSet {
            if self.on && !self.isTracking {
                backgroundView.backgroundColor = newValue
                backgroundView.layer.borderColor = newValue.cgColor
            }
        }
    }

    /*
    *   Sets the border color that shows when the switch is off. Defaults to light gray.
    */
    @IBInspectable open var borderColor: UIColor = UIColor.brown {
        willSet {
            if !self.on {
                backgroundView.layer.borderColor = newValue.cgColor
            }
        }
    }

    /*
    *	Sets the knob color. Defaults to white.
    */
    @IBInspectable open var thumbTintColor: UIColor = UIColor.blue {
        willSet {
            if !userDidSpecifyOnThumbTintColor {
                onThumbTintColor = newValue
            }
            if (!userDidSpecifyOnThumbTintColor || !self.on) && !self.isTracking {
                thumbView.backgroundColor = newValue
            }
        }
    }

    /*
    *	Sets the knob color that shows when the switch is on. Defaults to white.
    */
    @IBInspectable open var onThumbTintColor: UIColor = UIColor.white {
        willSet {
            userDidSpecifyOnThumbTintColor = true
            if self.on && !self.isTracking {
                thumbView.backgroundColor = newValue
            }
        }
    }

    /*
    *	Sets the shadow color of the knob. Defaults to gray.
    */
    @IBInspectable open var shadowColor: UIColor = UIColor.black {
        willSet {
            thumbView.layer.shadowColor = newValue.cgColor
        }
    }

    /*
    *	Sets whether or not the switch edges are rounded.
    *   Set to NO to get a stylish square switch.
    *   Defaults to YES.
    */
    @IBInspectable open var isRounded: Bool = true {
        willSet {
            if newValue {
                backgroundView.layer.cornerRadius = self.frame.size.height * 0.5
                thumbView.layer.cornerRadius = (self.frame.size.height * 0.5) - 1
            } else {
                backgroundView.layer.cornerRadius = 2
                thumbView.layer.cornerRadius = 2
            }

            thumbView.layer.shadowPath = UIBezierPath(roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).cgPath
        }
    }

    /*
    *   Sets the image that shows on the switch thumb.
    */
    @IBInspectable open var thumbImage: UIImage! {
        willSet {
            thumbImageView.image = newValue
        }
    }

    /*
    *   Sets the image that shows when the switch is on.
    *   The image is centered in the area not covered by the knob.
    *   Make sure to size your images appropriately.
    */
    @IBInspectable open var onImage: UIImage! {
        willSet {
            onImageView.image = newValue
        }
    }

    /*
    *	Sets the image that shows when the switch is off.
    *   The image is centered in the area not covered by the knob.
    *   Make sure to size your images appropriately.
    */
    @IBInspectable open var offImage: UIImage! {
        willSet {
            offImageView.image = newValue
        }
    }

    /*
    *	Sets the text that shows when the switch is on.
    *   The text is centered in the area not covered by the knob.
    */
    open var onLabel: UILabel!

    /*
    *	Sets the text that shows when the switch is off.
    *   The text is centered in the area not covered by the knob.
    */
    open var offLabel: UILabel!

    // internal
    internal var backgroundView: UIView!
    internal var thumbView: UIView!
    internal var onImageView: UIImageView!
    internal var offImageView: UIImageView!
    internal var thumbImageView: UIImageView!
    // private
    fileprivate var currentVisualValue: Bool = false
    fileprivate var startTrackingValue: Bool = false
    fileprivate var didChangeWhileTracking: Bool = false
    fileprivate var isAnimating: Bool = false
    fileprivate var userDidSpecifyOnThumbTintColor: Bool = false
    fileprivate var switchValue: Bool = false

    /*
    *   Initialization
    */
    public convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 61, height: 22))
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    override public init(frame: CGRect) {
        let initialFrame = CGRect(x: 0, y: 0, width: 61, height: 22)
        super.init(frame: initialFrame)

        self.setup()
    }

    /*
    *   Setup the individual elements of the switch and set default values
    */
    fileprivate func setup() {
        self.backgroundColor = UIColor.clear
        // background
        self.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: initialFrame.width, height: initialFrame.height))
        backgroundView.backgroundColor = UIColor.clear
        backgroundView.layer.cornerRadius = initialFrame.height * 0.5
        backgroundView.layer.borderColor = self.borderColor.cgColor
        backgroundView.layer.borderWidth = 5.0
        backgroundView.isUserInteractionEnabled = false
        backgroundView.clipsToBounds = true
        self.addSubview(backgroundView)

        // on/off images
        self.onImageView = UIImageView(frame: CGRect(x: 0, y: 0,
            width: initialFrame.width - initialFrame.height,
            height: initialFrame.height))
        onImageView.alpha = 1.0
        onImageView.contentMode = UIViewContentMode.center
        backgroundView.addSubview(onImageView)

        self.offImageView = UIImageView(frame: CGRect(x: initialFrame.height,
            y: 0,
            width: initialFrame.width - initialFrame.height,
            height: initialFrame.height))
        offImageView.alpha = 1.0
        offImageView.contentMode = UIViewContentMode.center
        backgroundView.addSubview(offImageView)

        // labels
        self.onLabel = UILabel(frame: CGRect(x: 0, y: 0,
            width: initialFrame.width - initialFrame.height,
            height: initialFrame.height))
        onLabel.textAlignment = NSTextAlignment.center
        onLabel.textColor = UIColor.lightGray
        onLabel.font = UIFont.systemFont(ofSize: 12)
        backgroundView.addSubview(onLabel)

        self.offLabel = UILabel(frame: CGRect(x: initialFrame.height,
            y: 0,
            width: initialFrame.width - initialFrame.height,
            height: initialFrame.height))
        offLabel.textAlignment = NSTextAlignment.center
        offLabel.textColor = UIColor.lightGray
        offLabel.font = UIFont.systemFont(ofSize: 12)
        backgroundView.addSubview(offLabel)

        // thumb
        self.thumbView = UIView(frame: CGRect(x: 1,
            y: 1,
            width: initialFrame.height - 2,
            height: initialFrame.height - 2))
        thumbView.backgroundColor = self.thumbTintColor
        thumbView.layer.cornerRadius = (initialFrame.height * 0.5) - 1

        self.arc = CAShapeLayer()
        arc!.lineWidth = 6
        arc!.path = UIBezierPath(roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).cgPath
        arc!.strokeStart = 0
        arc!.strokeEnd = 1
        arc!.lineCap = "round"
        arc!.strokeColor = UIColor.red.cgColor
        arc!.fillColor = UIColor.blue.cgColor
        arc!.shadowColor = UIColor.black.cgColor
        arc!.frame = thumbView.frame
        thumbView.layer.addSublayer(arc!)

        thumbView.layer.shadowColor = self.shadowColor.cgColor
        thumbView.layer.shadowRadius = 2.0
        thumbView.layer.shadowOpacity = 0.5
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 3)
        thumbView.layer.shadowPath = UIBezierPath(roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).cgPath
        thumbView.layer.masksToBounds = false
        thumbView.isUserInteractionEnabled = false
        self.addSubview(thumbView)

        // thumb image
        self.thumbImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: thumbView.frame.size.width, height: thumbView.frame.size.height))
        thumbImageView.contentMode = UIViewContentMode.center
        thumbImageView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        thumbView.addSubview(thumbImageView)

        self.on = false
    }

    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)

        startTrackingValue = self.on
        didChangeWhileTracking = false

        let activeKnobWidth = initialFrame.height - 2 + 5
        isAnimating = true

        UIView.animate(withDuration: 0.3, delay: 0.0, options: [UIViewAnimationOptions.curveEaseOut, UIViewAnimationOptions.beginFromCurrentState], animations: {
            if self.on {
                self.thumbView.frame = CGRect(x: self.initialFrame.width - (activeKnobWidth + 1),
                    y: self.thumbView.frame.origin.y,
                    width: activeKnobWidth,
                    height: self.thumbView.frame.size.height)
                self.backgroundView.backgroundColor = self.onTintColor
                self.thumbView.backgroundColor = self.onThumbTintColor
            } else {
                self.thumbView.frame = CGRect(x: self.thumbView.frame.origin.x, y: self.thumbView.frame.origin.y,
                    width: activeKnobWidth,
                    height: self.thumbView.frame.size.height)
                self.backgroundView.backgroundColor = self.activeColor
                self.thumbView.backgroundColor = self.thumbTintColor
            }
            }, completion: { _ in
                self.isAnimating = false
        })

        return true
    }

    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)

        // Get touch location
        let lastPoint = touch.location(in: self)

        // update the switch to the correct visuals depending on if
        // they moved their touch to the right or left side of the switch
        if lastPoint.x > initialFrame.width * 0.5 {
            self.showOn(true)
            if !startTrackingValue {
                didChangeWhileTracking = true
            }
        } else {
            self.showOff(true)
            if startTrackingValue {
                didChangeWhileTracking = true
            }
        }

        return true
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)

        let previousValue = self.on

        if didChangeWhileTracking {
            self.setOn(currentVisualValue, animated: true)
        } else {
            self.setOn(!self.on, animated: true)
        }

        if previousValue != self.on {
            self.sendActions(for: UIControlEvents.valueChanged)
        }
    }

    override open func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)

        // just animate back to the original value
        if self.on {
            self.showOn(true)
        } else {
            self.showOff(true)
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
    }

    /*
    *   Set the state of the switch to on or off, optionally animating the transition.
    */
    open func setOn(_ isOn: Bool, animated: Bool) {
        switchValue = isOn

        if on {
            self.showOn(animated)
        } else {
            self.showOff(animated)
        }
    }

    /*
    *   Detects whether the switch is on or off
    *
    *	@return	BOOL YES if switch is on. NO if switch is off
    */
    open func isOn() -> Bool {
        return self.on
    }

    /*
    *   update the looks of the switch to be in the on position
    *   optionally make it animated
    */
    fileprivate func showOn(_ animated: Bool) {
        let normalKnobWidth: CGFloat = initialFrame.height - 2
        let activeKnobWidth = normalKnobWidth + 5
        if animated {
            isAnimating = true
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [UIViewAnimationOptions.curveEaseOut, UIViewAnimationOptions.beginFromCurrentState], animations: {
                if self.isTracking {
                    self.thumbView.frame = CGRect(x: self.initialFrame.width - (activeKnobWidth + 1),
                        y: self.thumbView.frame.origin.y,
                        width: activeKnobWidth,
                        height: self.thumbView.frame.size.height)
                } else {
                    self.thumbView.frame = CGRect(x: self.initialFrame.width - (normalKnobWidth + 1),
                        y: self.thumbView.frame.origin.y,
                        width: normalKnobWidth,
                        height: self.thumbView.frame.size.height)
                }
                self.backgroundView.backgroundColor = self.onTintColor
                self.backgroundView.layer.borderColor = self.onTintColor.cgColor
                self.thumbView.backgroundColor = self.onThumbTintColor
                self.onImageView.alpha = 1.0
                self.offImageView.alpha = 0
                self.onLabel.alpha = 1.0
                self.offLabel.alpha = 0
                }, completion: { _ in
                    self.isAnimating = false
            })
        } else {
            if self.isTracking {
                thumbView.frame = CGRect(x: initialFrame.width - (activeKnobWidth + 1),
                    y: thumbView.frame.origin.y,
                    width: activeKnobWidth,
                    height: thumbView.frame.size.height)
            } else {
                thumbView.frame = CGRect(x: initialFrame.width - (normalKnobWidth + 1),
                    y: thumbView.frame.origin.y,
                    width: normalKnobWidth,
                    height: thumbView.frame.size.height)
            }

            backgroundView.backgroundColor = self.onTintColor
            backgroundView.layer.borderColor = self.onTintColor.cgColor
            thumbView.backgroundColor = self.onThumbTintColor
            onImageView.alpha = 1.0
            offImageView.alpha = 0
            onLabel.alpha = 1.0
            offLabel.alpha = 0
        }

        currentVisualValue = true
    }

    /*
    *   update the looks of the switch to be in the off position
    *   optionally make it animated
    */
    fileprivate func showOff(_ animated: Bool) {
        let normalKnobWidth: CGFloat = initialFrame.height - 2
        let activeKnobWidth = normalKnobWidth + 5

        if animated {
            isAnimating = true
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [UIViewAnimationOptions.curveEaseOut, UIViewAnimationOptions.beginFromCurrentState], animations: {
                if self.isTracking {
                    self.thumbView.frame = CGRect(x: 1,
                        y: self.thumbView.frame.origin.y,
                        width: activeKnobWidth,
                        height: self.thumbView.frame.size.height)
                    self.backgroundView.backgroundColor = self.activeColor
                } else {
                    self.thumbView.frame = CGRect(x: 1,
                        y: self.thumbView.frame.origin.y,
                        width: normalKnobWidth,
                        height: self.thumbView.frame.size.height)
                    self.backgroundView.backgroundColor = self.inactiveColor
                }

                self.backgroundView.layer.borderColor = self.borderColor.cgColor
                self.thumbView.backgroundColor = self.thumbTintColor
                self.onImageView.alpha = 0
                self.offImageView.alpha = 1.0
                self.onLabel.alpha = 0
                self.offLabel.alpha = 1.0
                }, completion: { _ in
                    self.isAnimating = false
            })
        } else {
            if (self.isTracking) {
                thumbView.frame = CGRect(x: 1,
                    y: thumbView.frame.origin.y,
                    width: activeKnobWidth,
                    height: thumbView.frame.size.height)
                backgroundView.backgroundColor = self.activeColor
            } else {
                thumbView.frame = CGRect(x: 1,
                    y: thumbView.frame.origin.y,
                    width: normalKnobWidth,
                    height: thumbView.frame.size.height)
                backgroundView.backgroundColor = self.inactiveColor
            }
            backgroundView.layer.borderColor = self.borderColor.cgColor
            thumbView.backgroundColor = self.thumbTintColor
            onImageView.alpha = 0
            offImageView.alpha = 1.0
            onLabel.alpha = 0
            offLabel.alpha = 1.0
        }

        currentVisualValue = false
    }

    override open var intrinsicContentSize: CGSize {
        return initialFrame.size
    }

}
