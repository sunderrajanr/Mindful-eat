//
//  CollapsibleImageView.swift
//  EAT
//
//  Created by Emlyn Murphy on 1/3/15.
//  Copyright (c) 2015 Nitemotif. All rights reserved.
//

import UIKit

class CollapsibleImageView: UIImageView {
    private var originalWidthConstant: CGFloat = 0
    private var originalMarginConstant: CGFloat = 0
    
    @IBOutlet var widthConstraint: NSLayoutConstraint?
		{
        didSet {
            if let constraint = widthConstraint {
                originalWidthConstant = constraint.constant
            }
            else {
                originalWidthConstant = 0
            }
        }
    }
    
    @IBOutlet var marginConstraint: NSLayoutConstraint? {
        didSet {
            if let constraint = marginConstraint {
                originalMarginConstant = constraint.constant
            }
            else {
                originalWidthConstant = 0
            }
        }
    }
    
    var collapsed: Bool = false {
        didSet {
            if collapsed {
                widthConstraint?.constant = 0
                marginConstraint?.constant = 0
            }
            else {
                widthConstraint?.constant = originalWidthConstant
                marginConstraint?.constant = originalMarginConstant
            }
        }
    }
}
