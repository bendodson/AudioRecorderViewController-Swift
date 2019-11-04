# AudioRecorderViewController-Swift
A simple view controller (in Swift 5) that allows you to record audio as simply as you would pick photos or record video with the iOS system frameworks.

## Installation

Copy the AudioRecorderViewController directory into your project ensuring that you add it to your target and choose "Copy items if necessary". There are 4 files which consist of the class, xib file for interface, and 2 images for the play and stop buttons respectively.

## Screenshot

![AudioRecorderViewController-Swift being presented modally](example.png?raw=true)

## Example Usage
	@IBAction func presentAudioRecorder(sender: AnyObject) {
        let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func audioRecorderViewControllerDismissed(withFileURL fileURL: NSURL?) {
        // do something with fileURL
        dismiss(animated: true, completion: nil)
    }

The controller works on a simple basis similar to `UIImagePickerController`. You present the controller modally after you have set the `audioRecorderDelegate`. Once the user cancels or chooses to save an audio clip, the `audioRecorderViewControllerDismissed` callback will be triggered with an optional `fileURL` - you are now responsible for clearing that file up (it'll be saved in your Documents directory) and doing whatever else you want with it. You will also need to dismiss the audio recorder view controller.

In terms of functionality, the controller allows you to record, playback, and re-record audio as well as save it to your Documents directory for further processing.

