//
//  ViewController.swift
//  SeeFoodWatson
//
//  Created by Pierre-Luc Bruyere on 2018-10-24.
//  Copyright © 2018 Pierre-Luc Bruyere. All rights reserved.
//

import UIKit
import VisualRecognition
import SVProgressHUD
import Social


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
  // MARK: - Attributes

  @IBOutlet weak var cameraButton: UIBarButtonItem!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var libraryButton: UIBarButtonItem!
  @IBOutlet weak var statusImageView: UIImageView!
  @IBOutlet weak var shareButton: UIButton!

  let imagePicker = UIImagePickerController()


  let apiKey = ""
  let version = "2018-10-24"

  var classificationResults = [String]()

  // MARK: -

  override func viewDidLoad()
  {
    super.viewDidLoad()

    imagePicker.delegate = self
  }

  // MARK: - Image Picker Delegate

  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
  {
    navigationItem.title = ""
    classificationResults.removeAll()
    cameraButton.isEnabled = false
    libraryButton.isEnabled = false

    SVProgressHUD.show()

    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
    {
      imageView.image = image
      imagePicker.dismiss(animated: true, completion: nil)
      statusImageView.isHidden = false

      let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)

      let imageData = image.jpegData(compressionQuality: 0.01)
      let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
      try? imageData?.write(to: fileURL)

      visualRecognition.classify(imagesFile: fileURL, url: nil, threshold: nil, owners: nil, classifierIDs: nil, acceptLanguage: nil, headers: nil, failure: nil, success:
      { (classifiedImages) in

        if let classes = classifiedImages.images.first?.classifiers.first?.classes
        {
          for classImage in classes
          {
            self.classificationResults.append(classImage.className)
          }

          DispatchQueue.main.async
          {
            self.cameraButton.isEnabled = true
            self.libraryButton.isEnabled = true
            self.shareButton.isHidden = false
            SVProgressHUD.dismiss()
          }

          if self.classificationResults.contains("hotdog")
          {
            DispatchQueue.main.async
            {
              self.navigationItem.title = "Hot dog !!"
              self.navigationController?.navigationBar.barTintColor = UIColor.green
              self.navigationController?.navigationBar.isTranslucent = false
              self.statusImageView.image = UIImage(named: "success.png")
              self.statusImageView.isHidden = false
            }
          }
          else
          {
            DispatchQueue.main.async
            {
              self.navigationItem.title = "Not Hot dog ??"
              self.navigationController?.navigationBar.barTintColor = UIColor.red
              self.navigationController?.navigationBar.isTranslucent = false
              self.statusImageView.image = UIImage(named: "error.png")
              self.statusImageView.isHidden = false
            }
          }
        }
      })
    }
  }

  // MARK: - Navigation bar actions

  @IBAction func libraryTapped(_ sender: UIBarButtonItem)
  {
    // To run on the simulator, we can't use the camera
    imagePicker.sourceType = .savedPhotosAlbum
    imagePicker.allowsEditing = false

    present(imagePicker, animated: true, completion: nil)
  }

  @IBAction func cameraTapped(_ sender: UIBarButtonItem)
  {
    // To run on the simulator, we can't use the camera
    imagePicker.sourceType = .camera
    imagePicker.allowsEditing = false

    present(imagePicker, animated: true, completion: nil)
  }

  @IBAction func shareTapped(_ sender: UIButton)
  {
    // Deprecated in IOS 11.0
/*    if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)
    {
      let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
    }
*/  }
}

