//
//  DateTimePicker.swift
//  DateTimePicker
//
//  Created by Huong Do on 9/16/16.
//  Copyright © 2016 ichigo. All rights reserved.
//
//  Modified by Cali Castle.

import UIKit

@objc public class DateTimePicker: UIView {
    
    var contentHeight: CGFloat = 310
    
    // public vars
    public var backgroundViewColor: UIColor? = .clear {
        didSet {
            shadowView.backgroundColor = backgroundViewColor
        }
    }
    
    public var highlightColor = UIColor(red: 0/255.0, green: 199.0/255.0, blue: 194.0/255.0, alpha: 1) {
        didSet {
            todayButton.setTitleColor(highlightColor, for: .normal)
        }
    }
    
    public var hightlightTextColor = UIColor.white
    
    public var darkColor = UIColor(red: 0, green: 22.0/255.0, blue: 39.0/255.0, alpha: 1) {
        didSet {
            dateTitleLabel.textColor = darkColor
            cancelButton.setTitleColor(darkColor.withAlphaComponent(0.5), for: .normal)
            doneButton.backgroundColor = darkColor.withAlphaComponent(0.5)
        }
    }
    
    public var daysBackgroundColor = UIColor(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, alpha: 1)
    
    var didLayoutAtOnce = false
    public override func layoutSubviews() {
        super.layoutSubviews()
        // For the first time view will be layouted manually before show
        // For next times we need relayout it because of screen rotation etc.
        if !didLayoutAtOnce {
            didLayoutAtOnce = true
        } else {
            self.configureView()
        }
    }
    
    public var selectedDate = Date() {
        didSet {
            resetDateTitle()
        }
    }
    
    public var dateFormat = "HH:mm dd/MM/YYYY" {
        didSet {
            resetDateTitle()
        }
    }
    
    public var cancelButtonTitle = "Cancel" {
        didSet {
            cancelButton.setTitle(cancelButtonTitle, for: .normal)
            let size = cancelButton.sizeThatFits(CGSize(width: 0, height: 44.0)).width + 20.0
            cancelButton.frame = CGRect(x: 20, y: 0, width: size, height: 44)
        }
    }
    
    public var todayButtonTitle = "Today" {
        didSet {
            todayButton.setTitle(todayButtonTitle, for: .normal)
            let size = todayButton.sizeThatFits(CGSize(width: 0, height: 44.0)).width
            todayButton.frame = CGRect(x: contentView.frame.width - size - 20, y: 0, width: size, height: 44)
        }
    }
    public var doneButtonTitle = "DONE" {
        didSet {
            doneButton.setTitle(doneButtonTitle, for: .normal)
        }
    }
    
    public var is12HourFormat = false {
        didSet {
            configureView()
        }
    }
    
    public var isDatePickerOnly = false {
        didSet {
            if isDatePickerOnly {
                isTimePickerOnly = false
            }
            configureView()
        }
    }
    
    public var isTimePickerOnly = false {
        didSet {
            if isTimePickerOnly {
                isDatePickerOnly = false
            }
            configureView()
        }
    }

    public var includeMonth = false {
        didSet {
            configureView()
        }
    }
    
    public var timeZone = TimeZone.current
    public var completionHandler: ((Date)->Void)?
    public var dismissHandler: (() -> Void)?
    
