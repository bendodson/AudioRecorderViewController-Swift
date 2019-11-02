//
//  ViewController.swift
//  AudioRecorderViewControllerExample
//
//  Created by Ben Dodson on 19/10/2015.
//  Copyright © 2015 Dodo Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AudioRecorderViewControllerDelegate {
    
    @IBOutlet weak var urlLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func presentAudioRecorder(sender: AnyObject) {
        let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func audioRecorderViewControllerDismissed(withFileURL fileURL: NSURL?) {
        dismiss(animated: true, completion: nil)
    }
}

