//
//  FullDateCollectionViewCell.swift
//  DateTimePicker
//
//  Created by Jess Chandler on 10/14/17.
//  Copyright © 2017 ichigo. All rights reserved.
//
//  Modified by Cali Castle

import UIKit

class FullDateCollectionViewCell: UICollectionViewCell {
    var monthLabel: UILabel!
    var dayLabel: UILabel!
    var numberLabel: UILabel!
    
    var highlightColor = UIColor.white
    
    var backgroundCardColor: UIColor {
        return AppearanceManager.default.isDarkTheme() ? .flatBlack() : .flatWhite()
    }

    override init(frame: CGRect) {

        dayLabel = UILabel(frame: CGRect(x: 5, y: 7, width: frame.width - 10, height: 20))
        dayLabel.font = AppearanceManager.font(size: 10, weight: .Medium)
        dayLabel.textAlignment = .center

        numberLabel = UILabel(frame: CGRect(x: 5, y: 20, width: frame.width - 10, height: 40))
        numberLabel.font = UIFont.boldSystemFont(ofSize: 30)
        numberLabel.textAlignment = .center

        monthLabel = UILabel(frame: CGRect(x: 5, y: 53, width: frame.width - 10, height: 20))
        monthLabel.font = AppearanceManager.font(size: 10, weight: .DemiBold)
        monthLabel.textAlignment = .center
        
        super.init(frame: frame)

        contentView.addSubview(monthLabel)
        contentView.addSubview(dayLabel)
        contentView.addSubview(numberLabel)
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            setColors()
            
            if isSelected {
                Haptic.selection.generate()
            }
        }
    }
    
    fileprivate func setColors() {
        let contrastOfBackgroundCard = UIColor(contrastingBlackOrWhiteColorOn: backgroundCardColor, isFlat: false)!
        let contrastOfHighlight = UIColor(contrastingBlackOrWhiteColorOn: highlightColor, isFlat: false)!
        
        monthLabel.textColor = isSelected ? contrastOfHighlight : contrastOfBackgroundCard.withAlphaComponent(0.35)
        dayLabel.textColor = isSelected ? contrastOfHighlight : contrastOfBackgroundCard.withAlphaComponent(0.35)
        numberLabel.textColor = isSelected ? contrastOfHighlight : contrastOfBackgroundCard.withAlphaComponent(0.75)
        contentView.backgroundColor = isSelected ? highlightColor : backgroundCardColor.lighten(byPercentage: 0.03)
    }

    func populateItem(date: Date) {
        let mdateFormatter = DateFormatter.localized()
        mdateFormatter.dateFormat = "MMMM"
        monthLabel.text = mdateFormatter.string(from: date)

        let dateFormatter = DateFormatter.localized()
        dateFormatter.dateFormat = "EEEE"
        dayLabel.text = dateFormatter.string(from: date).uppercased()

        let numberFormatter = DateFormatter.localized()
        numberFormatter.dateFormat = "d"
        numberLabel.text = numberFormatter.string(from: date)

        setColors()
    }

}
