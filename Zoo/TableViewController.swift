//
//  TableViewController.swift
//  Zoo
//
//  Created by Warren Wang on 7/3/17.
//  Copyright © 2017 Warren Wang. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UIViewController
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var lat: Double?
    var long: Double?
    //var selectedImageTag: Int? = 0
    
    
    
    @IBOutlet weak var imageView: UIImageView!
   // @IBOutlet weak var currentTitle: UILabel!
    
    
    var currentPin: coordinatePin!
    
   let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestures()
        fetchData()
        print(currentPin.new)

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var pinTitle: UITextField!
  
    @IBOutlet weak var pinSubtitle: UITextField!

    
    
    @IBAction func saveChanges(_ sender: Any) {
        //calls dismiss keyboard
      //  let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TableViewController.dismissKeyboard))
        
        dismissKeyboard()
        
        print(currentPin!.new)
        if currentPin!.new == false
        {
            print("Editing an old pin")
            //get all pins
             let entityDescription = NSEntityDescription.entity(forEntityName: "Coord", in: managedObjectContext)
            let request: NSFetchRequest = Coord.fetchRequest()
            request.entity = entityDescription
            // only use pin with right id
            let pred = NSPredicate(format: "(pinid = %@)", currentPin.pinID)
            request.predicate = pred
            
            do {
                var results = try managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
                
                if results.count > 0
                {
                    let resultData = results as! [Coord]
                    print("I found this many results: " + String(results.count))
                    resultData[0].title = pinTitle.text!
                    resultData[0].descrip = pinSubtitle.text!
                }
                else
                {
                    print("didnt find any pins matching the clicked pin")
                }
                
            }catch let error
            {
                print(error.localizedDescription);
            }
            
           
        }
        
        else
        {
        

        let entityDescription = NSEntityDescription.entity(forEntityName: "Coord", in: managedObjectContext)

        let photo = (Coord(entity: entityDescription!, insertInto: managedObjectContext))

            
        /*
        if !(pinTitle.text! == nil) && !(pinSubtitle.text == nil)
        {
             photo.title = pinTitle.text
            photo.descrip = pinSubtitle.text!
        }
       else if !(pinTitle.text! == nil)
        {
            photo.title = pinTitle.text
            
            }
        else if !(pinSubtitle.text == nil)
            {
                photo.descrip = pinSubtitle.text!

            }
        */
            if let tempTitle: String = pinTitle.text!
            {
                photo.title = tempTitle
            }
            else{
                photo.title = "pin "
            }
            
            if let tempSubTitle: String = pinSubtitle.text!
            {
                photo.descrip = tempSubTitle
            }
        
        photo.long = long!
        photo.lat = lat!
        photo.pinid = currentPin.pinID
        
        print(photo.title!)
         //   currentPin.new = false

        }
        /* MIGHT NEED THIS
        if (pinTitle.text != nil) && (pinSubtitle.text != nil)         {
            currentPin.name = pinTitle.text!
            currentTitle.text = pinTitle.text
            currentPin.notes = pinSubtitle.text!

        }
        else if(pinTitle.text != nil)
        {
            currentPin.name = pinTitle.text!
            currentTitle.text = pinTitle.text
        }
        else if pinSubtitle.text != nil{
            currentPin.notes = pinSubtitle.text!
        }
        */
        
        print(currentPin.new)
    }
    
    //dismiss keyboard
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
   
    func addTapGestures() {
        let tapGR0 = UITapGestureRecognizer(target: self, action: #selector(tappedImage))
        imageView.addGestureRecognizer(tapGR0)
       // imageView.tag = 1
    }
    
    
    
    @IBAction func openCamera(_ sender: Any) {
        tappedImage()
    }
    
    func fetchData() {
        // Set up fetch request
        let container = appDelegate.persistentContainer
        print(container)
        let context = container.viewContext
        print(context)
        let fetchRequest = NSFetchRequest<Image>(entityName: "Image")
        
        do {
            // Retrive array of all image entities in core data
            let images = try context.fetch(fetchRequest)
            
            // For each image entity get the imageData from filepath and assign it to image view
            for image in images {
                
                if let filePath = image.filePath {
                    
                    // Retrive image data from filepath and convert it to UIImage
                    if FileManager.default.fileExists(atPath: filePath) {
                        
                        if let contentsOfFilePath = UIImage(contentsOfFile: filePath) {
                            
                             imageView.image = contentsOfFilePath
                        
                        }
                    }
                }
            }
        } catch {
            print("entered catch for image fetch request")
        }
    }


    
}




extension TableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    func tappedImage() {
            // Make sure device has a camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                // Save tag of image view we selected
               // if let view = sender.view {
                //    selectedImageTag = view.tag
               // }
                
                // Setup and present default Camera View Controller
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            //save photo?
            //let imageData = UIImageJPEGRepresentation(imageView.image!, 0.6)
            //let compressedJPEGImage = UIImage(data: imageData!)
            //UIImageWriteToSavedPhotosAlbum(compressedJPEGImage!, nil, nil, nil)
            }
    }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            // Dismiss the view controller a
            picker.dismiss(animated: true, completion: nil)
            // Get the picture we took THIS IS HUGE!
              let image = info[UIImagePickerControllerOriginalImage] as! UIImage

                // Set the picture to be the image of the selected UIImageView
            //this is not abig deal for yuou
            //switch selectedImageTag {
                imageView.image = image

            //default: break
            // Save imageData to filePath
            // Get access to shared instance of the file manager
            let fileManager = FileManager.default
            print(fileManager)
            // Get the URL for the users home directory
            let documentsURL =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            print(documentsURL)
            // Get the document URL as a string
            let documentPath = documentsURL.path
            print(documentPath)
            // Create filePath URL by appending final path component (name of image)
            let filePath = documentsURL.appendingPathComponent("\(String(currentPin.pinID)).png")
            // Check for existing image data
            do {
                // Look through array of files in documentDirectory
                let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                
                for file in files {
                    // If we find existing image filePath delete it to make way for new imageData
                    if "\(documentPath)/\(file)" == filePath.path {
                        try fileManager.removeItem(atPath: filePath.path)
    }
    }
    } catch {
                print("Could not add image from document directory: \(error)")
            }
            // Create imageData and write to filePath
    do {
    if let pngImageData = UIImagePNGRepresentation(image) {
                    try pngImageData.write(to: filePath, options: .atomic)
                }
    } catch {
                print("couldn't write image")
    }
    
            // Save filePath and imagePlacement to CoreData
            let container = appDelegate.persistentContainer
            let context = container.viewContext
            let entity = Image(context: context)
            entity.filePath = filePath.path
    
           // switch selectedImageTag {
           // case 1: entity.placement = "top"
           // default:
            // break
 
            appDelegate.saveContext()
            let imageData = UIImageJPEGRepresentation(imageView.image!, 0.6)
            let compressedJPEGImage = UIImage(data: imageData!)
            UIImageWriteToSavedPhotosAlbum(compressedJPEGImage!, nil, nil, nil)
    //}
}

}

    
    

   
    

// make a save button that is an action that changes the label to pinTitle
