//
//  UserTableViewController.swift
//  SnapIt
//
//  Created by Frank Staine-Pyne on 6/2/15.
//  Copyright (c) 2015 Nseatads. All rights reserved.
//

import UIKit



class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var userArray: [String] = []
    
    var recipient = 0
    
    var timer = NSTimer()
    
    @IBAction func picky(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            println("Button capture")
            
            var imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.Camera;
           // imag.mediaTypes = [kUTTypeImage]
            imag.allowsEditing = false
            
            self.presentViewController(imag, animated: true, completion: nil)
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        println("image selected")
        self.dismissViewControllerAnimated(true, completion: nil)
        
        var imageToSend = PFObject(className: "image")
        imageToSend["photo"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.25))
        imageToSend["sendUsername"] = PFUser.currentUser().username
        imageToSend["recipientUsername"] = userArray[recipient]
        imageToSend.saveInBackgroundWithBlock{
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                println("the image has been sent")
            } else {
                println("please try again ")
            }
        }
    }
    
        @IBAction func pickImage(sender: AnyObject) {
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        var query = PFUser.query()
        query.whereKey("sender", notEqualTo:PFUser.currentUser().username)
        var users = query.findObjects()
        
        for user in users{
            userArray.append(user.username)
            
            tableView.reloadData()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector: Selector ("checkForMessage"), userInfo:nil, repeats: true)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func checkForMessage() {
        var query = PFQuery(className: "image")
        query.whereKey("recipientUsername", equalTo:PFUser.currentUser().username)
        var images = query.findObjects()
        
        var done = false
        
        for image in images {
            if done == false {
                
                var imageView:PFImageView = PFImageView()
                imageView.file = image["photo"] as! PFFile
                imageView.loadInBackground({ (photo, error) -> Void in
                    
                    if error == nil {
                        
                        var sendUsername = ""
                        
                        if image["sendUsername"] != nil {
                            sendUsername = image["sendUsername"] as! NSString as String
                            
                        } else {
                            sendUsername = "unknown user"
                        }
                        
                        var alertView = UIAlertController(title: "Photo received", message: "Message from \(sendUsername)", preferredStyle: UIAlertControllerStyle.Alert)
                        alertView.addAction(UIAlertAction (title:"Ok", style:UIAlertActionStyle.Default, handler: {
                          (action) -> Void in
                       
                        var backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                        backgroundView.backgroundColor = UIColor.blackColor()
                        backgroundView.alpha = 0.8
                        backgroundView.tag = 3
                        backgroundView.addSubview(backgroundView)
                   
                        var displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                        displayedImage.image = photo
                        displayedImage.tag = 3
                        displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
                        self.view.addSubview(displayedImage)
                        image.delete()
                        
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target:self, selector: Selector ("hideMessage"), userInfo:nil, repeats: true)
                    
                         }))
                    }
            })
        
        }
        }
    }
    
    func hideMessage() {
        for subview in self.view.subviews {
            if subview.tag == 3 {
                subview.removeFromSuperview()
            }
            
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return t number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return userArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = userArray[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        recipient = indexPath.row
        pickImage(self)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logout" {
        
        PFUser.logOut()
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
