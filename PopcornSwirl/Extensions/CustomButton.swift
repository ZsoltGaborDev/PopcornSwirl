//
//  CustomButtom.swift
//  PopcornSwirl
//
//  Created by zsolt on 29/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blur.frame = self.imageView!.bounds
         blur.isUserInteractionEnabled = false
         self.insertSubview(blur, at: 0)
    }
}
