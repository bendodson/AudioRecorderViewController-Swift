//
//  AudioRecorderViewController.swift
//  AudioRecorderViewControllerExample
//
//  Created by Ben Dodson on 19/10/2015.
//  Copyright © 2015 Dodo Apps. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioRecorderViewControllerDelegate: class {
    func audioRecorderViewControllerDismissed(withFileURL fileURL: NSURL?)
}


class AudioRecorderViewController: UINavigationController {
    
    internal let childViewController = AudioRecorderChildViewController()
    weak var audioRecorderDelegate: AudioRecorderViewControllerDelegate?
    var statusBarStyle: UIStatusBarStyle = .Default
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        statusBarStyle = UIApplication.sharedApplication().statusBarStyle
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(statusBarStyle, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        childViewController.audioRecorderDelegate = audioRecorderDelegate
        viewControllers = [childViewController]
        
        navigationBar.barTintColor = UIColor.blackColor()
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    
    // MARK: AudioRecorderChildViewController
    
    internal class AudioRecorderChildViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
        
        var saveButton: UIBarButtonItem!
        @IBOutlet weak var timeLabel: UILabel!
        @IBOutlet weak var recordButton: UIButton!
        @IBOutlet weak var recordButtonContainer: UIView!
        @IBOutlet weak var playButton: UIButton!
        weak var audioRecorderDelegate: AudioRecorderViewControllerDelegate?

        var timeTimer: NSTimer?
        var milliseconds: Int = 0
        
        var recorder: AVAudioRecorder!
        var player: AVAudioPlayer?
        var outputURL: NSURL
        
        init() {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
            let outputPath = documentsPath.stringByAppendingPathComponent("\(NSUUID().UUIDString).m4a")
            outputURL = NSURL(fileURLWithPath: outputPath)
            super.init(nibName: "AudioRecorderViewController", bundle: nil)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            title = "Audio Recorder"
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismiss:")
            edgesForExtendedLayout = .None
            
            saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveAudio:")
            navigationItem.rightBarButtonItem = saveButton
            saveButton.enabled = false
            
            let settings = [AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC), AVSampleRateKey: NSNumber(integer: 44100), AVNumberOfChannelsKey: NSNumber(integer: 2)]
            try! recorder = AVAudioRecorder(URL: outputURL, settings: settings)
            recorder.delegate = self
            recorder.prepareToRecord()
            
            recordButton.layer.cornerRadius = 4
            recordButtonContainer.layer.cornerRadius = 25
            recordButtonContainer.layer.borderColor = UIColor.whiteColor().CGColor
            recordButtonContainer.layer.borderWidth = 3
        }
        
        override func viewDidAppear(animated: Bool) {
            super.viewDidAppear(animated)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                try AVAudioSession.sharedInstance().setActive(true)
            }
            catch let error as NSError {
                NSLog("Error: \(error)")
            }
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopRecording:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        }
        
        override func viewWillDisappear(animated: Bool) {
            super.viewWillDisappear(animated)
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        
        func dismiss(sender: AnyObject) {
            cleanup()
            audioRecorderDelegate?.audioRecorderViewControllerDismissed(withFileURL: nil)
        }
        
        func saveAudio(sender: AnyObject) {
            cleanup()
            audioRecorderDelegate?.audioRecorderViewControllerDismissed(withFileURL: outputURL)
        }
        
        @IBAction func toggleRecord(sender: AnyObject) {
            
            timeTimer?.invalidate()
            
            if recorder.recording {
                recorder.stop()
            } else {
                milliseconds = 0
                timeLabel.text = "00:00.00"
                timeTimer = NSTimer.scheduledTimerWithTimeInterval(0.0167, target: self, selector: "updateTimeLabel:", userInfo: nil, repeats: true)
                recorder.deleteRecording()
                recorder.record()
            }
            
            updateControls()
            
        }
        
        func stopRecording(sender: AnyObject) {
            if recorder.recording {
                toggleRecord(sender)
            }
        }
        
        func cleanup() {
            timeTimer?.invalidate()
            if recorder.recording {
                recorder.stop()
                recorder.deleteRecording()
            }
            if let player = player {
                player.stop()
                self.player = nil
            }
        }
        
        @IBAction func play(sender: AnyObject) {
            
            if let player = player {
                player.stop()
                self.player = nil
                updateControls()
                return
            }
            
            do {
                try player = AVAudioPlayer(contentsOfURL: outputURL)
            }
            catch let error as NSError {
                NSLog("error: \(error)")
            }
            
            player?.delegate = self
            player?.play()
            
            updateControls()
        }
        
        
        func updateControls() {
            
            UIView.animateWithDuration(0.2) { () -> Void in
                self.recordButton.transform = self.recorder.recording ? CGAffineTransformMakeScale(0.5, 0.5) : CGAffineTransformMakeScale(1, 1)
            }
            
            if let _ = player {
                playButton.setImage(UIImage(named: "StopButton"), forState: .Normal)
                recordButton.enabled = false
                recordButtonContainer.alpha = 0.25
            } else {
                playButton.setImage(UIImage(named: "PlayButton"), forState: .Normal)
                recordButton.enabled = true
                recordButtonContainer.alpha = 1
            }
            
            playButton.enabled = !recorder.recording
            playButton.alpha = recorder.recording ? 0.25 : 1
            saveButton.enabled = !recorder.recording
            
        }
        
        
        
        
        // MARK: Time Label
        
        func updateTimeLabel(timer: NSTimer) {
            milliseconds++
            let milli = (milliseconds % 60) + 39
            let sec = (milliseconds / 60) % 60
            let min = milliseconds / 3600
            timeLabel.text = NSString(format: "%02d:%02d.%02d", min, sec, milli) as String
        }
        
        
        // MARK: Playback Delegate
        
        func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
            self.player = nil
            updateControls()
        }
        
        
        
    }

}