    // private vars
    internal lazy var dayCollectionView: UICollectionView = {
        let layout = StepCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: 75, height: 80)
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 44, width: contentView.frame.width, height: 100), collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = isTimePickerOnly
        
        let inset = (collectionView.frame.width - 75) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
        return collectionView
    }()
    
    internal lazy var timePicker: UIDatePicker = {
        let timePicker = UIDatePicker.localized()
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = 5
        timePicker.timeZone = timeZone
        timePicker.textColor = isDarkTheme ? .white : .flatBlack()
        timePicker.setSeparator(color: isDarkTheme ? UIColor.white.withAlphaComponent(0.2) : UIColor.lightGray.withAlphaComponent(0.5), width: 0.2)
        
        timePicker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        
        return timePicker
    }()
    
    private var backgroundView: UIView!
    
    private lazy var shadowView: UIView = {
        let shadowView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        shadowView.alpha = 1
        
        return shadowView
    }()
    
    private var contentView: UIView!
    
    private var titleView: UIView!
    
    private var dateTitleLabel: UILabel!
    
    private lazy var todayButton: UIButton = {
        let todayButton = UIButton(type: .system)
        todayButton.translatesAutoresizingMaskIntoConstraints = false
        todayButton.setTitle(todayButtonTitle, for: .normal)
        todayButton.setTitleColor(isDarkTheme ? .flatYellow() : .flatBlue(), for: .normal)
        todayButton.addTarget(self, action: #selector(setToday), for: .touchUpInside)
        todayButton.contentHorizontalAlignment = .right
        todayButton.titleLabel?.font = AppearanceManager.font(size: 15, weight: .DemiBold)
        todayButton.isHidden = self.minimumDate.compare(Date()) == .orderedDescending || self.maximumDate.compare(Date()) == .orderedAscending
        
        return todayButton
    }()
    
    private lazy var doneButton: UIButton = {
        let doneButton = UIButton(type: .system)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done".localized, for: .normal)
        doneButton.setTitleColor(isDarkTheme ? .flatBlack() : .flatWhite(), for: .normal)
        doneButton.backgroundColor = isDarkTheme ? .flatWhite() : .flatBlack()
        doneButton.titleLabel?.font = AppearanceManager.font(size: 14, weight: .DemiBold)
        doneButton.layer.cornerRadius = 14
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(dismissView(sender:)), for: .touchUpInside)
        
        return doneButton
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        cancelButton.setTitleColor(isDarkTheme ? UIColor.white.withAlphaComponent(0.5) : UIColor.black.withAlphaComponent(0.5), for: .normal)
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.addTarget(self, action: #selector(dismissView(sender:)), for: .touchUpInside)
        cancelButton.titleLabel?.font = AppearanceManager.font(size: 15, weight: .Medium)
        
        return cancelButton
    }()
    
    internal var minimumDate: Date!
    internal var maximumDate: Date!
    
    internal var calendar: Calendar = .current
    internal var dates: [Date]! = []
    internal var components: DateComponents! {
        didSet {
            components.timeZone = timeZone
        }
    }
    
    @objc open class func show(selected: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil) -> DateTimePicker {
        let dateTimePicker = DateTimePicker()
        dateTimePicker.minimumDate = minimumDate ?? Date(timeIntervalSinceNow: -3600 * 24 * 365 * 20)
        dateTimePicker.maximumDate = maximumDate ?? Date(timeIntervalSinceNow: 3600 * 24 * 365 * 20)
        dateTimePicker.selectedDate = selected ?? dateTimePicker.minimumDate

        dateTimePicker.configureView()
        UIApplication.shared.keyWindow?.addSubview(dateTimePicker)
        
        return dateTimePicker
    }
    
    fileprivate lazy var isDarkTheme: Bool = {
        return AppearanceManager.default.isDarkTheme()
    }()
    
    fileprivate func configureShadowView() {
        addSubview(shadowView)
    }
    
    fileprivate func configureContentView() {
        contentView = UIView(frame: CGRect(x: 0, y: frame.height, width: frame.width, height: contentHeight))
        contentView.layer.shadowColor = UIColor(white: 0, alpha: 0.5).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: -5.0)
        contentView.layer.shadowRadius = 25
        contentView.layer.shadowOpacity = 1
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        contentView.backgroundColor = isDarkTheme ? .flatBlack() : .flatWhite()
        contentView.isHidden = true
        
        addSubview(contentView)
    }
    
    fileprivate func configureTitleView() {
        titleView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: contentView.frame.width, height: 50)))
        titleView.backgroundColor = .clear
        
        contentView.addSubview(titleView)
        
        // Cancel button.
        configureCancelButton()
        // Today button.
        configureTodayButton()
        // Date title.
        configureDateTitleLabel()
    }
    
    fileprivate func configureCancelButton() {
        titleView.addSubview(cancelButton)
        
        cancelButton.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 16).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        cancelButton.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    fileprivate func configureDateTitleLabel() {
        dateTitleLabel = UILabel()
        dateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTitleLabel.font = AppearanceManager.font(size: 15, weight: .Medium)
        dateTitleLabel.textColor = isDarkTheme ? .white : .flatBlack()
        dateTitleLabel.textAlignment = .center
        
        resetDateTitle()
        
        titleView.addSubview(dateTitleLabel)
        
        dateTitleLabel.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 4).isActive = true
        dateTitleLabel.trailingAnchor.constraint(equalTo: todayButton.leadingAnchor, constant: 4).isActive = true
        dateTitleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
    }
    
    fileprivate func configureTodayButton() {
        titleView.addSubview(todayButton)
        
        todayButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16).isActive = true
        todayButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        todayButton.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    fileprivate func configureCollectionView() {
        dayCollectionView.register(includeMonth ? FullDateCollectionViewCell.self : DateCollectionViewCell.self, forCellWithReuseIdentifier: "dateCell")
        
        contentView.addSubview(dayCollectionView)
        
        dayCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: titleView.bounds.size.height + 4).isActive = true
        dayCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        dayCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        dayCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        dayCollectionView.setContentHuggingPriority(.required, for: .vertical)
    }
    
    fileprivate func configureDoneButton() {
        contentView.addSubview(doneButton)
        
        // Auto-layout
        doneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        // Safe area
        if #available(iOS 11.0, *) {
            doneButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8).isActive = true
        }
    }
    
    fileprivate func configureTimePicker() {
        contentView.addSubview(timePicker)
        
        timePicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        timePicker.topAnchor.constraint(equalTo: dayCollectionView.bottomAnchor).isActive = true
        timePicker.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -4).isActive = true
    }
    
    private func configureView() {
        if let contentView = contentView, let _ = contentView.superview {
            contentView.removeFromSuperview()
        }
        
        let screenSize = UIScreen.main.bounds.size
        frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        
        // Background view
        backgroundView = UIView(frame: UIScreen.main.bounds)
        backgroundView.backgroundColor = UIColor(white: 0.15, alpha: 0.7)
        backgroundView.alpha = 0
        addSubview(backgroundView)
        
        // Shadow view
        configureShadowView()
        
        // Content view
        contentHeight = isDatePickerOnly ? 228 : isTimePickerOnly ? 230 : 330
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            if #available(iOS 11.0, *) {
                contentHeight += rootViewController.view.safeAreaInsets.bottom
            }
        }
        contentHeight += 50
        
        configureContentView()
        
        // Title view
        configureTitleView()
        
        // Day collection view
        configureCollectionView()
        
        // Done button
        configureDoneButton()
        
        // Time picker
        configureTimePicker()
        
        // Fill date
        fillDates(fromDate: minimumDate, toDate: maximumDate)
        
        let formatter = DateFormatter.localized()
        formatter.dateFormat = "dd/MM/YYYY"
        
        for i in 0..<dates.count {
            let date = dates[i]
            if formatter.string(from: date) == formatter.string(from: selectedDate) {
                let indexPath = IndexPath(row: i, section: 0)
                dayCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                calibrateCellOffset(indexPath, animated: false)
                
                break
            }
        }
        components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: selectedDate)
        contentView.isHidden = false
        
        resetTime()
        
        // animate to show contentView
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 4.5, options: .curveEaseIn, animations: {
            self.contentView.frame = CGRect(x: 0,
                                            y: self.frame.height - self.contentHeight,
                                            width: self.frame.width,
                                            height: self.contentHeight)
            self.backgroundView.alpha = 1
        }) {
            if $0 {
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
        }
    }
    
    @objc func setToday() {
        selectedDate = Date()
        resetTime()
    }
    
    func resetTime() {
        components = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: selectedDate)
        updateCollectionView(to: selectedDate)
        updateTimePicker(to: selectedDate)
    }
    
    private func resetDateTitle() {
        guard let dateTitleLabel = dateTitleLabel else { return }
        
        let formatter = DateFormatter.localized()
        formatter.dateFormat = dateFormat
        dateTitleLabel.text = formatter.string(from: selectedDate)
    }
    
    func fillDates(fromDate: Date, toDate: Date) {
        var dates: [Date] = []
        var days = DateComponents()
        
        var dayCount = 0
        repeat {
            days.day = dayCount
            dayCount += 1
            
            guard let date = calendar.date(byAdding: days, to: fromDate) else { break }
            
            if date.compare(toDate) == .orderedDescending { break }
            
            dates.append(date)
        } while (true)
        
        self.dates = dates
        
        dayCollectionView.reloadData()
        
        if let index = self.dates.index(of: selectedDate) {
            dayCollectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    fileprivate func updateCollectionView(to currentDate: Date) {
        let formatter = DateFormatter.localized()
        formatter.dateFormat = "dd/MM/YYYY"
        for i in 0..<dates.count {
            let date = dates[i]
            if formatter.string(from: date) == formatter.string(from: currentDate) {
                let indexPath = IndexPath(row: i, section: 0)
                dayCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { 
                    self.dayCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                    self.calibrateCellOffset(indexPath, animated: true)
                })
                
                break
            }
        }
    }
    
    fileprivate func updateTimePicker(to selectedDate: Date) {
        timePicker.setDate(selectedDate, animated: true)
    }
    
    @objc public func dismissView(sender: UIButton?=nil) {
        UIView.animate(withDuration: 0.3, animations: {
            // animate to show contentView
            self.contentView.frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: self.contentHeight)
            self.backgroundView.alpha = 0
        }) {[weak self] (completed) in
            guard let `self` = self else {
                return
            }
            if sender == self.doneButton {
                self.completionHandler?(self.selectedDate)
            } else {
                self.dismissHandler?()
            }
            
            self.removeFromSuperview()
        }
    }
    
    fileprivate func updateSelectedDate(to indexPath: IndexPath) {
        let date = dates[indexPath.item]
        let dayComponent = calendar.dateComponents([.day, .month, .year], from: date)
        components.day = dayComponent.day
        components.month = dayComponent.month
        components.year = dayComponent.year
        
        if let selected = calendar.date(from: components) {
            if selected < minimumDate {
                selectedDate = minimumDate
                resetTime()
            } else {
                selectedDate = selected
            }
        }
    }
    
}

