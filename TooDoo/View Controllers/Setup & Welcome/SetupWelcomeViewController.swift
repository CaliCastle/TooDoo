//
//  SetupWelcomeViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/15/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Photos
import Haptica
import CoreData
import BulletinBoard
import ChameleonFramework

class SetupWelcomeViewController: UIViewController {

    /// Storyboard identifier
    
    static let identifier = "Welcome"
    
    /// Welcome outlets
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var greetingMessageLabel: UILabel!
    // Gradient backgrounds
    @IBOutlet var gradientBackgroundViewWelcome: GradientView!
    @IBOutlet var gradientBackgroundViewStep1: GradientView!
    @IBOutlet var gradientBackgroundViewStep2: GradientView!
    @IBOutlet var gradientBackgroundViewComplete: GradientView!
    // Step 1 outlets
    @IBOutlet var step1QuestionLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var step1CompleteTitleLabel: UILabel!
    @IBOutlet var step1CompleteMessageLabel: UILabel!
    // Step 2 outlets
    @IBOutlet var step2TitleLabel: UILabel!
    @IBOutlet var step2MessageLabel: UILabel!
    @IBOutlet var step2BoyAvatarImageView: UIImageView!
    @IBOutlet var step2GirlAvatarImageView: UIImageView!
    @IBOutlet var step2CustomizeButton: CornerRadiusButton!
    @IBOutlet var step2SkipButton: UIButton!
    // Step complete outlets
    @IBOutlet var stepCompleteTitleLabel: UILabel!
    @IBOutlet var stepCompleteAvatarImageView: CornerRadiusImageView!
    @IBOutlet var stepCompleteMessageLabel: UILabel!
    @IBOutlet var stepCompleteGetStartedButton: CornerRadiusButton!
    
    /// Segue enum
    ///
    /// - GetStarted: GetStarted segue to show Main.storyboard
    
    enum Segue: String {
        case GetStarted = "GetStarted"
    }
    
    // MARK: - Properties
    
    /// Dependency Injection for Managed Object Context.
    
    var managedObjectContext: NSManagedObjectContext?
    
    /// User attributes.
    
    var userName: String? {
        didSet {
            // Once set, update label to match name
            step1CompleteMessageLabel.text = step1CompleteMessageLabel.text?.replacingOccurrences(of: "%name%", with: userName!)
        }
    }
    
    /// Avatar type selection enum.
    ///
    /// - Boy: Boy avatar selected
    /// - Girl: Girl avatar selected
    /// - Custom: Custom avatar selected
    /// - Skipped: Skipped avatar selection
    
    enum AvatarType {
        case Boy
        case Girl
        case Custom
        case Skipped
    }
    
    /// User selected avatar type.
    
    var userAvatarType: AvatarType?
    
    /// For storing selected avatar.
    
    var userSelectedImage: UIImage?
    
    /// The image picker controller for choosing avatar.
    
