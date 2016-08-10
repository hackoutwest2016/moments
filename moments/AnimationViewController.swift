//
//  AnimationViewController.swift
//  moments
//
//  Created by Pak on 10/08/16.
//  Copyright © 2016 paksnicefriends. All rights reserved.
//

import UIKit

class AnimationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        var animationImages:[UIImage] = []
        for n in 1...85 {
            //moments0008
            
            var name = "moments00"
            if n < 10{
                name += "0"
            }
            name += String(n)
            
            print(name)
            
            let image = UIImage(named: name)
            animationImages.append(image!)
        }
        
        let animationImageView = UIImageView()
        animationImageView.animationImages = animationImages
        self.view.addSubview(animationImageView)
        
        animationImageView.startAnimating()
        print(animationImageView.isAnimating())
        
        
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
