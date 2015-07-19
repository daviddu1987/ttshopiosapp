//
//  ScanViewController.swift
//  code
//
//  Created by Mac on 15-7-9.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ScanViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,UITextViewDelegate{
    var scancontent:String? = "";
    var barcodes:[String] = [];
    let types:[String] = [AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code];
    var session:AVCaptureSession?;
    var layer:AVCaptureVideoPreviewLayer?;
    var scanview: UIView?;
    var alert:UIAlertView!;
    var animatestate = true;
    var formsegue:String! = "";
    var soundid:SystemSoundID = 1114;
    
    @IBOutlet var comfirmbutton: UIButton!
    @IBOutlet var linebottom: NSLayoutConstraint!
    @IBOutlet var line: UIView!
    @IBOutlet var border: UIView!
    @IBOutlet var barcodesview: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barcodesview.delegate = self;
        initall();
        initlayer();
        initborder();
        if(formsegue=="infosegue") {
            alert = UIAlertView(title: "条型码", message: "", delegate: self, cancelButtonTitle: "添加产品");
            alert.delegate = self;
        }else{
            alert = UIAlertView(title: "条形码", message: "", delegate: self, cancelButtonTitle: "开单", otherButtonTitles: "继续", "取消");
            alert.delegate = self;
            self.barcodesview.hidden = false;
            self.comfirmbutton.hidden = false;
            self.view.bringSubviewToFront(barcodesview);
            self.view.bringSubviewToFront(comfirmbutton);
            self.barcodesview.layoutIfNeeded();
        }
        session?.startRunning();
        linebottom.constant = 300;
        self.line.layoutIfNeeded();
        self.linemove();
        view.bringSubviewToFront(line);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
//        if (metadataObjects != nil || metadataObjects.count == 0 ) {
//            scanview?.frame = CGRectZero;
//            scancontent = "没有任何扫描结果";
//            //alert.message = scancontent;
//            //alert.show();
//            //session?.stopRunning();
//            return;
//        }
        let metaobj = metadataObjects[0] as AVMetadataMachineReadableCodeObject;
        
        if contains(types, metaobj.type) {
            //获取到值时显示绿色框
            playsound();
            let barcodeobj = layer?.transformedMetadataObjectForMetadataObject(metaobj as AVMetadataMachineReadableCodeObject) as AVMetadataMachineReadableCodeObject;
            scanview?.frame = barcodeobj.bounds;
            //获取 value
            if(metaobj.stringValue != nil ){
                scancontent = metaobj.stringValue;
                barcodes.append(scancontent!);
                alert.message = "读取的条码为:\(scancontent!)";
                alert.show();
                session?.stopRunning();
                animatestate = false;
            }
        }
    }
    
    //init the canmer
    func initall(){
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        var error:NSError?;
        let input:AVCaptureInput? = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error) as? AVCaptureInput;
        if(error != nil){
            var alertview = UIAlertView(title: "错误信息", message: "", delegate: self, cancelButtonTitle: "OK");
            alertview.message = "初始化相机出错!\(error)";
            alertview.show();
            return;
        }
        session = AVCaptureSession();
        session?.addInput(input);
        
        let capturedataoutput = AVCaptureMetadataOutput();
        session?.addOutput(capturedataoutput);
        
        capturedataoutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue());
        capturedataoutput.metadataObjectTypes = types;
        
    }
    
    func initborder(){
        scanview = UIView();
        scanview?.layer.borderColor = UIColor.greenColor().CGColor;
        scanview?.layer.borderWidth = 2;
        view.addSubview(scanview!);
        border?.layer.borderColor = UIColor.greenColor().CGColor;
        border?.layer.borderWidth = 2;
        view.bringSubviewToFront(border!);
        view.bringSubviewToFront(scanview!);
    }
    
    //init the scanview
    func initlayer(){
        layer = AVCaptureVideoPreviewLayer(session: session);
        layer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
        layer?.frame = view.layer.bounds;
        view.layer.addSublayer(layer);
    }
    

    
    func linemove(){
        if(animatestate){
            self.line.layer.hidden = false;
            view.layoutSubviews();
            self.linebottom.constant = 300;
            self.line.layoutIfNeeded();
            UIView.animateWithDuration(1.5, delay: 0, options: nil, animations: {
                self.linebottom.constant = 0;
                self.line.layoutIfNeeded();
            }, completion: { (finished) -> Void in
                self.linemove();
            })
        }else{
            self.line.layer.hidden = true;
            view.layoutSubviews();
            //self.linebottom.constant = 300;
            //self.line.layoutIfNeeded();
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(alertView.title=="错误信息"){
            if(formsegue=="infosegue"){
                self.performSegueWithIdentifier("gotoinfoview", sender: self);
            }else{
                self.performSegueWithIdentifier("gotosaleview", sender: self);
            }
        }
        if(buttonIndex==0){
            if(formsegue=="infosegue"){
                self.performSegueWithIdentifier("gotoinfoview", sender: self);
            }else{
                self.performSegueWithIdentifier("gotosaleview", sender: self);
            }
        }else if(buttonIndex==1){
            barcodesview.text = "\(barcodesview.text) \(scancontent!),";
            session?.startRunning();
            animatestate = true;
            linemove();
        }else if(buttonIndex==2){
            barcodes.removeLast();
            session?.startRunning();
            animatestate = true;
            linemove();
        }
    }
    
    @IBAction func kaidan(sender: AnyObject) {
        self.performSegueWithIdentifier("gotosaleview", sender: self);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //used unwin method to instead
        if(segue.identifier=="gotosaleview"){
            //send read barcodes to saleviewcontroller
            var saleuc = segue.destinationViewController as SaleViewController;
            saleuc.barcodes = self.barcodes;
        }
    }
    
    func playsound(){
        AudioServicesPlaySystemSound(soundid);
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return false;
    }
    
}