extension DateTimePicker: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if includeMonth {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! FullDateCollectionViewCell
            let date = dates[indexPath.item]
            cell.highlightColor = highlightColor
            cell.populateItem(date: date)

            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCollectionViewCell
            let date = dates[indexPath.item]
            cell.populateItem(date: date, highlightColor: highlightColor, darkColor: darkColor)

            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        calibrateCellOffset(indexPath)
        updateSelectedDate(to: indexPath)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView.isEqual(dayCollectionView) else { return }
        
        let centerPoint = CGPoint(x: dayCollectionView.center.x + dayCollectionView.contentOffset.x, y: 50)
        if let indexPath = dayCollectionView.indexPathForItem(at: centerPoint) {
            // Automatically select this item and center it to the screen
            // Set animated = false to avoid unwanted effects
            dayCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            
            calibrateCellOffset(indexPath, animated: false)
            updateSelectedDate(to: indexPath)
        }
    }
    
    fileprivate func calibrateCellOffset(_ indexPath: IndexPath, animated: Bool = true) {
        if let cell = dayCollectionView.cellForItem(at: indexPath) {
            let offset = CGPoint(x: cell.center.x - dayCollectionView.frame.width / 2, y: 0)
            dayCollectionView.setContentOffset(offset, animated: animated)
        }
    }
    
}

extension DateTimePicker {
    
    @objc fileprivate func datePickerChanged(_ datePicker: UIDatePicker) {
        let date = datePicker.date
        let dayComponent = calendar.dateComponents([.hour, .minute], from: date)
        components.hour = dayComponent.hour
        components.minute = dayComponent.minute
        
        if let selected = calendar.date(from: components) {
            if selected < minimumDate {
                selectedDate = minimumDate
                resetTime()
            } else {
                selectedDate = selected
            }
        }
    }
    
}
