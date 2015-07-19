//
//  SaleViewController.swift
//  ttshop
//
//  Created by Mac on 15-7-12.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

import UIKit

class Saleproduct {
    var barcode:String;
    var desc:String;
    var price:Double;
    var quantity:Int;
    
    init(barcode:String,desc:String,price:Double,quantity:Int){
        self.barcode = barcode;
        self.desc = desc;
        self.price = price;
        self.quantity = quantity;
    }
}
var datasource:[Saleproduct] = [];

class SaleViewController:UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate {
    let tosegue:String! = "salesegue";
    var barcodes:[String] = [];
    var invoice:String = "";
    var actionsheet:UIActionSheet?;
    @IBOutlet var addItem: UIBarButtonItem!
    @IBOutlet var loadinglable: UILabel!
    @IBOutlet var loadingview: UIView!
    @IBOutlet var loading: UIActivityIndicatorView!
    @IBOutlet var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.dataSource = self;
        self.tableview.delegate = self;
        if(datasource.isEmpty){
            loadingview.hidden = false;
            loading.hidden = true;
            loadinglable.text = "没有数据,点击右上角'扫码'读取商品条码";
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func addProduct(sender: UIBarButtonItem) {
        actionsheet = UIActionSheet(title: "你想通过什么方式添加?", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "扫码添加", otherButtonTitles: "搜索添加");
        actionsheet?.actionSheetStyle = UIActionSheetStyle.BlackTranslucent;
        actionsheet?.showFromBarButtonItem(addItem,animated: true);
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        //println(buttonIndex);
        //canclebutton ==1 scanviewbutton == 0 searchviewbutton = 2
        if(buttonIndex==0){
            self.performSegueWithIdentifier("goformsaleview", sender: self);
        }else if(buttonIndex==2){
            self.performSegueWithIdentifier("searchsegue", sender: self);
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier=="goformsaleview"){
            var duc = segue.destinationViewController as ScanViewController;
            duc.formsegue = self.tosegue;
            duc.barcodes = [];
            //datasource = [];
        }else if(segue.identifier=="invoicesegue"){
            var iuc = segue.destinationViewController as InvoiceViewController;
            iuc.invoice = self.invoice;
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableview.dequeueReusableCellWithIdentifier("productcell") as UITableViewCell;
        loadcontent(cell, indexpath: indexPath);
        return cell;
    }
    
    func loadcontent(cell:UITableViewCell, indexpath:NSIndexPath) {
        if(!datasource.isEmpty) {
            var index = indexpath.row;
            var label = cell.viewWithTag(1) as UILabel;
            var price = cell.viewWithTag(2) as UITextField;
            var quantity = cell.viewWithTag(3) as UITextField;
            price.delegate = self;
            quantity.delegate = self;
            label.text = "\(index+1) . \(datasource[index].desc) - \(datasource[index].barcode)";
            price.text = "\(datasource[index].price)";
            quantity.text = "\(datasource[index].quantity)";
        }
    }
    
    //#mark - create a deal by ajax
    @IBAction func createsale(sender: UIBarButtonItem) {
        self.loadingview.hidden = false;
        self.loading.hidden = false;
        self.loadinglable.text = "数据提交中...";
        var bodystring = "";
        for ds in datasource {
            bodystring += "&barcodes=\(ds.barcode)&quantitys=\(ds.quantity)&prices=\(ds.price)";
        }
        var alert = UIAlertView(title: "消息", message: "", delegate:  self, cancelButtonTitle: "OK");
        var req = NSMutableURLRequest(URL: NSURL(string: "\(serverUrl)/ttshop/retialinterface/creaetadealbyphone.action?token=0")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 60);
        req.HTTPMethod = "POST";
        req.HTTPBody = NSString(string:"\(bodystring)").dataUsingEncoding(NSUTF8StringEncoding);
        var d = NSURLConnection.sendSynchronousRequest(req, returningResponse:nil, error:nil);
        if let data = d {
            var datastr = NSString(data:data, encoding: NSUTF8StringEncoding);
            var errorrange = datastr?.rangeOfString("error:");
            var successrange = datastr?.rangeOfString("success:");
            if(errorrange!.length > 0 ){
            alert.message = datastr?.stringByReplacingCharactersInRange(errorrange!, withString: "");
            alert.show();
            self.loading.hidden = true;
            self.loadinglable.text = datastr?.stringByReplacingCharactersInRange(errorrange!, withString: "");
            return;
            }
            if(successrange!.length > 0){
            var invoiceno = datastr?.stringByReplacingCharactersInRange(successrange!, withString: "");
            self.invoice = invoiceno!;
            self.performSegueWithIdentifier("invoicesegue", sender: self);
            self.loadingview.hidden = true;
            }
        }else{
            alert.message = "连接服务器出错!";
            alert.show();
        }
    }
    
    //#mark - deal the info from scanview
    func sortbarcodes(barcodes:[String]){
        var bodyString:String = "";
        if(!barcodes.isEmpty){
            println("sort");
            self.loadingview.hidden = false;
            self.loading.hidden = false;
            self.loadinglable.text = "数据加载中...";
            for str in barcodes {
                bodyString += "&barcodes=\(str)";
            }
            var req = NSMutableURLRequest(URL: NSURL(string: "\(serverUrl)/ttshop/retialinterface/prepareForDeal.action")!);
            req.HTTPMethod = "POST";
            req.HTTPBody = NSString(string: "\(bodyString)").dataUsingEncoding(NSUTF8StringEncoding);
            NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue(), completionHandler: { (respeonse:NSURLResponse!, d:NSData!, error:NSError!) -> Void in
                var alert = UIAlertView(title: "错误信息", message: "", delegate:self, cancelButtonTitle: "OK");
                if let err = error {
                    alert.message = "连接到服务器出错!";
                    alert.show();
                    return;
                }
                if let d1 = d {
                    var datastr = NSString(data: d, encoding: NSUTF8StringEncoding);
                    var errorrange = datastr?.rangeOfString("error:");
                    if(errorrange?.length>0){
                        alert.message = datastr!.stringByReplacingCharactersInRange(errorrange!, withString: "");
                        alert.show();
                        return;
                    }else{
                        var json = JSON(data:d1);
                        for (index:String,subjson:JSON) in json {
                            var flag = true;
                            var barcode = subjson["barcode"];
                            var desc = subjson["pdesc"];
                            var pri = subjson["price"];
                            var q = subjson["quantity"];
                            var quantity:Int! = NSString(string: "\(q)").integerValue;
                            var price:Double! = NSString(string: "\(pri)").doubleValue;
                            for  dp in datasource {
                                if(equal(dp.barcode, "\(barcode)")){
                                    dp.quantity += quantity;
                                    flag = false;
                                    continue;
                                }
                            }
                            if(flag){
                                var p = Saleproduct(barcode: "\(barcode)", desc: "\(desc)", price: price, quantity:quantity
                                )
                                datasource.append(p);
                            }
                        self.barcodes = [];
                        self.tableview.reloadData();
                        self.loadingview.hidden = true;
                        }
                    }
               }
            })
        }
    }
    
    @IBAction func unwindforminvoiceview(segue:UIStoryboardSegue){
        //must clear datasource
        var invoiceuc = segue.sourceViewController as InvoiceViewController;
        datasource = [];
        if(datasource.isEmpty){
            loadingview.hidden = false;
            loading.hidden = true;
            loadinglable.text = "没有数据,点击右上角'扫码'读取商品条码";
        }
        self.tableview.reloadData();
        //self.viewDidLoad();
    }
    
    
    @IBAction func unwindFormScanview(segue:UIStoryboardSegue){
        //catch barcodes info form scanview;
        //var scanuc = segue.sourceViewController as ScanViewController;
        //scanuc.barcodes = self.barcodes;
        self.sortbarcodes(barcodes);
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
         view.endEditing(true);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true);
        return true;
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        datasource.removeAtIndex(indexPath.row);
        self.tableview.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic);
    }
    
}