    lazy var imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.navigationController?.visibleViewController?.setStatusBarStyle(.lightContent)
        imagePickerController.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "black-background"), for: .default)
        imagePickerController.navigationBar.shadowImage = UIImage()
        imagePickerController.modalPresentationStyle = .popover
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        return imagePickerController
    }()
    
    /// The bulletin manager that manages page bulletin items.
    
    lazy var bulletinManager: BulletinManager = {
        // FIXME: Localization
        let rootItem = PageBulletinItem(title: "No Photo Access")
        rootItem.image = #imageLiteral(resourceName: "no-photo-access")
        rootItem.descriptionText = "You need to grant this application with 'Read & Write' access, you can turn it on in settings Privacy > Photos"
        rootItem.actionButtonTitle = "Give access"
        rootItem.alternativeButtonTitle = "Not now"
        
        rootItem.shouldCompactDescriptionText = true
        rootItem.isDismissable = true
        
        // Take user to the settings page
        rootItem.actionHandler = { item in
            guard let openSettingsURL = URL(string: UIApplicationOpenSettingsURLString + Bundle.main.bundleIdentifier!) else { return }
            
            if UIApplication.shared.canOpenURL(openSettingsURL) {
                UIApplication.shared.open(openSettingsURL, options: [:], completionHandler: nil)
            }
            
            item.manager?.dismissBulletin()
        }
        
        // Dismiss bulletin
        rootItem.alternativeHandler = { item in
            item.manager?.dismissBulletin()
        }
        
        return BulletinManager(rootItem: rootItem)
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        animateViews()
    }
    
    /// Configure view properties.
    
    func setupViews() {
        setupWelcomeViews()
        setupStep1Views()
        setupStep2Views()
        setupStepCompleteViews()
    }
    
    /// Configure welcome views.
    
    func setupWelcomeViews() {
        gradientBackgroundViewWelcome.alpha = 1
        
        greetingLabel.transform = .init(scaleX: 0, y: 0)
        greetingLabel.alpha = 0
        
        greetingMessageLabel.alpha = 0
        greetingMessageLabel.transform = .init(translationX: 0, y: 30)
    }
    
    /// Configure step1 views.
    
    func setupStep1Views() {
        gradientBackgroundViewStep1.alpha = 1
        
        step1QuestionLabel.alpha = 0
        step1QuestionLabel.transform = .init(translationX: 0, y: -35)
        
        nameTextField.attributedPlaceholder = NSAttributedString(string: nameTextField.placeholder!, attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.45)])
        nameTextField.alpha = 0
        nameTextField.transform = .init(scaleX: 0, y: 0)
        
        step1CompleteTitleLabel.alpha = 0
        step1CompleteTitleLabel.transform = .init(scaleX: 0, y: 0)
        
        step1CompleteMessageLabel.alpha = 0
        step1CompleteMessageLabel.transform = .init(translationX: 0, y: 50)
    }
    
    /// Configure step2 views.
    
    func setupStep2Views() {
        gradientBackgroundViewStep2.alpha = 1
        
        step2TitleLabel.alpha = 0
        step2TitleLabel.transform = .init(translationX: 0, y: 45)
        
        step2BoyAvatarImageView.alpha = 0
        step2BoyAvatarImageView.layer.cornerRadius = step2BoyAvatarImageView.frame.width / 2
        step2BoyAvatarImageView.layer.masksToBounds = true
        step2BoyAvatarImageView.transform = .init(scaleX: 0, y: 0)
        
        step2GirlAvatarImageView.alpha = 0
        step2GirlAvatarImageView.layer.cornerRadius = step2GirlAvatarImageView.frame.width / 2
        step2GirlAvatarImageView.layer.masksToBounds = true
        step2GirlAvatarImageView.transform = .init(scaleX: 0, y: 0)
        
        step2MessageLabel.alpha = 0
        
        step2CustomizeButton.alpha = 0
        step2CustomizeButton.transform = .init(scaleX: 0, y: 0)
        
        step2SkipButton.alpha = 0
        step2SkipButton.transform = .init(translationX: 0, y: -15)
    }
    
    /// Set up step complete views properties.
    
    func setupStepCompleteViews() {
        gradientBackgroundViewComplete.alpha = 1
        
        stepCompleteTitleLabel.alpha = 0
        stepCompleteTitleLabel.transform = .init(translationX: -35, y: 0)
        
        stepCompleteAvatarImageView.layer.cornerRadius = stepCompleteAvatarImageView.frame.width / 2
        stepCompleteAvatarImageView.layer.masksToBounds = true
        stepCompleteAvatarImageView.alpha = 0
        stepCompleteAvatarImageView.transform = .init(scaleX: 0, y: 0)
        
        stepCompleteMessageLabel.alpha = 0
        stepCompleteMessageLabel.transform = .init(scaleX: 0.2, y: 0.2)
        
        stepCompleteGetStartedButton.alpha = 0
        stepCompleteGetStartedButton.transform = .init(translationX: 0, y: 40)
    }
    
    /// Configure views accordingly to avatar selection.
    
    func configureStepCompleteViews() {
        guard let userAvatarType = userAvatarType else { return }
        
        // Check user avatar selection
        switch userAvatarType {
        case .Boy, .Girl:
            stepCompleteAvatarImageView.image = (userAvatarType == .Boy) ? #imageLiteral(resourceName: "avatar_boy") : #imageLiteral(resourceName: "avatar_girl")
            fallthrough
        case .Skipped:
            // FIXME: Localization
            stepCompleteMessageLabel.text = stepCompleteMessageLabel.text! + "\nLet's start using TooDoo"
        case .Custom:
            // FIXME: Localization
            stepCompleteTitleLabel.text = "👀 Nice pic!"
            stepCompleteMessageLabel.text = stepCompleteMessageLabel.text! + "\nAnd no worries! I don't judge 🙈"
            stepCompleteAvatarImageView.image = userSelectedImage
            stepCompleteAvatarImageView.layer.shadowColor = UIColor(hexString: "111111", withAlpha: 0.35).cgColor
            stepCompleteAvatarImageView.layer.shadowRadius = 30
            stepCompleteAvatarImageView.layer.shadowOffset = CGSize(width: 0, height: 5)
            stepCompleteAvatarImageView.layer.shadowOpacity = 1
        }
    }
    
    /// Save the user data.
    
    func saveUserData() {
        // Save user name
        UserDefaultManager.set(value: userName, forKey: .UserName)
        
        var userAvatar = #imageLiteral(resourceName: "avatar_default")
        
        // Adjust user avatar
        if let userAvatarType = userAvatarType {
            switch userAvatarType {
            case .Boy:
                userAvatar = #imageLiteral(resourceName: "avatar_boy")
            case .Girl:
                userAvatar = #imageLiteral(resourceName: "avatar_girl")
            case .Custom:
                userAvatar = userSelectedImage!
            case .Skipped:
                break
            }
        }
        // Save user avatar
        UserDefaultManager.set(image: userAvatar, forKey: .UserAvatar)
        // Notify that the user finished setup
        NotificationManager.send(notification: .UserHasSetup)
    }
    
    // MARK: - Handle Actions.
    
    @IBAction func nameEntered(_ sender: UITextField) {
        guard let username = sender.text else { return }
        
        if username.trimmingCharacters(in: .whitespaces).count != 0 && username.trimmingCharacters(in: .whitespaces).count < 30 {
            // Validation passed
            // Send success haptic feedback and play sound fx
            Haptic.notification(.success).generate()
            SoundManager.play(soundEffect: .Success)
            // Animate text to green color
            UIView.transition(with: sender, duration: 0.45, options: [.transitionFlipFromBottom, .curveEaseInOut], animations: {
                sender.textColor = HexColor(hexString: "86F9C0")
            }, completion: {
                if $0 {
                    // Once finished, persist data and animate views out
                    self.userName = username
                    self.animateStep1ViewsOut()
                }
            })
        } else {
            // Validation failed, let user re-enter name
            sender.text = ""
            // Send error haptic feedback
            Haptic.notification(.error).generate()
        }
    }
    
    /// User selected boy avatar.
    
    @IBAction func boyAvatarSelected(_ sender: Any) {
        userAvatarType = .Boy
        animateStep2ViewsOut()
        
        // Play click sound
        SoundManager.play(soundEffect: .Click)
    }
    
    /// User selected girl avatar.
    
    @IBAction func girlAvatarSelected(_ sender: Any) {
        userAvatarType = .Girl
        animateStep2ViewsOut()
        
        // Play click sound
        SoundManager.play(soundEffect: .Click)
    }
    
    /// User tapped customize avatar.
    
    @IBAction func customizeAvatarTapped(_ sender: CornerRadiusButton) {
        // Configure image picker for iPad with Popover
        imagePickerController.popoverPresentationController?.delegate = self
        imagePickerController.popoverPresentationController?.sourceView = sender
        
        // Play click sound
        SoundManager.play(soundEffect: .Click)
        
        // Check for access authorization
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
                
            case .authorized:
                // Access is granted by user.
                DispatchQueue.main.async() {
                    // Generate haptic feedback
                    Haptic.impact(.medium).generate()
                    
                    // Present image picker
                    self.present(self.imagePickerController, animated: true, completion: nil)
                }
                break
                
            case .notDetermined:
                // It is not determined until now.
                fallthrough
            case .restricted:
                // User do not have access to photo album.
                fallthrough
            case .denied:
                // User has denied the permission.
                DispatchQueue.main.async() {
                    // Generate haptic feedback
                    Haptic.notification(.warning).generate()
                    // Present bulletin
                    self.bulletinManager.backgroundViewStyle = .blurredDark
                    self.bulletinManager.prepare()
                    self.bulletinManager.presentBulletin(above: self)
                }
                break
            }
        }
    }
    
    /// User tapped skip button.
    
    @IBAction func skipTapped(_ sender: UIButton) {
        userAvatarType = .Skipped
        
        // Generate haptic
        Haptic.impact(.light).generate()
        // Play click sound
        SoundManager.play(soundEffect: .Click)
        
        animateStep2ViewsOut()
    }
    
    /// Prepare for segue.
    ///
    /// - Parameters:
    ///   - segue: The segue to be performed
    ///   - sender: The sender
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        if identifier == Segue.GetStarted.rawValue {
            let destination = segue.destination as! UINavigationController
            let mainController = destination.topViewController as! ToDoOverviewViewController
            
            mainController.managedObjectContext = managedObjectContext
            
            // FIXME: Localization
            let category = Category(context: managedObjectContext!)
            category.name = "Personal"
            category.color = "E7816D"
            category.icon = "personal"
            category.createdAt = Date()
        }
    }
    
    /// Set status bar to white.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Animations

