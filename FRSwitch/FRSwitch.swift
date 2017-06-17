//
//  FRSwitch.swift
//
//  Created by Nikola Ristic on 3/5/16.
//  Copyright © 2016 nr. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
open class FRSwitch: UIControl {
    let initialFrame = CGRect(x: 0, y: 0, width: 61, height: 22)
    var arc: CAShapeLayer?

    // internal
    internal var backgroundView: UIView!
    internal var thumbView: UIView!
    internal var onImageView: UIImageView!
    internal var offImageView: UIImageView!
    internal var thumbImageView: UIImageView!

    // private
    private var currentVisualValue: Bool = false
    private var isAnimating: Bool = false
    private var userDidSpecifyOnThumbTintColor: Bool = false
    private var switchValue: Bool = false
    private var tapGesture: UITapGestureRecognizer!

    // MARK: - Public

    /// Wheter the switch is on or off
    @IBInspectable open var on: Bool { //swiftlint:disable:this identifier_name
        get {
            return switchValue
        }
        set {
            switchValue = newValue
            self.setOn(newValue, animated: false)
        }
    }

    /// Background color when the switch is off and being touched. Defaults to light gray.
    @IBInspectable open var activeColor: UIColor = UIColor.lightGray {
        willSet {
            if self.on && !self.isTracking {
                backgroundView.backgroundColor = newValue
            }
        }
    }

    /// Background color when the switch is off. Defaults to clear color.
    @IBInspectable open var inactiveColor: UIColor = UIColor.clear {
        willSet {
            if !self.on && !self.isTracking {
                backgroundView.backgroundColor = newValue
            }
        }
    }

    /// Background color that shows when the switch is on. Defaults to green.
    @IBInspectable open var onTintColor: UIColor = UIColor.green {
        willSet {
            if self.on && !self.isTracking {
                backgroundView.backgroundColor = newValue
                backgroundView.layer.borderColor = newValue.cgColor
            }
        }
    }

    /// Border color when the switch is off. Defaults to light gray.
    @IBInspectable open var borderColor: UIColor = UIColor.lightGray {
        willSet {
            if !self.on {
                backgroundView.layer.borderColor = newValue.cgColor
            }
        }
    }

    /// Knob color. Defaults to light gray.
    @IBInspectable open var thumbTintColor: UIColor = UIColor.lightGray {
        willSet {
            if !userDidSpecifyOnThumbTintColor {
                onThumbTintColor = newValue
            }
            if (!userDidSpecifyOnThumbTintColor || !self.on) && !self.isTracking {
                thumbView.backgroundColor = newValue
            }
        }
    }

    /// Knob color when the switch is on. Defaults to white.
    @IBInspectable open var onThumbTintColor: UIColor = UIColor.white {
        willSet {
            userDidSpecifyOnThumbTintColor = true
            if self.on && !self.isTracking {
                thumbView.backgroundColor = newValue
            }
        }
    }

    /// Thumb border color.
    @IBInspectable var thumbBorderColor: UIColor = UIColor.darkGray

    /// Shadow color of the knob. Defaults to gray.
    @IBInspectable open var thumbShadowColor: UIColor = UIColor.gray {
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
                backgroundView.layer.cornerRadius = initialFrame.size.height * 0.5
                thumbView.layer.cornerRadius = (initialFrame.size.height * 0.5) - 1
            } else {
                backgroundView.layer.cornerRadius = 2
                thumbView.layer.cornerRadius = 2
            }

            thumbView.layer.shadowPath = UIBezierPath(
                roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).cgPath
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

    // MARK: - Initialization

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

    deinit {
        removeGestureRecognizer(tapGesture)
    }

    // MARK: - Utilities

