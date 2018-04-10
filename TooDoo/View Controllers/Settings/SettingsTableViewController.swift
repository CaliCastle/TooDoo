//
//  SettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/21/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
import SideMenu
import LocalAuthentication

final class SettingsTableViewController: SettingTableViewController {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconImageViews: [UIImageView]!
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var switches: [UISwitch]!
    
    @IBOutlet var appIconImageView: UIImageView!
    
    @IBOutlet var appVersionLabel: UILabel!
    @IBOutlet var designedByLabel: UILabel!
    
    /// Switch types.
    private enum Switch: Int {
        case Sounds = 0
        case Haptics = 1
        case MotionEffects = 2
    }
    
    // MARK: - View Life Cycle.
    
    override func usesLargeTitle() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureAppIconImage()
    }
    
    /// Localize interface.
    override func localizeInterface() {
        super.localizeInterface()
        
        setVersionText()
        setDesignedByText()
        configureIconImages()
    }
    
    /// Configure app icon to be cornered.
    fileprivate func configureAppIconImage() {
        appIconImageView.cornerRadius = 6
        appIconImageView.layer.masksToBounds = true
        
        if #available(iOS 10.3, *) {
            let iconName = ApplicationManager.currentAlternateIcon()
            appIconImageView.image = UIImage(named: iconName.imageName())
        }
    }
    
    /// Configure icon image views.
    fileprivate func configureIconImages() {
        iconImageViews.forEach {
            // Bulk set image tint colors
            $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = currentThemeIsDark() ? .white : .flatBlack()
        }
    }
    
    /// Configure switches.
    fileprivate func configureSwitches() {
        switches.forEach {
            switch $0.tag {
            case Switch.Sounds.rawValue:
                // Sounds switch
                $0.setOn(UserDefaultManager.settingSoundsEnabled(), animated: false)
            case Switch.Haptics.rawValue:
                $0.setOn(UserDefaultManager.settingHapticsEnabled(), animated: false)
            case Switch.MotionEffects.rawValue:
                // Motion switch
                $0.setOn(UserDefaultManager.settingMotionEffectsEnabled(), animated: false)
            default:
                break
            }
        }
    }
    
    /// Set up table view.
    internal override func setupTableView() {
        super.setupTableView()
        
        configureIconImages()
        configureSwitches()
    }
    
    /// Set cell labels
    override func getCellLabels() -> [UILabel]? {
        return cellLabels
    }
    
    /// Set app version text.
    fileprivate func setVersionText() {
        appVersionLabel.text = Bundle.main.localizedVersionLabelString
    }
    
    /// Set up designed and developed label.
    fileprivate func setDesignedByText() {
        let text = "designed by".localized
        let separatedText = text.components(separatedBy: "|")
        
        let attributedText = NSMutableAttributedString(string: separatedText.first!, attributes: [.font: AppearanceManager.font(size: 11, weight: .DemiBold), .foregroundColor: appVersionLabel.textColor])
        attributedText.append(.init(string: separatedText.last!, attributes: [.font: AppearanceManager.font(size: 11, weight: .Bold), .foregroundColor: currentThemeIsDark() ? UIColor.white : UIColor.flatBlack()]))
        
        designedByLabel.attributedText = attributedText
    }
    
    /// Sounds switch value changed.
    @IBAction func soundsSwitchChanged(_ sender: UISwitch) {
        UserDefaultManager.set(value: sender.isOn, forKey: .Sounds)
    }
    
    /// Haptics switch changed.
    @IBAction func hapticsSwitchChanged(_ sender: UISwitch) {
        UserDefaultManager.set(value: sender.isOn, forKey: .Haptics)
    }
    
    /// Motion effects switch changed.
    @IBAction func motionEffectSwitchChanged(_ sender: UISwitch) {
        UserDefaultManager.set(value: sender.isOn, forKey: .MotionEffects)
        NotificationManager.send(notification: .SettingMotionEffectsChanged)
    }
    
    /// When cell is about to be displayed.
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.prepareDisclosureIndicator()
    }
    
    /// Table header titles.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "settings.headers.general".localized
        case 1:
            return "settings.headers.look-and-feel".localized
        case 2:
            return "settings.headers.privacy".localized
        default:
            return nil
        }
    }
    
    /// Prepare for segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        DispatchQueue.main.async {
            // Generate haptic feedback
            Haptic.selection.generate()
        }
    }

}
