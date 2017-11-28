//
//  DetailViewController.swift
//  Edibili-Buddy-Project
//
//  Created by Ashley Roselius on 11/26/17.
//  Copyright © 2017 Ashley Roselius. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var detailImage: UIImageView!
    @IBOutlet var foodResult: UILabel!
    @IBOutlet var conResult: UILabel!
    
    var image: UIImage!
    var food: String!
    var confidence: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
        detailImage.image = image
        detailImage.contentMode = .scaleAspectFit
        foodResult.text = food
        conResult.text = String(confidence)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = true
    }
}
