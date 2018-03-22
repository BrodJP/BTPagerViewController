//
//  AppDelegate.swift
//  Content Tabs Slide
//
//  Created by Bryan Rodriguez on 3/19/18.
//  Copyright © 2018 Applaudo Studios. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let tabViewController = BTPagerViewController.fromStoryboard()
        tabViewController.tabElements = exampleTabElements()
        
        //TabHeaderView UI costumization
        tabViewController.tabHeaderContainerHeight = 80.0
        tabViewController.tabHeaderViewInsets = UIEdgeInsets(top: 30.0, left: 32.0, bottom: 0.0, right: 32.0)
        
        //TabElements UI constumization
        tabViewController.tabElementSpacing = 32.0
        
        // SelectedIndicatorView UI constumization
        tabViewController.roundedSelectedIndicator = true
        tabViewController.selectedIndicatorOverallLeftSpace = 16.0
        tabViewController.selectedIndicatorOverallRightSpace = 16.0
        tabViewController.selectedIndicatorInsets = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 8.0, right: 0.0)
        tabViewController.selectedIndicatorHeight = 5.0
        tabViewController.selectedIndicatorColor = .lightBlue
        
        // Initially shows tab at index 3
        // If animated = true, then animation will happen when viewDidAppear is called
        tabViewController.moveToTabElementAt(index: 3, animated: true)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabViewController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    
    fileprivate func exampleTabElements() -> [TabElement] {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controllerStoryboardID = "BasicTabElementViewController"
        
        
        let testController1 = storyboard.instantiateViewController(withIdentifier: controllerStoryboardID) as! BasicTabElementViewController
        
        let testController2 = storyboard.instantiateViewController(withIdentifier: controllerStoryboardID) as! BasicTabElementViewController
        testController2.revertTestingCells = true
        
        let testController3 = storyboard.instantiateViewController(withIdentifier: controllerStoryboardID) as! BasicTabElementViewController
        
        let testController4 = storyboard.instantiateViewController(withIdentifier: controllerStoryboardID) as! BasicTabElementViewController
        testController4.revertTestingCells = true
        
        return [testController1, testController2, testController3, testController4]
    }
}

