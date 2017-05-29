//
//  CollapsableTableViewCell.swift
//  codeTest
//
//  Created by Yogesh Sharma on 28/05/17.
//  Copyright © 2017 Yogesh Sharma. All rights reserved.
//

import UIKit

class CollapsableTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.estimatedRowHeight = 140
        }
    }
    
    var tableData: [PerformanceTableViewController.RowData]?
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//       // tableView?.frame = CGRect(0.2, 0.3, self.bounds.size.width-5, self.bounds.size.height-5)
//        tableView?.frame = CGRect(x: 0.2, y: 0.3, width: self.bounds.size.width-5, height: self.bounds.size.height-5)
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print (tableData?.count ?? 0)
        return tableData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(tableData!)
        let cellIdentifier = "list"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InnerTableViewCell
        cell.leftLabel.text = tableData?[indexPath.row].name
        //cell.rightLabel.text = tableData?[indexPath.row].value
        return cell
    }
}
