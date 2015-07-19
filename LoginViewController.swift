//
//  LoginViewController.swift
//  ttshop
//
//  Created by Mac on 15-7-11.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

import UIKit
let serverUrl:String = "http://192.168.0.103:8080";


class LoginViewController: UIViewController,UIAlertViewDelegate,UITextFieldDelegate {
    
    @IBOutlet var userid: UITextField!
    @IBOutlet var passwd: UITextField!
    @IBOutlet var coverview: UIView!
    @IBAction func login(sender: UIButton) {
        var alert:UIAlertView! = UIAlertView(title: "信息", message: "", delegate: self, cancelButtonTitle: "Ok");
        if(userid.text != "" && passwd.text != ""){
            self.coverview.hidden = false;
            var req = NSMutableURLRequest(URL: NSURL(string: "\(serverUrl)/ttshop/user/loginajax.action")!);
            req.HTTPMethod = "POST";
            req.HTTPBody = NSString(string: "userid=\(userid.text)&password=\(passwd.text)").dataUsingEncoding(NSUTF8StringEncoding);
            NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue(), completionHandler: { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                self.coverview.hidden = true;
                if let err = error {
                    alert.message = "连接到服务器出错!";
                    alert.show();
                    return;
                }
                if let d = data {
                    var datastr = NSString(data: d, encoding: NSUTF8StringEncoding);
                    var errorrange = datastr?.rangeOfString("error:");
                    var successrange = datastr?.rangeOfString("success:");
                    if(errorrange?.length>0){
                        alert.message = datastr!.stringByReplacingCharactersInRange(errorrange!, withString: "");
                        alert.show();
                        return;
                    }else if(successrange?.length>0){
                        self.performSegueWithIdentifier("login", sender: self);
                    }
                }
            })
        }
    }
    override func viewDidLoad() {
        userid.delegate = self;
        passwd.delegate = self;
        self.view.bringSubviewToFront(coverview);
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        view.endEditing(true);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        userid.resignFirstResponder();
        passwd.resignFirstResponder();
        return true;
    }
    
    
}
