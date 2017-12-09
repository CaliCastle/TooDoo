//
//  +UIImageView.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

extension UIImageView {
    
    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    
}
