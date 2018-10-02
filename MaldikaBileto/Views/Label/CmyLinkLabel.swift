//
//  UIlabel+hyperlink.swift
//  MaldikaBileto
//
//  Created by x.yang on 2018/07/04.
//  Copyright © 2018年 x.yang. All rights reserved.
//

import UIKit

import Foundation

@objc protocol CmyTappableLabelDelegate {
    @objc optional func tappableLabel(tabbableLabel: CmyLinkableLabel, didTapUrl: URL, atRange: NSRange)
}

/// Represent a label with attributed text inside.
/// We can add a correspondence between a range of the attributed string an a link (URL)
/// By default, link will be open on the external browser @see 'openLinkOnExternalBrowser'

class CmyLinkableLabel: UILabel {
    
    // MARK: - Public properties -
    
    var links: [String: NSRange] = [:]
    var openLinkOnExternalBrowser = false
    var delegate: CmyTappableLabelDelegate?
    
    // MARK: - Constructors -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.enableInteraction()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.enableInteraction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func enableInteraction() {
        self.isUserInteractionEnabled = self.isEnabled
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnLabel(tapGesture:))))
    }
    
    // MARK: - Public methods -
    
    /**
     Add correspondence between a range and a link.
     
     - parameter url:   url.
     - parameter range: range on which couple url.
     */
    func addLink(url: String, atRange range: NSRange) {
        self.links[url] = range
    }
    
    // MARK: - Public properties -
    
    /**
     Action rised on user interaction on label.
     
     - parameter tapGesture: gesture.
     */
    @objc func didTapOnLabel(tapGesture: UITapGestureRecognizer) {
        let labelSize = self.bounds.size;
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        
        // configure textContainer for the label
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.size = labelSize;
        
        // configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = tapGesture.location(in: self)
        
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.2 - textBoundingBox.origin.x
            , y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                            in:textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)
        
        for (url, range) in self.links {
            if  range.location != NSNotFound {
                if NSLocationInRange(indexOfCharacter, range) {
                    let url = NSURL(string: url)
                    if self.openLinkOnExternalBrowser {
                        UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                    } else {
                        self.delegate?.tappableLabel?(tabbableLabel: self, didTapUrl: url! as URL, atRange: range)
                    }
                }
            }
        }
    }
    
}
