//
//  ViewController.swift
//  DigitalLife
//
//  Created by ChenQianPing on 16/7/8.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func setupGame(_ sender: UIButton) {
        let game = NumbertailGameController(demension: 4 , threshold: 2048)
        self.present(game, animated: true , completion: nil)
    }

}

