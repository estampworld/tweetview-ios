//
//  ViewController.swift
//  Demo Tweet View
//
//  Created by Eduardo Irias on 1/21/21.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        TweetView.prepare()
        
        let tweetView = TweetView(id:"1345021162959503360")
        let width = view.frame.width - 32
        tweetView.frame = CGRect(x: 16, y: 16, width: width, height: width)
        tweetView.delegate = self
        
        self.view.addSubview(tweetView)
        
        tweetView.load()
    }
    

}

extension ViewController: TweetViewDelegate {
    func tweetView(_ tweetView: TweetView, didUpdatedHeight height: CGFloat) {
        tweetView.frame.size = CGSize(width: tweetView.frame.width, height: height)
    }
    
    func tweetView(_ tweetView: TweetView, shouldOpenURL url: URL) {
        let vc = SFSafariViewController(url: url)
        self.showDetailViewController(vc, sender: self)
    }
}