extension SetupWelcomeViewController {
    
    /// Animate views for startup.
    
    func animateViews() {
        animateWelcomeViews()
    }
    
    /// Animate the first welcome views.
    
    func animateWelcomeViews() {
        // Transition in:
        // Animate greetingLabel -> Fade In & Scale Up
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [.curveEaseInOut], animations: {
            self.greetingLabel.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: [], animations: {
            self.greetingLabel.transform = .init(scaleX: 1, y: 1)
        }, completion: {
            if $0 {
                // Once finished, start transitioning out
                // Fade out
                UIView.animate(withDuration: 0.6, delay: 2, options: [.curveEaseInOut], animations: {
                    self.greetingLabel.alpha = 0
                }, completion: nil)
                // Scale down
                UIView.animate(withDuration: 0.6, delay: 2, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: [], animations: {
                    self.greetingLabel.transform = .init(scaleX: 0.01, y: 0.01)
                }, completion: {
                    if $0 {
                        // Once finished, remove from superview
                        self.greetingLabel.removeFromSuperview()
                    }
                })
            }
        })
        
        // Animate greetingMessageLabel -> Fade In & Move Up
        UIView.animate(withDuration: 0.5, delay: 0.65, options: [.curveEaseInOut], animations: {
            self.greetingMessageLabel.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.65, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.5, options: [], animations: {
            self.greetingMessageLabel.transform = .init(translationX: 0, y: 0)
        }, completion: {
            // Once finished, start transitioning out
            if $0 {
                // Fade out and Move down then remove
                UIView.animate(withDuration: 0.5, delay: 1.7, options: [.curveEaseInOut], animations: {
                    self.greetingMessageLabel.alpha = 0
                    self.greetingMessageLabel.transform = .init(translationX: 0, y: 30)
                    self.gradientBackgroundViewWelcome.alpha = 0
                }, completion: {
                    if $0 {
                        // Once finished, remove from superview
                        self.greetingMessageLabel.removeFromSuperview()
                        self.gradientBackgroundViewWelcome.removeFromSuperview()
                        
                        // Start animating step 1
                        self.animateStep1ViewsIn()
                    }
                })
            }
        })
    }
    
    /// Animate step 1 views in.
    
    func animateStep1ViewsIn() {
        // Fade in
        UIView.animate(withDuration: 0.4, delay: 0.2, options: [.curveLinear], animations: {
            self.step1QuestionLabel.alpha = 1
            self.nameTextField.alpha = 1
        }, completion: nil)
        // Move step1QuestionLabel down
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: [], animations: {
            self.step1QuestionLabel.transform = .init(translationX: 0, y: 0)
        }, completion: nil)
        
        // Scale nameTextField up
        UIView.animate(withDuration: 0.6, delay: 0.4, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.7, options: [], animations: {
            self.nameTextField.transform = .init(scaleX: 1, y: 1)
        }) {
            if $0 {
                // Generate light haptic
                Haptic.impact(.light).generate()
                // Focus and let user type in the name
                self.nameTextField.becomeFirstResponder()
            }
        }
    }
    
