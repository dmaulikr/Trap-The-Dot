//
//  ResultViewController.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/22/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import UIKit

enum Result {
    case Win
    case Fail
    
    var title: String {
        return self == .Win ? "✌️" : "输了"
    }
    
    var message: String {
        return self == .Win ? "✌️" : "赢了"
    }
}

class ResultViewController: UIViewController {
    
    var titleLabel: UILabel!
    lazy var resultTitleLabel = UILabel()
    lazy var resultDescriptionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel = addTTDTitle()
        
        view.addSubviews([resultTitleLabel, resultDescriptionLabel])
        
        resultTitleLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(titleLabel.snp_bottom).offset(20)
        }
        resultDescriptionLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(resultTitleLabel.snp_bottom).offset(20)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