    /*
    *   Setup the individual elements of the switch and set default values
    */
    private func setup() {
        setupBackground()
        setupImages()
        setupLabels()
        setupThumb()
        on = false
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(switchTapped(_:)))
        addGestureRecognizer(tapGesture)
    }

    /**
     Sets up the background component of the switch.
     */
    func setupBackground() {
        backgroundColor = UIColor.clear
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: initialFrame.width, height: initialFrame.height))
        backgroundView.backgroundColor = UIColor.clear
        backgroundView.layer.cornerRadius = initialFrame.height * 0.5
        backgroundView.layer.borderColor = self.borderColor.cgColor
        backgroundView.layer.borderWidth = 5.0
        backgroundView.isUserInteractionEnabled = false
        backgroundView.clipsToBounds = true
        self.addSubview(backgroundView)
    }

    /**
     Sets up the on and off images of the switch.
     */
    func setupImages() {
        onImageView = UIImageView(frame: CGRect(x: 0, y: 0,
                                                width: initialFrame.width - initialFrame.height, height: initialFrame.height))
        onImageView.alpha = 1.0
        onImageView.contentMode = UIViewContentMode.center
        backgroundView.addSubview(onImageView)

        offImageView = UIImageView(frame: CGRect(x: initialFrame.height, y: 0,
                                                 width: initialFrame.width - initialFrame.height, height: initialFrame.height))
        offImageView.alpha = 1.0
        offImageView.contentMode = UIViewContentMode.center
        backgroundView.addSubview(offImageView)
    }

    /**
     Sets up the on and off labels of the switch.
     */
    func setupLabels() {
        onLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                        width: initialFrame.width - initialFrame.height, height: initialFrame.height))
        onLabel.textAlignment = NSTextAlignment.center
        onLabel.textColor = UIColor.lightGray
        onLabel.font = UIFont.systemFont(ofSize: 12)
        backgroundView.addSubview(onLabel)

        offLabel = UILabel(frame: CGRect(x: initialFrame.height, y: 0,
                                         width: initialFrame.width - initialFrame.height, height: initialFrame.height))
        offLabel.textAlignment = NSTextAlignment.center
        offLabel.textColor = UIColor.lightGray
        offLabel.font = UIFont.systemFont(ofSize: 12)
        backgroundView.addSubview(offLabel)
    }

    /**
     Sets up the thumb component of the switch.
     */
    func setupThumb() {
        thumbView = UIView(frame: CGRect(x: 0.5, y: 0.5,
                                         width: initialFrame.height - 2, height: initialFrame.height - 2))
        thumbView.backgroundColor = self.thumbTintColor
        thumbView.layer.cornerRadius = (initialFrame.height * 0.5) - 1

        arc = CAShapeLayer()
        arc!.lineWidth = 6
        arc!.path = UIBezierPath(roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).cgPath
        arc!.strokeStart = 0
        arc!.strokeEnd = 1
        arc!.lineCap = "round"
        arc!.strokeColor = thumbBorderColor.cgColor
        arc!.fillColor = thumbTintColor.cgColor
        arc!.shadowColor = thumbShadowColor.cgColor
        arc!.frame = thumbView.frame
        thumbView.layer.addSublayer(arc!)

        thumbView.layer.shadowColor = thumbShadowColor.cgColor
        thumbView.layer.shadowRadius = 2.0
        thumbView.layer.shadowOpacity = 0.5
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 3)
        thumbView.layer.shadowPath = UIBezierPath(
            roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).cgPath
        thumbView.layer.masksToBounds = false
        thumbView.isUserInteractionEnabled = false
        addSubview(thumbView)

        // thumb image
        thumbImageView = UIImageView(frame: CGRect(x: 0, y: 0,
                                                   width: thumbView.frame.size.width, height: thumbView.frame.size.height))
        thumbImageView.contentMode = UIViewContentMode.center
        thumbImageView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        thumbView.addSubview(thumbImageView)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
    }

    /*
    *   Set the state of the switch to on or off, optionally animating the transition.
    */
    open func setOn(_ isOn: Bool, animated: Bool) {
        switchValue = isOn
        self.setValueLayout(value: on, animated)
    }

    /**
     Flag specifying wheter the swithc i on of off
     */
    var isOn: Bool {
        return on
    }

    func setValueLayout(value: Bool, _ animated: Bool) {
        let knobWidth: CGFloat = initialFrame.height - 2

        let frameX = value ? self.initialFrame.width - (knobWidth + 1) : 1
        let frameY = self.thumbView.frame.origin.y
        let frameWidth = knobWidth
        let frameHeight = self.thumbView.frame.size.height

        let funkyBlock = {
                self.thumbView.frame = CGRect(x: frameX, y: frameY, width: frameWidth, height: frameHeight)
        }

        if animated {
            isAnimating = true
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState],
                           animations: {
                                funkyBlock()
                            }, completion: { _ in
                                self.isAnimating = false
                            })
        } else {
            funkyBlock()
        }

        backgroundView.backgroundColor = value ? onTintColor : onThumbTintColor
        backgroundView.layer.borderColor = value ? onTintColor.cgColor : borderColor.cgColor
        thumbView.backgroundColor = value ? onThumbTintColor : thumbTintColor
        onImageView.alpha = value ? 1.0 : 0.0
        offImageView.alpha = value ? 0.0 : 1.0
        onLabel.alpha = value ? 1.0 : 0.0
        offLabel.alpha = value ? 0.0 : 1.0

        currentVisualValue = value
    }

    override open var intrinsicContentSize: CGSize {
        return initialFrame.size
    }

    // MARK: - User gestures

    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return super.beginTracking(touch, with: event)
    }

    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)

        // Get touch location
        let lastPoint = touch.location(in: self)

        // update the switch to the correct visuals depending on if
        // they moved their touch to the right or left side of the switch
        let isMovedToOn = lastPoint.x > initialFrame.width * 0.5
        if (currentVisualValue && !isMovedToOn) || (!currentVisualValue && isMovedToOn) {
            setValueLayout(value: isMovedToOn, true)
        }
        return true
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        if currentVisualValue != on {
            setOn(!self.on, animated: true)
            sendActions(for: UIControlEvents.valueChanged)
        }
    }

    override open func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        setValueLayout(value: on, true)
    }

    func switchTapped(_ sender: Any) {
        setOn(!on, animated: true)
    }

}
