# BulletinBoard

[![CI Status](https://travis-ci.org/alexaubry/BulletinBoard.svg?branch=master)](https://travis-ci.org/alexaubry/BulletinBoard)
[![Version](https://img.shields.io/cocoapods/v/BulletinBoard.svg?style=flat)](https://cocoapods.org/pods/BulletinBoard)
[![License](https://img.shields.io/cocoapods/l/BulletinBoard.svg?style=flat)](https://cocoapods.org/pods/BulletinBoard)
[![Platform](https://img.shields.io/cocoapods/p/BulletinBoard.svg?style=flat)](https://cocoapods.org/pods/BulletinBoard)
[![Documentation](https://img.shields.io/badge/Documentation-available-blue.svg)](https://alexaubry.github.io/BulletinBoard)
[![Contact: @_alexaubry](https://raw.githubusercontent.com/alexaubry/BulletinBoard/master/.assets/twitter_badge.svg?sanitize=true)](https://twitter.com/_alexaubry)

BulletinBoard is an iOS library that generates and manages contextual cards displayed at the bottom of the screen. It is especially well suited for quick user interactions such as onboarding screens or configuration.

It has an interface similar to the cards displayed by iOS for AirPods, Apple TV configuration and NFC tag scanning.

It has built-in support for accessibility features such as VoiceOver and Switch Control.

Here are some screenshots showing what you can build with BulletinBoard:

![Demo Screenshots](https://raw.githubusercontent.com/alexaubry/BulletinBoard/master/.assets/demo_screenshots.png)

## Requirements

- iOS 9 and later
- Swift 3.2 and later

## Demo

A demo application is included in the `BulletinBoard` workspace. It demonstrates how to: 

- integrate the library (setup, data flow)
- create standard page cards
- create custom page subclasses to add features
- create custom cards from scratch

Build and run the `Instanimal` scheme to use it.

Here's a video showing it in action:

[![Watch Demo on YouTube](https://raw.githubusercontent.com/alexaubry/BulletinBoard/master/.assets/demo_thumbnail.png)](https://youtu.be/DT58Lz7qpTA)

## Installation

BulletinBoard is available via CocoaPods and Carthage.

### CocoaPods

To install BulletinBoard using [CocoaPods](https://cocoapods.org), add this line to your `Podfile`:

~~~ruby
pod 'BulletinBoard'
~~~

### Carthage

To install BulletinBoard using [Carthage](https://github.com/Carthage/Carthage), add this line to your `Cartfile`:

~~~
github "alexaubry/BulletinBoard"
~~~

## Usage

## The Basics

The `BulletinManager` class generates, manages and displays bulletin cards. Cards are created using bulletin items. Bulletin items are objects that conform to the `BulletinItem` protocol.

The library provides a standard item type: `PageBulletinItem`. If you need to customize the items, you can override this class, or create new item types from scratch.

## Displaying Bulletins

To display bulletins you first need to create the root item to display (explained in the next sections).

With this root item, you need to create a `BulletinManager`. We recommend putting it in the view controller that will display the bulletin.

~~~swift
class ViewController: UIViewController {

    lazy var bulletinManager: BulletinManager = {

        let rootItem: BulletinItem = // ... create your item here
        return BulletinManager(rootItem: rootItem)

    }()

}
~~~

To present your bulletin, call this method:

~~~swift
bulletinManager.prepare()
bulletinManager.presentBulletin(above: self)
~~~

Always call `prepare()` before calling `presentBulletin()`! Failure to do so will cause a precondition failure (TL;DR your app will crash).

For the case of onboarding, you can call it in `viewWillAppear(animated:)` after checking if the user has already completed onboarding.

## Creating Page Items

You can create standard page items using the `PageBulletinItem` class.

It takes care of generating a user interface with standard components:

- a title (required)
- an icon image (should be 128x128px or less)
- a description text
- a large action button
- a smaller alternative button

For example, this interface was created using a `PageBulletinItem`:

![Customizing PageBulletinItem](https://raw.githubusercontent.com/alexaubry/BulletinBoard/master/.assets/page_customization.png)

To recreate this interface, use this code:

~~~swift
let page = PageBulletinItem(title: "Push Notifications")
page.image = UIImage(named: "...")

page.descriptionText = "Receive push notifications when new photos of pets are available."
page.actionButtonTitle = "Subscribe"
page.alternativeButtonTitle = "Not now"
~~~

If you omit an optional property, the page won't generate a view for it. For instance, if you set `alternativeButtonTitle` to `nil`, the card won't display an alternative button.

### Customizing the Appearance

#### Colors

You can customize the colors on the page by using the `interfaceFactory` property.

This property references a `BulletinInterfaceFactory`, which is responsible for generating the standard components (more on this later).

There are two properties that you can change:

- `tintColor` - the tint color of the buttons (defaults to iOS blue)
- `actionButtonTitleColor` - the color of action button titles

You need to set these before you present / push the item. Changing them after presentation will have no effect.

**Example**

~~~swift
page.interfaceFactory.tintColor = UIColor(red: 0.294, green: 0.85, blue: 0.392, alpha: 1) // green
page.interfaceFactory.actionButtonTitleColor = .white
~~~

This produces a card with the following appearance:

![Demo Tint Color](https://raw.githubusercontent.com/alexaubry/BulletinBoard/master/.assets/demo_tint_color.png)

#### Text Size

If the description text is long, you can set the `shouldCompactDescriptionText` property to `true` to reduce the text size.

![Text Size](https://raw.githubusercontent.com/alexaubry/BulletinBoard/master/.assets/demo_long_text.png)

This property is `false` by default.

### Handling Button Taps

To handle taps on buttons, set a closure for these properties:

- `actionHandler` - called when the action button is tapped.
- `alternativeHandler` - called when the alternative button is tapped.

~~~swift
page.actionHandler = { (item: PageBulletinItem) in
    print("Action button tapped")
}
~~~

This prints `"Action button tapped"` when the action button is tapped.

~~~swift
page.alternativeHandler = { (item: PageBulletinItem) in
    print("Alternative button tapped")
}
~~~

This prints `"Alternative button tapped"` when the alternative button is tapped.

Use these handlers as an opportunity to change the presented item, dismiss the bulletin and/or pass data to your model.

## Changing the Presented Item

The `BulletinItem` protocol exposes a `manager` property that is set when the item is currently being displayed by a manager.

You can use it to interact with the presented bulletin. Call:

- `manager?.popItem()` to go back to the previous item
- `manager?.popToRootItem()` to go back to the first item
- `manager?.push(item:)` with a `BulletinItem` to present a new item
- `manager?.dismissBulletin(animated:)` to dismiss the bulletin

You need to call these methods from the main thread. Never force unwrap `manager`, as this property will be unset as soon as the item is removed from the bulletin.

It is also possible to set the `nextItem` property to the `BulletinItem` that should be displayed next and call the `displayNextItem()` method when you want to display it.

For instance, to present a new card when the user taps the action button:

~~~swift
page.nextItem = makeLocationPage() // Creates a new PageBulletinItem

page.actionHandler = { (item: PageBulletinItem) in
    item.displayNextItem()
}
~~~

This creates the following interaction:

![Next Item](https://raw.githubusercontent.com/alexaubry/BulletinBoard/master/.assets/demo_segue.png)

## Displaying an Activity Indicator

If you need to perform a task between the moment the user taps a button and the moment you'll be able to change the presented item, you can call `displayActivityIndicator()` method on the item manager to hide the current card and display an activity indicator.

This is especially useful if you need to fetch data from a server (in-app purchase price, subscription status, ...) or save data (e.g. Core Data).

Once your task is finished, call one of the methods described in [Changing the Presented Item](#changing-the-presented-item).

**Example**:

~~~swift
page.actionHandler = { (item: PageBulletinItem) in
    item.manager?.displayActivityIndicator()
    // do your task
    // ...
    // when your task is finished, transition to the appropriate bulletin item
    item.displayNextItem()
}
~~~

This creates the following interaction:

![Activity Indicator](https://raw.githubusercontent.com/alexaubry/BulletinBoard/master/.assets/demo_activity.png)

## Customizing the Background View

By default, the content behind the card is covered with a semi-opaque view (known as the `.dimming` style).

You can customize the background view by changing the `backgroundViewStyle` property of the manager before calling `prepare()`.

**Example**:

~~~swift
manager.backgroundViewStyle = .blurredExtraLight
manager.prepare()
~~~

Several styles are available in the `BulletinBackgroundViewStyle` enum:

![Dimming View](https://raw.githubusercontent.com/alexaubry/BulletinBoard/master/.assets/demo_background_styles.png)

> Note: blurred backgrounds are available in iOS 10.0 and later.

## Dismissal

If you set the `isDismissable` property to `true`, the user will be able to dismiss the bulletin by tapping outside of the card or by swiping the card down.

You should set this property to `true` for the last item.

## Creating Custom Items

To create custom bulletin items, create a class that implements the `BulletinItem` protocol. To learn with a concrete example, you can read the implementation of `PageBulletinItem`.

### Conforming to `BulletinItem`

To conform to this protocol, you need to add the required properties and implement two methods:

#### `makeArrangedSubviews()`

This method should return all the elements to display on the card.

Please note that the `alpha` and `isHidden` properties will be ignored.

#### `tearDown()`

In this method, clear all the resources allocated for the item (such as notification observers or button targets). After this method is called, the `manager` will be set to `nil` and the arranged subviews will be hidden and removed from the card.

### Generating Standard Views

Even though you are creating a custom card, you may still want to display some standard elements, such as title labels or action buttons.

To generate standard elements, use the methods of `BulletinInterfaceFactory`:

- `makeTitleLabel(reading:)` to create a title label with the given title
- `makeDescriptionLabel(isCompact:)` to create a description label
- `makeActionButton(title:)` to create an action button
- `makeAlternativeButton(title:)` to create an alternative button
- `makeGroupStack(spacing:)` to create a vertical stack view with the given spacing

## Internals

BulletinBoard uses stack views and Auto Layout to display and manage cards. It automatically adapts to changes in width and height. iPad and iPhone X are supported out of the box.

If you are interested in learning how it works in more details, look at the implementation of `BulletinManager`, `BulletinViewController` and `BulletinInterfaceFactory`.

## Contributing

Thank you for your interest in the project! Contributions are welcome and appreciated.

Make sure to read these guides before getting started:

- [Code of Conduct](https://github.com/alexaubry/BulletinBoard/blob/master/CODE_OF_CONDUCT.md)
- [Contribution Guidelines](https://github.com/alexaubry/BulletinBoard/blob/master/CONTRIBUTING.md)

## Apps Using _BulletinBoard_

Feel free to submit a PR if you’re using this library in your apps.

## Author

Written by Alexis Aubry. You can [find me on Twitter](https://twitter.com/_alexaubry).

## License

BulletinBoard is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
