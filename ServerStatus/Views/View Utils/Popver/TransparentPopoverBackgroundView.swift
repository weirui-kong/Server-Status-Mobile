//
//  File.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023-03-16.
//

import Foundation
import UIKit
class TransparentPopoverBackgroundView: UIPopoverBackgroundView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0 // 设置透明度为 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class func contentViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    override class func arrowBase() -> CGFloat {
        return 0
    }

    override class func arrowHeight() -> CGFloat {
        return 0
    }
}
