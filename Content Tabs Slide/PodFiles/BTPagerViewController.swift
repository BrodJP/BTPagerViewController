//
//  ViewController.swift
//  Content Tabs Slide
//
//  Created by Bryan Rodriguez on 3/19/18.
//  Copyright © 2018 Applaudo Studios. All rights reserved.
//

import UIKit

public protocol TabElement {
    var viewController: UIViewController { get }
    var tabView: UIView? { get }
    
    func didBecomeSelected()
    func didBecomeUnselected()
}

public class BTPagerViewController: UIViewController, UIScrollViewDelegate {

    private struct MoveToTabRequest {
        let index: Int
        let animated: Bool
    }
    
    class func fromStoryboard() -> BTPagerViewController {
        
        let bundle = Bundle(for: BTPagerViewController.self)
        let storyboard = UIStoryboard(name: "BTPagerViewController", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: "BTPagerViewController") as! BTPagerViewController
    }
    
    // Mark: IBOutlets

    @IBOutlet private var tabContainerView: UIView!
    @IBOutlet private var tabStackView: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var selectedTabIndicatorView: UIView!
    
    // Mark: Constraints
    
    @IBOutlet private var tabContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private var tabStackViewLeftSpaceToContainer: NSLayoutConstraint!
    @IBOutlet private var tabStackViewBottomSpaceToContainer: NSLayoutConstraint!
    @IBOutlet private var tabStackViewRightSpaceToConatiner: NSLayoutConstraint!
    @IBOutlet private var tabStackViewTopSpaceToContainer: NSLayoutConstraint!

    // Mark: Public Properties

    var tabElements: [TabElement]? {
        didSet {
            guard isViewLoaded else {
                return
            }
            
            if let previousControllers = oldValue {
                removeTabs(for: previousControllers)
            }
            
            if let newTabs = tabElements {
                addTabs(for: newTabs)
                
                if newTabs.count > 0 {
                    selectedTabIndex = 0
                }
            }
        }
    }
    
    private(set) var selectedTabIndex: Int? {
        didSet {
            guard isViewLoaded else {
                return
            }
            
            updateTabIndicator()
            notifySelectionChange(previousIndex: oldValue, newIndex: selectedTabIndex)
        }
    }
    
    var visibleTab: TabElement? {
        guard let currentIndex = selectedTabIndex else {
            return nil
        }
        return tabElements?[currentIndex]
    }
    
