//
//  ViewController.swift
//  FRSwitch
//
//  Created by johnny12000 on 06/28/2017.
//  Copyright (c) 2017 johnny12000. All rights reserved.
//

import UIKit
import FRSwitch

class ViewController: UIViewController {

    @IBOutlet var testSwitch: FRSwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testSwitch.on = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

