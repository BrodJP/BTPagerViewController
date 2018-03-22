//
//  BasicTabElementViewController.swift
//  Content Tabs Slide
//
//  Created by Bryan Rodriguez on 3/20/18.
//  Copyright © 2018 Applaudo Studios. All rights reserved.
//

import UIKit

class BasicTabElementViewController: UIViewController, TabElement, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tabLabelView: UIView!
    @IBOutlet var tabLabel: UILabel!
    
    private let unselectedTabLabelViewColor = UIColor.customLightGray
    private let selectedTabLabelViewColor = UIColor.lightBlue
    
    var revertTestingCells: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupView() {
        tabLabel.layer.cornerRadius = 10.0
        tabLabel.layer.masksToBounds = true
        tabLabel.text = title
        tabLabel.textColor = .black
    }
    
    // MARK: UITableViewDatasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellOneID = "CellOne"
        let cellTwoID = "CellTwo"
        
        var cellID: String!
        if (indexPath.row % 2) == 0 {
            cellID = revertTestingCells ? cellTwoID : cellOneID
        } else {
            cellID = revertTestingCells ? cellOneID : cellTwoID
        }
        
        return tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
    
    // MARK: TabElement
    
    var viewController: UIViewController {
        return self
    }
    
    var tabView: UIView? {
        return tabLabelView
    }
    
    func didBecomeSelected() {
        UIView.animate(withDuration: 0.2) {
            self.tabLabel.layer.backgroundColor = self.selectedTabLabelViewColor.cgColor
        }
    }
    
    func didBecomeUnselected() {
        UIView.animate(withDuration: 0.2) {
            self.tabLabel.layer.backgroundColor = self.unselectedTabLabelViewColor.cgColor
        }
    }
}
