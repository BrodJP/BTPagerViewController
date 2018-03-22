//
//  RoundedViewWithShadow.swift
//  Content Tabs Slide
//
//  Created by Bryan Rodriguez on 3/21/18.
//  Copyright © 2018 Applaudo Studios. All rights reserved.
//

import UIKit

class RoundedViewWithShadow: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = 8.0
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 2.0
        self.layer.shadowColor = UIColor.lightBlue.cgColor
    }
}
