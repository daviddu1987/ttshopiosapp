//
//  InvoiceViewController.swift
//  ttshop
//
//  Created by Mac on 15-7-16.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

import UIKit

class InvoiceViewController: UIViewController,UIWebViewDelegate {
    
    var invoice:String = "";
     
    @IBOutlet var loading: UIView!
    @IBOutlet var uv: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uv.delegate = self;
        var url = NSURL(string: "\(serverUrl)/ttshop/retialinterface/loadinvoice.action?invoice_no=\(invoice)");
        var req = NSURLRequest(URL:url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 30);
        uv.loadRequest(req);
        datasource = [];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.loading.hidden = false;
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.loading.hidden = true;
    }
    
}
