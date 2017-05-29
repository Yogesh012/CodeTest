//
//  GameViewController.swift
//  codeTest
//
//  Created by Yogesh Sharma on 25/05/17.
//  Copyright © 2017 Yogesh Sharma. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        var gradientLayer: CAGradientLayer!
        
        gradientLayer       = CAGradientLayer()
        gradientLayer.frame = self.view.frame
        
        gradientLayer.colors     = [UIColor(netHex: 0x0000FF).cgColor, UIColor(netHex: 0x000080).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        
        self.view.layer.addSublayer(gradientLayer)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
