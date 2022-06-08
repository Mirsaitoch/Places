import UIKit

import Cosmos

class NewPlaceTableViewController: UITableViewController {
    
    var imageIsChanged = false
    
    var currentPlace: Place!
    
    var currentRating = 0.0
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var save: UIBarButtonItem!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var ImageOFPlace: UIImageView!
    @IBOutlet var cosmosView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        save.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()

        cosmosView.settings.fillMode = .half
        cosmosView.didTouchCosmos = {rating in
            self.currentRating  = rating}
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default){_ in
                self.chooseImage(source: .camera)
            }
            let photo = UIAlertAction(title: "Photo", style: .default){ _ in
                self.chooseImage(source: .photoLibrary)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        }
        else{
            view.endEditing(true)
        }
    }
    func saveNewPlace(){
        var image: UIImage?
//        print("git test")

        if imageIsChanged{
            image = placeImage.image
        }else{
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData,
                             rating: currentRating)
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace.rating = newPlace.rating
                print("qqqqqqqqqq")
                print(newPlace.rating)
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditScreen(){
        if currentPlace != nil{
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}

            navigationItem.leftBarButtonItem = nil
            save.isEnabled = true
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFit
            placeName.text = currentPlace?.name
            placeType.text = currentPlace?.type
            placeLocation.text = currentPlace?.location
            cosmosView?.rating = currentPlace.rating
            print("ergergergergergerger")
            print(currentPlace.rating)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
}



extension NewPlaceTableViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged(){
        if placeName.text?.isEmpty == false{
            save.isEnabled = true
        }
        else{
            save.isEnabled = false
        }
    }
    
    
}

extension NewPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func chooseImage(source: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ImageOFPlace.image = info[.editedImage] as? UIImage
        ImageOFPlace.contentMode = .scaleAspectFill
        ImageOFPlace.clipsToBounds = true
        imageIsChanged = true

        dismiss(animated: true)
    }
    
}


