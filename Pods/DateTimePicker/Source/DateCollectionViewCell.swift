//
//  DateCollectionViewCell.swift
//  DateTimePicker
//
//  Created by Huong Do on 9/26/16.
//  Copyright © 2016 ichigo. All rights reserved.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    var dayLabel: UILabel! // rgb(128,138,147)
    var numberLabel: UILabel!
    var darkColor = UIColor(red: 0, green: 22.0/255.0, blue: 39.0/255.0, alpha: 1)
    var highlightColor = UIColor(red: 0/255.0, green: 199.0/255.0, blue: 194.0/255.0, alpha: 1)
    
    override init(frame: CGRect) {
        
        dayLabel = UILabel(frame: CGRect(x: 5, y: 15, width: frame.width - 10, height: 20))
        dayLabel.font = UIFont(name: "AvenirNext-Medium", size: 10)
        dayLabel.textAlignment = .center
    
        numberLabel = UILabel(frame: CGRect(x: 5, y: 30, width: frame.width - 10, height: 40))
        numberLabel.font = UIFont(name: "AvenirNext-Medium", size: 25)
        numberLabel.textAlignment = .center
        
        super.init(frame: frame)
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(numberLabel)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            dayLabel.textColor = isSelected == true ? UIColor(red: 50 / 255, green: 60.0/255.0, blue: 59.0/255.0, alpha: 1) : .white
            numberLabel.textColor = isSelected == true ? UIColor(red: 50 / 255, green: 60.0/255.0, blue: 59.0/255.0, alpha: 1) : .white
            contentView.backgroundColor = isSelected == true ? highlightColor : UIColor(red: 50 / 255, green: 60.0/255.0, blue: 59.0/255.0, alpha: 1)
            contentView.layer.borderWidth = isSelected == true ? 0 : 1
            
            if isSelected {
                if #available(iOS 10.0, *) {
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                }
            }
        }
    }
    
    func populateItem(date: Date, highlightColor: UIColor, darkColor: UIColor) {
        self.highlightColor = highlightColor
        self.darkColor = darkColor
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dayLabel.text = dateFormatter.string(from: date).uppercased()
        dayLabel.textColor = isSelected == true ? UIColor(red: 50 / 255, green: 60.0/255.0, blue: 59.0/255.0, alpha: 1) : .white
        
        let numberFormatter = DateFormatter()
        numberFormatter.dateFormat = "d"
        numberLabel.text = numberFormatter.string(from: date)
        numberLabel.textColor = isSelected == true ? UIColor(red: 50 / 255, green: 60.0/255.0, blue: 59.0/255.0, alpha: 1) : .white
        
        contentView.layer.borderColor = darkColor.withAlphaComponent(0.2).cgColor
        contentView.backgroundColor = isSelected == true ? highlightColor : UIColor(red: 50 / 255, green: 60.0/255.0, blue: 59.0/255.0, alpha: 1)
    }
    
}