    var tabHeaderContainerHeight: CGFloat = 80.0 {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateTabContainerViewConstraint()
        }
    }
    
    var selectedIndicatorHeight = CGFloat(5.0) {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateTabIndicator()
        }
    }
    
    var roundedSelectedIndicator = true {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateTabIndicator()
        }
    }
    
    var tabElementSpacing: CGFloat = 32.0 {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateTabHeaderView()
        }
    }
    
    var tabHeaderViewInsets = UIEdgeInsets(top: 30.0, left: 32.0, bottom: 0.0, right: 32.0) {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateTabHeaderView()
        }
    }
    
    var selectedIndicatorOverallLeftSpace: CGFloat = 16.0 {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateTabIndicator()
        }
    }
    
    var selectedIndicatorOverallRightSpace: CGFloat = 16.0 {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateTabIndicator()
        }
    }
    
    var selectedIndicatorInsets = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 8.0, right: 0.0) {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateTabIndicator()
        }
    }
    
    var selectedIndicatorColor = UIColor.blue {
        didSet {
            guard isViewLoaded else {
                return
            }
            
            selectedTabIndicatorView.backgroundColor = selectedIndicatorColor
        }
    }
    
    // Mark: Private Properties
    
    private var tapGesturesAttachedToTabViews = [UIGestureRecognizer]()
    
    private var initialMoveRequest: MoveToTabRequest?
    
    // MARK: Lyfecicle
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateControllerPositions()
        updateTabIndicator()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        if let request = initialMoveRequest, !request.animated {
            moveToTabElementAt(index: request.index, animated: request.animated)
            initialMoveRequest = nil
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let request = initialMoveRequest {
            moveToTabElementAt(index: request.index, animated: request.animated)
            initialMoveRequest = nil
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: Public Functions
    
    func moveToTabElementAt(index: Int, animated: Bool) {
        
        guard isViewLoaded else {
            initialMoveRequest = MoveToTabRequest(index: index, animated: animated)
            return
        }
        
        guard let tabElements = tabElements, tabElements.count > index else {
            return
        }
        
        moveTo(tabAtIndex: index, animated: animated)
    }
    
    func indexOf(tabElement: TabElement) -> Int? {
        
        guard let tabElements = tabElements else {
            return nil
        }
        
        for (index, element) in tabElements.enumerated() {
            if element.viewController == tabElement.viewController {
                return index
            }
        }
        
        return nil
    }
    
    // MARK: Private Functions
    
    private func setupView() {
        
        updateTabContainerViewConstraint()
        updateTabHeaderView()
        updateControllerPositions()
        
        scrollView.delegate = self
        
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        selectedTabIndicatorView.backgroundColor = selectedIndicatorColor
        
        if let newTabs = tabElements {
            addTabs(for: newTabs)
            
            if newTabs.count > 0 {
                selectedTabIndex = 0
            }
        }
    }
    
    @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
        
        guard let index = tapGesturesAttachedToTabViews.index(of: sender) else {
            return
        }
        
        moveTo(tabAtIndex: index, animated: true)
    }
    
    private func moveTo(tabAtIndex: Int, animated: Bool) {
        
        guard let numberOfTabs = tabElements?.count else {
            return
        }
        
        let availableWidthSpaceForTabControllers = scrollView.contentSize.width
        let relativeOffsetAtX = (availableWidthSpaceForTabControllers / CGFloat(numberOfTabs)) * CGFloat(tabAtIndex)
        
        var newOffset = scrollView.contentOffset
        newOffset.x = relativeOffsetAtX
        
        scrollView.setContentOffset(newOffset, animated: animated)
        
        if !animated {
            updateCurrentSelectedTabIfNeccesary()
        }
    }
    
    private func addTabs(for tabElements: [TabElement]) {
        for tabElement in tabElements {
            self.addChildViewController(tabElement.viewController)
            scrollView.addSubview(tabElement.viewController.view)
            tabElement.viewController.didMove(toParentViewController: self)
            
            if let tabView = tabElement.tabView {
                tabStackView.addArrangedSubview(tabView)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
                tabView.addGestureRecognizer(tapGesture)
                tapGesturesAttachedToTabViews.append(tapGesture)
                tabView.isUserInteractionEnabled = true
            }
            
            tabElement.didBecomeUnselected()
        }
    }
    
    private func removeTabs(for tabElements: [TabElement]) {
        for (index, tabElement) in tabElements.enumerated() {
            tabElement.viewController.willMove(toParentViewController: nil)
            tabElement.viewController.view.removeFromSuperview()
            tabElement.viewController.removeFromParentViewController()
            
            if let tabView = tabElement.tabView {
                tabStackView.removeArrangedSubview(tabView)
                
                let tapGesture = tapGesturesAttachedToTabViews[index]
                tabView.removeGestureRecognizer(tapGesture)
            }
        }
        
        tapGesturesAttachedToTabViews.removeAll()
    }
    
    private func updateControllerPositions() {
        
        let visibleSize = scrollView.bounds.size
        var contentSize = CGSize.zero
        contentSize.height = visibleSize.height
        
        if let tabElements = tabElements {
            for (index, tabElement) in tabElements.enumerated() {
                let origin = CGPoint(x: visibleSize.width * CGFloat(index), y: 0.0)
                tabElement.viewController.view.frame = CGRect(origin: origin, size: visibleSize)
            }
            
            contentSize.width = visibleSize.width * CGFloat(tabElements.count)
        }
        
        scrollView.contentSize = contentSize
        
        if let selectedTabIndex = selectedTabIndex {
            moveToTabElementAt(index: selectedTabIndex, animated: false)
        }
    }
    
    private func updateTabIndicator() {
        
        guard let currentIndex = selectedTabIndex else {
            selectedTabIndicatorView.frame = CGRect.zero
            return
        }
        
        selectedTabIndicatorView.frame = tabIndicatorFrameAt(index: currentIndex)
        
        if roundedSelectedIndicator {
            selectedTabIndicatorView.layer.cornerRadius = selectedIndicatorHeight / 2.0
        } else {
            selectedTabIndicatorView.layer.cornerRadius = 0.0
        }
        
        updateTabStackHeightConstraint()
    }
    
    private func updateTabStackHeightConstraint() {
    
        let newBottomSpaceConstraitValue = selectedIndicatorHeight + selectedIndicatorInsets.top + selectedIndicatorInsets.bottom
        tabStackViewBottomSpaceToContainer.constant = newBottomSpaceConstraitValue
        tabStackView.layoutIfNeeded()
    }
    
    private func tabIndicatorFrameAt(index: Int) -> CGRect {
        
        guard let numberOfTabs = tabElements?.count, numberOfTabs > index else {
            return CGRect.zero
        }
        
        var indicatorFrame = CGRect.zero
        
        if numberOfTabs > 0 {
            let selectedIndicatorLeftAndRightSpace = selectedIndicatorOverallLeftSpace + selectedIndicatorOverallRightSpace
            let availableWidthSpace = tabContainerView.frame.size.width - selectedIndicatorLeftAndRightSpace
            
            indicatorFrame.size.height = selectedIndicatorHeight
            indicatorFrame.origin.y = tabContainerView.frame.size.height - selectedIndicatorHeight - selectedIndicatorInsets.bottom
            
            let leftAndRightMarginsForIndicator = selectedIndicatorInsets.left + selectedIndicatorInsets.right
            indicatorFrame.size.width = ( availableWidthSpace / CGFloat(numberOfTabs) ) - leftAndRightMarginsForIndicator
            
            let totalLeftMarging = selectedIndicatorInsets.left + selectedIndicatorOverallLeftSpace
            indicatorFrame.origin.x = CGFloat(index) * ( availableWidthSpace / CGFloat(numberOfTabs) ) + totalLeftMarging
        }
        
        return indicatorFrame
    }
    
    private func selectedTabOffsetFrom(scrollView: UIScrollView) -> CGPoint {
        
        var newOffset = selectedTabIndicatorView.frame.origin
        
        let scrollViewContentSizeWith = scrollView.contentSize.width
        let relativeOffset = scrollView.contentOffset.x / scrollViewContentSizeWith
        
        let leftAndRightMarginsForIndicatorContainerView = selectedIndicatorOverallLeftSpace + selectedIndicatorOverallRightSpace
        let availableWidthSpaceForSelector = tabContainerView.frame.size.width - leftAndRightMarginsForIndicatorContainerView
        newOffset.x = availableWidthSpaceForSelector * relativeOffset + selectedIndicatorInsets.left + selectedIndicatorOverallLeftSpace
        return newOffset
    }
    
    private func updateTabSelectorOffset(with offset: CGPoint) {
        
        var currentSelectorFrame = selectedTabIndicatorView.frame
        currentSelectorFrame.origin = offset
        selectedTabIndicatorView.frame = currentSelectorFrame
    }
    
    private func updateCurrentSelectedTabIfNeccesary() {
        guard let tabElements = tabElements else {
            selectedTabIndex = nil
            return
        }
        
        let contentOffset = scrollView.contentOffset
        
        for (index, tabElement) in tabElements.enumerated() {
            if contentOffset.x == tabElement.viewController.view.frame.origin.x {
                if index != selectedTabIndex {
                    selectedTabIndex = index
                }
                break
            }
        }
    }
    
    private func notifySelectionChange(previousIndex: Int?, newIndex: Int?) {
        
        guard let tabElements = tabElements else {
            return
        }
        
        if let previousIndex = previousIndex {
            let tabElement = tabElements[previousIndex]
            tabElement.didBecomeUnselected()
        }
        
        if let newIndex = newIndex {
            let tabElement = tabElements[newIndex]
            tabElement.didBecomeSelected()
        }
    }
    
    private func updateTabContainerViewConstraint() {
        
        tabContainerViewHeightConstraint.constant = tabHeaderContainerHeight
        tabContainerView.layoutIfNeeded()
    }
    
    private func updateTabHeaderView() {
        
        tabStackView.spacing = tabElementSpacing
        tabStackViewTopSpaceToContainer.constant = tabHeaderViewInsets.top
        tabStackViewLeftSpaceToContainer.constant = tabHeaderViewInsets.left
        tabStackViewBottomSpaceToContainer.constant = tabHeaderViewInsets.bottom
        tabStackViewRightSpaceToConatiner.constant = tabHeaderViewInsets.right
        tabStackView.layoutIfNeeded()
    }
    
    // MARK: ScollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newTabSelectorOffset = selectedTabOffsetFrom(scrollView: scrollView)
        updateTabSelectorOffset(with: newTabSelectorOffset)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentSelectedTabIfNeccesary()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentSelectedTabIfNeccesary()
    }
}

