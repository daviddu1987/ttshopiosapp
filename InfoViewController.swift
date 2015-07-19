//
//  InfoViewController.swift
//  ttshop
//
//  Created by Mac on 15-7-9.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate{
    var scancontent:String = "";
    let tosegue:String = "infosegue";
    var typelistid:[String] = [];
    var typelistname:[String] = [];
    @IBOutlet var barcode: UITextField!
    @IBOutlet var productname: UITextField!
    @IBOutlet var brand: UITextField!
    @IBOutlet var color: UITextField!
    @IBOutlet var sprice: UITextField!
    @IBOutlet var mprice: UITextField!
    @IBOutlet var introduction: UITextField!
    @IBOutlet var picker: UIPickerView!
    @IBOutlet var typetext: UITextField!
    @IBOutlet var typeview: UIView!
    @IBOutlet var coverview: UIView!

    @IBAction func choose(sender: UITextField) {
        typetext.resignFirstResponder();
        self.view.bringSubviewToFront(typeview);
        typeview.hidden = false;
        self.view.endEditing(true);
    }
    @IBAction func choosewhenchange(sender: AnyObject) {
        typetext.resignFirstResponder();
        self.view.bringSubviewToFront(typeview);
        typeview.hidden = false;
        self.view.endEditing(true);
    }
    
    @IBAction func chooseok(sender: AnyObject) {
        typeview.hidden = true;
        self.view.endEditing(true);
        var index = picker.selectedRowInComponent(0);
        typetext.text = typelistname[index];
    }
    
    @IBAction func comfirm(sender: UIButton) {
        var alert:UIAlertView = UIAlertView(title: "消息", message: "", delegate: self, cancelButtonTitle: "OK");
        var index = picker.selectedRowInComponent(0);
        var type = typelistid[index];
        var bar = barcode.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet());
        var pname = productname.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet());
        var bra = brand.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet());
        var col = color.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet());
        var spr = sprice.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet());
        var mpr = mprice.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet());
        var intro = introduction.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet());
        if(bar==""){
            alert.message = "产品编码不能为空!";
            alert.show();
            return;
        }
        if(pname==""){
            alert.message = "产品名称不能为空!";
            alert.show();
            return;
        }
        if(spr=="") {
            spr = "0.0";
        }
        if(mpr=="") {
            mpr = "0.0";
        }
        if(intro=="") {
            intro = "这家伙很懒,什么都没有写";
        }
        var req = NSMutableURLRequest(URL: NSURL(string: "\(serverUrl)/ttshop/productinfo/addproductinfoAjax.action")!);
        req.HTTPMethod = "POST";
        req.HTTPBody = NSString(string: "barcode=\(bar)&ptype=\(type)&pdesc=\(pname)&pbrand=\(bra)&pcolor=\(col)&sprice=\(spr)&mprice=\(mpr)&introduction=\(intro)").dataUsingEncoding(NSUTF8StringEncoding);
        self.view.bringSubviewToFront(coverview);
        self.coverview.hidden = false;
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) { (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
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
                    alert.message = datastr!.stringByReplacingCharactersInRange(successrange!, withString: "");
                    alert.show();
                    self.resettextfield();
                }
            }
        }
    }
    
    @IBAction func gotoscan(sender: UIBarButtonItem) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barcode.delegate = self;
        productname.delegate = self;
        brand.delegate = self;
        color.delegate = self;
        sprice.delegate = self;
        mprice.delegate = self;
        introduction.delegate = self;
        typetext.delegate = self;
        picker.dataSource = self;
        picker.delegate = self;
        var req = NSURLRequest(URL:NSURL(string: "\(serverUrl)/ttshop/ptype/listptypeAjax.action")!);
        self.view.bringSubviewToFront(coverview);
        self.coverview.hidden = false;
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue()) { (response:NSURLResponse!, d:NSData!, error:NSError!) -> Void in
            self.coverview.hidden = true;
            if let data = d {
                var json = JSON(data:data);
                for (index:String,subjson:JSON) in json {
                    var id = subjson["id"];
                    var name = subjson["typeName"];
                    self.typelistid.append("\(id)");
                    self.typelistname.append("\(name)");
                }
                self.typetext.text = self.typelistname[0];
                self.picker.reloadComponent(0);
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var duc = segue.destinationViewController as ScanViewController;
        duc.formsegue = self.tosegue;
    }
    
    @IBAction func unwin(segue:UIStoryboardSegue) {
        var svc = segue.sourceViewController as ScanViewController;
        self.scancontent = svc.scancontent!;
        self.barcode.text = self.scancontent;
    }
    
    func resetkeyboard(){
          view.endEditing(true);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        resetkeyboard();
        return true;
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if(textField.tag==7){
            typetext.resignFirstResponder();
            self.view.bringSubviewToFront(typeview);
            typeview.hidden = false;
            self.view.endEditing(true);
            return false;
        }else{
            return true;
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.typelistname.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.typelistname[row];
    }
    
    //#mark 自定义 pickerview lable
//    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
//        var pickerLabel:UILabel = UILabel();
//        pickerLabel.adjustsFontSizeToFitWidth = true;
//        pickerLabel.font = UIFont(name: "hello", size: 13);
//        pickerLabel.text = typelistname[row];
//        return pickerLabel;
//    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        view.endEditing(true);
    }
    
    func resettextfield() {
        barcode.text = "";
        productname.text = "";
        brand.text = "";
        color.text = "";
        sprice.text = "1.0";
        mprice.text = "1.0";
        introduction.text = "";
        typetext.text = typelistname[0];
    }
    
    
    
}
