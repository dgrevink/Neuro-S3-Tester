//
//  ViewController.swift
//  Neuro-S3-Tester
//
//  Created by David Grevink on 2014-11-29.
//  Copyright (c) 2014 David Grevink. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var buttonUpload: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerImage: UIPickerView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.progressView.setProgress(0.0, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    var counter:Int = 0 {
//        didSet {
//            let fractionalProgress = Float(counter) / 100.0
//            let animated = counter != 0
//            
//            progressView.setProgress(fractionalProgress, animated: animated)
//            progressLabel.text = ("\(counter)%")
//        }
//    }
    
    @IBAction func uploadButtonAction(sender: UIButton) {
        println("beginning upload...");
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let testFileURL1 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        
        let data = UIImageJPEGRepresentation(imageView.image, 0.5)
        data.writeToURL(testFileURL1!, atomically: true)

        uploadRequest1.bucket = "neuro-test-s3"
        uploadRequest1.key =  "tigre-\(getCurrentDateTime()).jpg"
        uploadRequest1.body = testFileURL1
        uploadRequest1.uploadProgress = { (bytesSent:Int64, totalBytesSent:Int64,  totalBytesExpectedToSend:Int64) -> Void in
            dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                self.progressView.setProgress(Float(totalBytesSent)/Float(totalBytesExpectedToSend), animated: true)
                println(Float(totalBytesSent)/Float(totalBytesExpectedToSend) * 100);
            })
        }
        
        let task = transferManager.upload(uploadRequest1)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                println("Error: \(task.error)")
            } else {
                println("Upload successful")
                self.progressView.setProgress(0.0, animated: false)
            }
            return nil
        }
    }
    
    func getCurrentDateTime() -> String {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter.stringFromDate(date)
    }

}