    /// Animate step 1 views out.
    
    func animateStep1ViewsOut() {
        // Fade out
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseInOut, animations: {
            self.nameTextField.alpha = 0
        }, completion: nil)
        // Scale nameTextField down
        UIView.animate(withDuration: 0.6, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.7, options: [], animations: {
            self.nameTextField.transform = .init(scaleX: 0.05, y: 0.05)
        }, completion: nil)
        // Move step1QuestionLabel down
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: [], animations: {
            self.step1QuestionLabel.alpha = 0
            self.step1QuestionLabel.transform = .init(translationX: 0, y: 40)
        }) {
            if $0 {
                // Once finished, start animating step 1 complete views in
                self.animateStep1Complete()
            }
        }
    }
    
    /// Animate step 1 complete views.
    
    func animateStep1Complete() {
        // Fade in title
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
            self.step1CompleteTitleLabel.alpha = 1
        }, completion: nil)
        // Scale up title
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.5, options: [], animations: {
            self.step1CompleteTitleLabel.transform = .init(scaleX: 1, y: 1)
        }) {
            if $0 {
                // Once finished, animate out
                UIView.animate(withDuration: 0.5, delay: 1.45, options: .curveEaseInOut, animations: {
                    self.step1CompleteTitleLabel.alpha = 0
                    self.step1CompleteTitleLabel.transform = .init(scaleX: 0.05, y: 0.05)
                }, completion: nil)
            }
        }
        
        // Fade in message
        UIView.animate(withDuration: 0.6, delay: 0.4, options: .curveLinear, animations: {
            self.step1CompleteMessageLabel.alpha = 1
        }, completion: nil)
        // Move message down
        UIView.animate(withDuration: 0.6, delay: 0.4, usingSpringWithDamping: 0.55, initialSpringVelocity: 1.3, options: [], animations: {
            self.step1CompleteMessageLabel.transform = .init(translationX: 0, y: 0)
        }) {
            if $0 {
                // Once finished, animate out
                UIView.animate(withDuration: 0.4, delay: 1.4, options: .curveEaseInOut, animations: {
                    self.step1CompleteMessageLabel.alpha = 0
                    self.step1CompleteMessageLabel.transform = .init(translationX: 0, y: -50)
                    self.gradientBackgroundViewStep1.alpha = 0
                }, completion: {
                    if $0 {
                        // Start animating step 2 views in
                        self.animateStep2ViewsIn()
                    }
                })
            }
        }
    }
    
    /// Animate step 2 views in.
    
    func animateStep2ViewsIn() {
        // Fade in and move up title
        UIView.animate(withDuration: 0.4, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: [], animations: {
            self.step2TitleLabel.alpha = 1
            self.step2TitleLabel.transform = .init(translationX: 0, y: 0)
        }, completion: nil)
        // Fade in and scale up boy image
        UIView.animate(withDuration: 0.45, delay: 0.4, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.5, options: [], animations: {
            self.step2BoyAvatarImageView.alpha = 1
            self.step2BoyAvatarImageView.transform = .init(scaleX: 1, y: 1)
        }, completion: nil)
        // Fade in and scale up girl image
        UIView.animate(withDuration: 0.45, delay: 0.5, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.5, options: [], animations: {
            self.step2GirlAvatarImageView.alpha = 1
            self.step2GirlAvatarImageView.transform = .init(scaleX: 1, y: 1)
        }, completion: nil)
        // Fade in message
        UIView.animate(withDuration: 0.35, delay: 0.7, options: .curveEaseInOut, animations: {
            self.step2MessageLabel.alpha = 1
        }, completion: nil)
        // Fade in and scale up customize button
        UIView.animate(withDuration: 0.45, delay: 0.8, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.75, options: [], animations: {
            self.step2CustomizeButton.alpha = 1
            self.step2CustomizeButton.transform = .init(scaleX: 1, y: 1)
        }, completion: nil)
        // Fade in and move down skip button
        UIView.animate(withDuration: 0.5, delay: 2, options: .curveEaseInOut, animations: {
            self.step2SkipButton.alpha = 1
            self.step2SkipButton.transform = .init(translationX: 0, y: 0)
        }, completion: nil)
    }
    
    /// Animate step 2 views out.
    
    func animateStep2ViewsOut() {
        // Configure the step complete views before showing
        configureStepCompleteViews()
        // Persist to user defaults
        saveUserData()
        
        // Fade out and move up title
        UIView.animate(withDuration: 0.4, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: [], animations: {
            self.step2TitleLabel.alpha = 0
            self.step2TitleLabel.transform = .init(translationX: 0, y: -40)
        }, completion: nil)
        // Fade out and move down skip button
        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseInOut, animations: {
            self.step2SkipButton.alpha = 0
            self.step2SkipButton.transform = .init(translationX: 0, y: 20)
        }, completion: nil)
        // Fade out and scale down boy image
        UIView.animate(withDuration: 0.45, delay: 0.4, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.5, options: [], animations: {
            self.step2BoyAvatarImageView.alpha = 0
            self.step2BoyAvatarImageView.transform = .init(scaleX: 0.09, y: 0.09)
        }, completion: nil)
        // Fade out and scale down girl image
        UIView.animate(withDuration: 0.45, delay: 0.5, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.5, options: [], animations: {
            self.step2GirlAvatarImageView.alpha = 0
            self.step2GirlAvatarImageView.transform = .init(scaleX: 0.09, y: 0.09)
        }, completion: nil)
        // Fade out message
        UIView.animate(withDuration: 0.35, delay: 0.7, options: .curveEaseInOut, animations: {
            self.step2MessageLabel.alpha = 0
        }, completion: nil)
        // Fade out and scale up customize button
        UIView.animate(withDuration: 0.45, delay: 0.8, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.75, options: [], animations: {
            self.step2CustomizeButton.alpha = 0
            self.step2CustomizeButton.transform = .init(scaleX: 0.05, y: 0.05)
        }) {
            if $0 {
                // Once finished, start animating complete views in
                // Fade out background gradient
                UIView.transition(with: self.gradientBackgroundViewStep2, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.gradientBackgroundViewStep2.alpha = 0
                }, completion: nil)
                self.animateStepCompleteViewsIn()
            }
        }
    }
    
    /// Animate step complete views in.
    
    func animateStepCompleteViewsIn() {
        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.3, options: [], animations: {
            self.stepCompleteTitleLabel.alpha = 1
            self.stepCompleteTitleLabel.transform = .init(translationX: 0, y: 0)
        }) {
            if $0 {
                // Generate success haptic
                Haptic.notification(.success).generate()
                // Play success sound
                SoundManager.play(soundEffect: .Success)
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.35, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.5, options: [], animations: {
            self.stepCompleteAvatarImageView.alpha = 1
            self.stepCompleteAvatarImageView.transform = .init(scaleX: 1, y: 1)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.35, delay: 0.6, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.5, options: [], animations: {
            self.stepCompleteMessageLabel.alpha = 1
            self.stepCompleteMessageLabel.transform = .init(scaleX: 1, y: 1)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.75, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.5, options: [], animations: {
            self.stepCompleteGetStartedButton.alpha = 1
            self.stepCompleteGetStartedButton.transform = .init(translationX: 0, y: 0)
        }, completion: nil)
    }
}

// MARK: - Image Picker Delegate methods.

extension SetupWelcomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    /// User cancels selection.
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// User selected a photo.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        userAvatarType = .Custom
        userSelectedImage = image
        
        SoundManager.play(soundEffect: .Click)
        
        picker.dismiss(animated: true) {
            self.animateStep2ViewsOut()
        }
    }
}
