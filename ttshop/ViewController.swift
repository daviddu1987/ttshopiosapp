//
//  ViewController.swift
//  ttshop
//
//  Created by Mac on 15-6-22.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

import UIKit




class ViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var wv: UIWebView!;
    var ptimer:NSTimer!;
    @IBOutlet var bar: UIProgressView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wv.delegate = self;
        //bar.progress = 0;
        //ptimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("loadprogress"), userInfo: nil, repeats: true);
        wv.loadRequest(NSURLRequest(URL:NSURL(string:"\(serverUrl)/ttshop/main.jsp")!))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadprogress(){
        if(bar.progress >= 1.0){
            //ptimer.invalidate();
            //bar.progress = 0;
        }else{
            bar.setProgress(bar.progress + 0.2, animated: true);
        }
    }
    
    func webView(webview: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        return true;
    }
    func webViewDidStartLoad(webview: UIWebView){
        bar.setProgress(0, animated: false);
    }
    func webViewDidFinishLoad(webview: UIWebView){
        bar.setProgress(1.0, animated: true);
    }
    

    
}

