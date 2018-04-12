//
//  RepeatTodoTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/13/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import DeckTransition

protocol RepeatTodoTableViewControllerDelegate {
    
    func selectedRepeat(with info: ToDo.Repeat?)
    
}

class RepeatTodoTableViewController: UITableViewController, LocalizableInterface {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var repeatTypePickerView: UIPickerView!
    @IBOutlet var repeatNextDateLabel: UILabel!
    @IBOutlet var endDatePicker: UIDatePicker!
    @IBOutlet var endDateSwitch: UISwitch!
    
    // MARK: - Localizable Outlets.
    
    // MARK: - Properties.
    
    var delegate: RepeatTodoTableViewControllerDelegate?
    
    var repeatInfo: ToDo.Repeat? {
        didSet {
            guard let info = repeatInfo else { return }
            
            if let oldValue = oldValue {
                if oldValue.type == info.type { return }
            }
            
            guard info.type == .Regularly || info.type == .AfterCompletion else { return }
            
            if tableView.numberOfSections == 1 {
                tableView.insertSections([1, 2], with: .middle)
            }
        }
    }
    
    /// Date formatter.
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter.localized()
        dateFormatter.dateFormat = "yyyy MMM dd, EEE".localized
        
        return dateFormatter
    }()
    
    /// Due date for todo.
    var dueDate: Date?
    
    /// Repeat frequencies.
    let repeatFrequencies = 800
    
    /// Selected frequency.
    var selectedFrequency: Int? {
        didSet {
            if var info = repeatInfo {
                if let frequency = selectedFrequency {
                    info.frequency = frequency
                } else {
                    info.frequency = 0
                }
                
                repeatInfo = info
            }
        }
    }
    
    /// Selected unit.
    var selectedUnit: ToDo.RepeatUnit? {
        didSet {
            if var info = repeatInfo {
                if let unit = selectedUnit {
                    info.unit = unit
                } else {
                    info.unit = .Day
                }
                
                repeatInfo = info
                
            }
        }
    }
    
    /// Has end date.
    var hasEndDate: Bool = false {
        didSet {
            guard hasEndDate != oldValue else { return }
            
            if var info = repeatInfo, info.type == .Regularly || info.type == .AfterCompletion {
                let indexPaths = [IndexPath(row: 1, section: 2)]
                
                if hasEndDate {
                    tableView.insertRows(at: indexPaths, with: .middle)
                    tableView.scrollToRow(at: indexPaths.first!, at: .top, animated: true)
                } else {
                    tableView.deleteRows(at: indexPaths, with: .middle)
                    
                    info.endDate = nil
                    repeatInfo = info
                }
                endDatePicker.isEnabled = hasEndDate
            }
        }
    }
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = false
        localizeInterface()
        setupViews()
        configureColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let _ = updateNextDateLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let delegate = delegate {
            if var info = repeatInfo {
                if hasEndDate, let _ = info.endDate {
                    info.endDate = endDatePicker.date
                }
                
                delegate.selectedRepeat(with: info)
            }
        }
    }
    
    /// Localize interface.
    func localizeInterface() {
        title = "todo-table.repeat".localized
        
        cellLabels.forEach {
            $0.text = "repeat-todo.types.\($0.tag)".localized
        }
        
        endDatePicker.locale = Locale(identifier: LocaleManager.default.currentLanguage.string())
        endDatePicker.calendar = Calendar.current
    }
    
    /// Setup views.
    fileprivate func setupViews() {
        repeatTypePickerView.textColor = .white
        repeatTypePickerView.setSeparator(color: UIColor.white.withAlphaComponent(0.1))
        endDatePicker.textColor = .white
        endDatePicker.setSeparator(color: UIColor.white.withAlphaComponent(0.1))
        
        if let info = repeatInfo {
            if let index = ToDo.repeatTypes.index(of: info.type) {
                tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
            }
            
            if let endDate = info.endDate {
                hasEndDate = true
                endDatePicker.date = endDate
            }
            
            endDateSwitch.setOn(hasEndDate, animated: false)
            
            repeatTypePickerView.selectRow(info.frequency > 0 ? info.frequency - 1 : 0, inComponent: 0, animated: false)
            repeatTypePickerView.selectRow(ToDo.repeatUnits.index(of: info.unit)!, inComponent: 1, animated: false)
        }
        endDatePicker.minimumDate = Date()
    }
    
    /// Configure colors.
    fileprivate func configureColors() {
        let color: UIColor = currentThemeIsDark() ? .white : .flatBlack()
        
        cellLabels.forEach {
            $0.textColor = color
        }
        
        repeatTypePickerView.setValue(color, forKey: "textColor")
        endDatePicker.setValue(color, forKey: "textColor")
        repeatNextDateLabel.textColor = color.withAlphaComponent(0.6)
    }
    
    /// Update next date label.
    fileprivate func updateNextDateLabel() -> Date? {
        if let info = repeatInfo {
            guard let nextDate = info.getNextDate(dueDate ?? Date()) else { return nil }
                
            repeatNextDateLabel.text = "\("repeat-todo.custom.footer".localized)\n\(dateFormatter.string(from: nextDate))"
            
            return nextDate
        }
        
        return nil
    }
    
    /// Update next recurring date.
    fileprivate func updateNextDate() {
        endDatePicker.date = updateNextDateLabel() ?? Date()
    }
    
    /// Light status bar.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Auto hide home indicator
    @available(iOS 11, *)
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    /// End date switch did change.
    @IBAction func endDateSwitchDidChange(_ sender: UISwitch) {
        hasEndDate = sender.isOn
        updateNextDate()
    }
    
    /// End date picker did change.
    @IBAction func endDatePickerDidChange(_ sender: UIDatePicker) {
        guard var info = repeatInfo else { return }
        
        info.endDate = sender.date
        
        repeatInfo = info
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let info = repeatInfo else { return 0 }
        
        switch info.type {
        case .Regularly, .AfterCompletion:
            return 3
        default:
            return 1
        }
    }

    /// Number of rows.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 1
        case 2:
            return hasEndDate ? 2 : 1
        default:
            return ToDo.repeatTypes.count
        }
    }
    
    /// About to display cell.
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = cell.isSelected ? .checkmark : .none
    }
    
    /// Select row.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard var info = repeatInfo else { return }
        
        switch indexPath.section {
        case 0:
            // Generate haptic feedback
            Haptic.selection.generate()
            
            switch indexPath.row {
            case 1:
                info.type = .Daily
            case 2:
                info.type = .Weekday
            case 3:
                info.type = .Weekly
            case 4:
                info.type = .Monthly
            case 5:
                info.type = .Annually
            case 6:
                info.type = .Regularly
            case 7:
                info.type = .AfterCompletion
            default:
                info.type = .None
            }
            
            if info.type == .Regularly || info.type == .AfterCompletion {
                repeatInfo = info
                tableView.reloadSections([0], with: .none)
            } else {
                info.endDate = nil
                info.frequency = 1
                info.unit = .Day
                
                repeatInfo = info
            }
        default:
            return
        }
        
        if info.type != .Regularly && info.type != .AfterCompletion {
            let _ = navigationController?.popViewController(animated: true)
        } else {
            pickerView(repeatTypePickerView, didSelectRow: 0, inComponent: 0)
        }
    }
    
    /// Select highlight cell.
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let darkTheme = currentThemeIsDark()
            
            cell.backgroundColor = darkTheme ? UIColor.flatBlack().lighten(byPercentage: 0.08) : UIColor.flatWhite().darken(byPercentage: 0.08)
        }
    }
    
    /// Select unhightlight cell.
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let darkTheme = currentThemeIsDark()
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                cell.backgroundColor = darkTheme ? .flatBlack() : .flatWhite()
            })
        }
    }

    /// Header titles.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "repeat-todo.types.header".localized
        case 1:
            return "repeat-todo.frequency.header".localized
        default:
            return nil
        }
    }

}

// MARK: - Picker Delegate and Data Source Mthods.

extension RepeatTodoTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    /// Number of components.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    /// Number of rows.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return repeatFrequencies
        default:
            return ToDo.repeatUnits.count
        }
    }
    
    /// Selected row.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedFrequency = row + 1
        default:
            selectedUnit = ToDo.repeatUnits[row]
        }
        
        let _ = updateNextDateLabel()
    }
    
    /// Attributed string for each component.
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var text = ""
        
        switch component {
        case 0:
            text = String(format: "repeat-todo.every-frequency".localized, row + 1)
        default:
            text = ToDo.repeatUnits[row].rawValue.localized
        }
        
        return NSAttributedString(string: text, attributes: [.foregroundColor: currentThemeIsDark() ? UIColor.white : .flatBlack(), .font: AppearanceManager.font(size: 17, weight: .DemiBold)])
    }
    
}
