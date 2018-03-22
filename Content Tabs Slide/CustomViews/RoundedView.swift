//
//  RoundedView.swift
//  Content Tabs Slide
//
//  Created by Bryan Rodriguez on 3/21/18.
//  Copyright © 2018 Applaudo Studios. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func setupView() {
        self.layer.cornerRadius = 8.0
    }
}
