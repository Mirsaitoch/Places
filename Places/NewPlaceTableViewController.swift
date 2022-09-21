import UIKit

import Cosmos

class NewPlaceTableViewController: UITableViewController {
    
    var imageIsChanged = false
    
    var currentPlace: Place!
        
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var save: UIBarButtonItem!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var ImageOFPlace: UIImageView!
    @IBOutlet var cosmosView: CosmosView!
    @IBOutlet var mapButton: UIButton!
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            }
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        save.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
                
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)

        let largeBoldDoc =  UIImage(systemName: "map.circle", withConfiguration: largeConfig)
        
        mapButton.setImage(largeBoldDoc, for: .normal)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            
            let actionSheet = UIAlertController(title: nil , message: "choose where to upload the photo from", preferredStyle: .actionSheet)
            
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard
        let identifier = segue.identifier,
        let mapVC = segue.destination as? MapViewController
        else { return }
        
        mapVC.incomeIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        if identifier == "showMap"{
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text!
            mapVC.place.type = placeType.text!
            mapVC.place.imageData = placeImage.image?.pngData()
        }
    }
    func saveNewPlace(){
        let image = imageIsChanged ? placeImage.image :  #imageLiteral(resourceName: "imagePlaceholder")
        let imageData = image?.pngData()
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData,
                             rating: Double(ratingControl.rating))
        print(newPlace.rating)
        if currentPlace != nil {
            try! realm.write {
                print(newPlace.rating)
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.rating = newPlace.rating
                currentPlace?.imageData = newPlace.imageData
            }
        }
        else{
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
            ratingControl.rating = Int(currentPlace.rating)
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

extension NewPlaceTableViewController: MapViewControllerDelegate{
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
}
