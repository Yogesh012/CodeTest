//
//  PerformanceTableViewController.swift
//  codeTest
//
//  Created by Yogesh Sharma on 26/05/17.
//  Copyright © 2017 Yogesh Sharma. All rights reserved.
//

import UIKit


class PerformanceTableViewController: UITableViewController {
    
     struct RowData {
        var name : String!
        var value: String!
        
        init(name: String, value: String){
            self.name  = name
            self.value = value
        }
    }
    
    private struct Section {
        var name     : String!
        var value    : String!
        var collapsed: Bool!
        var rows     : [RowData]!
        
        init(name: String, value: String, rows: [RowData], collapsed: Bool = true) {
            self.name      = name
            self.value     = value
            self.rows      = rows
            self.collapsed = collapsed
        }
    }
    
    private var sections = [Section]()
    private func getData() -> NSDictionary? {
        let json : NSDictionary?
        do {
            if let file = Bundle.main.url(forResource: "list", withExtension: "json") {
                let data = try Data(contentsOf: file)
                json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                //print((json["Equity - Banking"]! as! NSDictionary)["_figure"]!)
                return json
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let json = getData()
        
        for (key, value) in json! {
            let value = value as! NSDictionary
            var rows = [RowData]()
            
            let numberFormatter = NumberFormatter()
            
            numberFormatter.alwaysShowsDecimalSeparator = false
            numberFormatter.maximumFractionDigits       = 2
            numberFormatter.minimumIntegerDigits        = 1
            numberFormatter.roundingMode = .halfUp
            numberFormatter.numberStyle                 = .none
            //numberFormatter.locale                      = Locale(identifier: "en_US")
            
            for (key, value) in value {
                let k = key as! String
                if k != "_figure" {
                    let data: RowData
                    var v = (((value as! NSDictionary)["_figure"]!) as! NSArray)[0]
                    if v is NSNull{
                        data = RowData(name: k, value: "null")
                    }
                    else {
                        v = numberFormatter.string(from: v as! NSNumber)!
                        data = RowData(name: k, value: "\(v)")
                    }
                    
                    rows.append(data)
                }
            }
            
            var v = ((value["_figure"]!) as! NSArray)[0]
            v  = numberFormatter.string(from: v as! NSNumber)!
            let section = Section(name: key as! String, value: "\(v)", rows: rows)
            sections.append(section)
        }
       // print(sections)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
        
        //set an empt footer to the tabel
        self.tableView.tableFooterView = UIView()
        
    }
    
    func toggleCollapse(sender: UIGestureRecognizer){
        let v = sender.view
        let section = v!.tag
        let collapsed = sections[section].collapsed
        sections[section].collapsed = !collapsed!
        
        self.tableView.reloadSections(NSIndexSet(index: section) as IndexSet , with: .automatic)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sections[section].collapsed!) ? 0 : sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //Construct header view of the table
        let frame = tableView.frame
        let viewRect = CGRect(x: 0, y: 0, width: frame.size.width, height: 60)
        let mainView = UIView(frame: viewRect)
        let headerView = UIView(frame: mainView.frame)
        headerView.backgroundColor = UIColor.init(netHex:0xFFFFFF)
        headerView.alpha = 1
        
        if sections[section].collapsed == false {
            headerView.layer.masksToBounds = false
            headerView.layer.shadowColor = UIColor.black.cgColor
            headerView.layer.shadowOpacity = 0.4
            headerView.layer.shadowOffset = CGSize(width: 0, height: 0.0)
            headerView.layer.shadowRadius = 2.0
            
            let rect = CGRect(x: 0.0, y: 5.0, width: headerView.bounds.width - 16, height: headerView.bounds.height - 10)
            headerView.layer.shadowPath = UIBezierPath(rect: rect).cgPath
            headerView.layer.shouldRasterize = true
            
            let animation = CABasicAnimation(keyPath: "shadowOpacity")
            animation.fromValue = headerView.layer.shadowOpacity
            animation.toValue = 0.4
            animation.duration = 1.0
            headerView.layer.add(animation, forKey: "shadowOpacity")
        }
        
        let labelFrame = CGRect(origin: headerView.frame.origin, size: CGSize(width: 100, height: 60))
        let margins = headerView.layoutMarginsGuide
        
        //label 1
        var label = UILabel(frame: labelFrame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = sections[section].name
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "System", size: 15.0)
        
        headerView.addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        
        //button 1
        let button = UIButton(frame: labelFrame)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "rightArrow")
        button.setImage(image, for: .normal)
        
        headerView.addSubview(button)
        
        button.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -10).isActive = true
        button.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        
        //label 2
        label = UILabel(frame: labelFrame)
        label.translatesAutoresizingMaskIntoConstraints = false
       // print(sections[section].value!)
        label.text = "\(sections[section].value!)%"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "System", size: 15.0)
        if sections[section].value! == "null" {
            label.textColor = UIColor(netHex: 0x008000)
        }
        else if Double(sections[section].value)! <= 10.00 {
            label.textColor = UIColor.red
        }
        else if Double(sections[section].value!)! > 10.00 && Double(sections[section].value!)! <= 13.00 {
            label.textColor = UIColor.orange
        }
        else {
            label.textColor = UIColor(netHex: 0x008000)
        }
        
        headerView.addSubview(label)
        
        label.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -12).isActive = true
        label.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        
        if sections[section].collapsed == false {
            //button.transform = button.transform.rotated(by: CGFloat(Double.pi/2))
            button.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        }
        
        
        
        //add tap gesture to the header view
        let gesture = UITapGestureRecognizer(target: self, action: #selector(PerformanceTableViewController.toggleCollapse))
        headerView.addGestureRecognizer(gesture)
        headerView.tag = section
        
        mainView.addSubview(headerView)
        
        return mainView
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.subviews[0].translatesAutoresizingMaskIntoConstraints = false
        view.subviews[0].leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        view.subviews[0].trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        view.subviews[0].topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        view.subviews[0].bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Header"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CollapsableTableViewHeader
//        cell.tableData = sections[indexPath.section].rows
//        cell.tableView.reloadData()
        cell.leftLabel.text = sections[indexPath.section].rows[indexPath.row].name
        cell.rightLabel.text = "\(sections[indexPath.section].rows[indexPath.row].value!)%"
        
        if sections[indexPath.section].rows[indexPath.row].value == "null" {
            cell.rightLabel.textColor = UIColor.red
            cell.rightLabel.text = "\(sections[indexPath.section].rows[indexPath.row].value!)"
        }
        else if Double(sections[indexPath.section].rows[indexPath.row].value)! <= 10.00 {
            cell.rightLabel.textColor = UIColor.red
        }
        else if Double(sections[indexPath.section].rows[indexPath.row].value)! > 10.00 && Double(sections[indexPath.section].rows[indexPath.row].value!)! <= 13.00 {
            cell.rightLabel.textColor = UIColor.orange
        }
        else {
            cell.rightLabel.textColor = UIColor(netHex: 0x008000)
        }
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
////        cell.subviews[0].translatesAutoresizingMaskIntoConstraints = false
////        cell.subviews[0].leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor, constant: -12.0).isActive = true
////        cell.subviews[0].trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor, constant: 12.0).isActive = true
//    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
