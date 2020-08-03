//
//  ViewController.swift
//  Liar's Dice
//
//  Created by Dylan Kuster on 7/18/20.
//  Copyright © 2020 Dylan Kuster. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController
{
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        playButton.layer.cornerRadius = playButton.frame.height / 5
    }
    
    @IBAction func playPressed(_ sender: UIButton)
    {
        DispatchQueue.main.async
        {
            self.performSegue(withIdentifier: K.playSegue, sender: self)
        }
    }
}

