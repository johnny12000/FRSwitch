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
    internal var backgroundView: UIView!
    internal var thumbView: UIView!
    internal var onImageView: UIImageView!
    internal var offImageView: UIImageView!
    internal var thumbImageView: UIImageView!

    private var currentVisualValue: Bool = false
    private var userDidSpecifyOnThumbTintColor: Bool = false
    private var switchValue: Bool = false
    private var tapGesture: UITapGestureRecognizer!
    private let initialFrame = CGRect(x: 0, y: 0, width: 61, height: 22)
    private var arc: CAShapeLayer?

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

    /// Background border color when the switch is on. Defaults to light gray.
    @IBInspectable open var backgroundBorderOnColor: UIColor = UIColor.lightGray {
        didSet {
            setupBackground()
        }
    }

    /// Background border color when the switch is off. Defaults to clear color.
    @IBInspectable open var backgroundBorderOffColor: UIColor = UIColor.clear {
        didSet {
            setupBackground()
        }
    }

    /// Background color when the switch is on. Defaults to green.
    @IBInspectable open var backgroundOnColor: UIColor = UIColor.green {
        didSet {
            setupBackground()
        }
    }

    /// Border color when the switch is off. Defaults to light gray.
    @IBInspectable open var backgroundOffColor: UIColor = UIColor.lightGray {
        didSet {
            setupBackground()
        }
    }

    /// Knob color. Defaults to light gray.
    @IBInspectable open var thumbOffColor: UIColor = UIColor.lightGray {
        didSet {
            setupThumb()
        }
    }

    /// Knob color when the switch is on. Defaults to white.
    @IBInspectable open var thumbOnColor: UIColor = UIColor.white {
        didSet {
            setupThumb()
        }
    }

    /// Thumb border color when the switch is on. Defaults to dark grey.
    @IBInspectable var thumbBorderOnColor: UIColor = UIColor.darkGray {
        didSet {
            setupThumb()
        }
    }

    /// Thumb border color when the switch is off. Defaults to dark grey.
    @IBInspectable var thumbBorderOffColor: UIColor = UIColor.darkGray {
        didSet {
            setupThumb()
        }
    }

    /// Shadow color of the knob. Defaults to gray.
    @IBInspectable open var thumbShadowColor: UIColor = UIColor.gray {
        willSet {
            setupThumb()
        }
    }

    /// Sets whether or not the switch edges are rounded.
    /// Set to NO to get a stylish square switch.
    /// Defaults to YES.
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

    /// Sets the image that shows on the switch thumb.
    @IBInspectable open var thumbImage: UIImage! {
        willSet {
            thumbImageView.image = newValue
        }
    }

    /// Sets the image that shows when the switch is on.
    /// The image is centered in the area not covered by the knob.
    /// Make sure to size your images appropriately.
    @IBInspectable open var onImage: UIImage! {
        willSet {
            onImageView.image = newValue
        }
    }

    /// Sets the image that shows when the switch is off.
    /// The image is centered in the area not covered by the knob.
    /// Make sure to size your images appropriately.
    @IBInspectable open var offImage: UIImage! {
        willSet {
            offImageView.image = newValue
        }
    }

    /// Width of the thumb border
    @IBInspectable open var thumbBorderWidth: CGFloat = 6 {
        didSet {
            let arc = thumbView.layer.sublayers?.filter({ $0 is CAShapeLayer}).first
            (arc as? CAShapeLayer)?.lineWidth = thumbBorderWidth
        }
    }

    /// Width of the switch background
    @IBInspectable open var backgroundBorderWidth: CGFloat = 5 {
        didSet {
            backgroundView.layer.borderWidth = backgroundBorderWidth
        }
    }

    /// Sets the text that shows when the switch is on.
    /// The text is centered in the area not covered by the knob.
    open var onLabel: UILabel!

    /// Sets the text that shows when the switch is off.
    /// The text is centered in the area not covered by the knob.
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

    /// Setup the individual elements of the switch and set default values
    private func setup() {
        setupBackground()
        setupImages()
        setupLabels()
        setupThumb()
        on = false
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(switchTapped(_:)))
        addGestureRecognizer(tapGesture)
    }

    /// Sets up the background component of the switch.
    private func setupBackground() {
        backgroundColor = UIColor.clear
        if backgroundView == nil {
            backgroundView = UIView(frame: initialFrame)
            self.addSubview(backgroundView)
        }
        backgroundView.backgroundColor = UIColor.clear
        backgroundView.layer.cornerRadius = isRounded ? initialFrame.height * 0.5 : 2.0
        backgroundView.layer.borderWidth = backgroundBorderWidth
        backgroundView.backgroundColor = isOn ? backgroundOnColor : backgroundOffColor
        backgroundView.layer.borderColor = isOn ? backgroundBorderOnColor.cgColor : backgroundBorderOffColor.cgColor
        backgroundView.isUserInteractionEnabled = false
        backgroundView.clipsToBounds = true
    }

    /// Sets up the on and off images of the switch.
    private func setupImages() {
        onImageView = UIImageView(frame: CGRect(x: 0, y: 0,
                                                width: initialFrame.width - initialFrame.height,
                                                height: initialFrame.height))
        onImageView.alpha = 1.0
        onImageView.contentMode = UIViewContentMode.center
        backgroundView.addSubview(onImageView)

        offImageView = UIImageView(frame: CGRect(x: initialFrame.height, y: 0,
                                                 width: initialFrame.width - initialFrame.height,
                                                 height: initialFrame.height))
        offImageView.alpha = 1.0
        offImageView.contentMode = UIViewContentMode.center
        backgroundView.addSubview(offImageView)
    }

    /// Sets up the on and off labels of the switch.
    private func setupLabels() {
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

    /// Sets up the thumb component of the switch.
    private func setupThumb() {
        if thumbView == nil {
            thumbView = UIView(frame: CGRect(x: 0.5, y: 0.5,
                                             width: initialFrame.height - 2, height: initialFrame.height - 2))
            addSubview(thumbView)
        }
        thumbView.backgroundColor = UIColor.blue
        thumbView.layer.cornerRadius = isRounded ? (initialFrame.height * 0.5) - 1 : 2
        thumbView.layer.shadowColor = thumbShadowColor.cgColor
        thumbView.layer.shadowRadius = 2.0
        thumbView.layer.shadowOpacity = 0.5
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 3)
        thumbView.layer.shadowPath = UIBezierPath(
            roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).cgPath
        thumbView.layer.masksToBounds = false
        thumbView.isUserInteractionEnabled = false

        if arc == nil {
            arc = CAShapeLayer()
            thumbView.layer.addSublayer(arc!)
            arc!.path = UIBezierPath(
                roundedRect: CGRect(x: 0, y: 0, width: initialFrame.height, height: initialFrame.height),
                cornerRadius: thumbView.layer.cornerRadius).cgPath
        }
        arc!.lineWidth = thumbBorderWidth
        arc!.strokeStart = 0
        arc!.strokeEnd = 1
        arc!.lineCap = "round"
        arc!.strokeColor = isOn ? thumbBorderOnColor.cgColor : thumbBorderOffColor.cgColor
        arc!.fillColor = isOn ? thumbOnColor.cgColor : thumbOffColor.cgColor
        arc!.shadowColor = thumbShadowColor.cgColor
        arc!.frame = CGRect(x: 0, y: 0, width: initialFrame.height, height: initialFrame.height)

        if thumbImageView == nil {
            thumbImageView = UIImageView(frame: CGRect(x: 0, y: 0,
                                                       width: thumbView.frame.size.width,
                                                       height: thumbView.frame.size.height))
            thumbView.addSubview(thumbImageView)
        }
        thumbImageView.contentMode = UIViewContentMode.center
        thumbImageView.autoresizingMask = UIViewAutoresizing.flexibleWidth
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
    }

    /// Set the state of the switch to on or off, optionally animating the transition.
    open func setOn(_ isOn: Bool, animated: Bool) {
        switchValue = isOn
        self.setValueLayout(value: on, animated)
    }

    /// Flag specifying wheter the switch is on or off
    var isOn: Bool {
        return on
    }

    func setValueLayout(value: Bool, _ animated: Bool) {
        let knobWidth: CGFloat = initialFrame.height

        let frameX = value ? self.initialFrame.width - knobWidth : 1
        let frameY = self.thumbView.frame.origin.y
        let frameWidth = knobWidth
        let frameHeight = self.thumbView.frame.size.height

        let funkyBlock = {
            self.thumbView.frame = CGRect(x: frameX, y: frameY, width: frameWidth, height: frameHeight)
        }

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut, .beginFromCurrentState],
                           animations: {
                                funkyBlock()
                            })
        } else {
            funkyBlock()
        }

        setupBackground()
        setupThumb()
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
