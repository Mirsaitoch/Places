import UIKit
import RealmSwift
import Cosmos

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var reversedSort: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            }
        places = realm.objects(Place.self)
        searchControoller.searchResultsUpdater = self
        searchControoller.obscuresBackgroundDuringPresentation = false
        searchControoller.searchBar.placeholder = "Search"
        navigationItem.searchController = searchControoller
        definesPresentationContext = true
    }
    
    private let searchControoller = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool{
        guard let text = searchControoller.searchBar.text else { return false}
        return text.isEmpty
    }
    private var isFiltring: Bool{
        if searchControoller.isActive && searchControoller.searchBar.text?.isEmpty != true{
            return true
        }
        else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltring{
            return filteredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        var place = Place()
        
        if isFiltring{
            place = filteredPlaces[indexPath.row]
        }
        else{
            place = places[indexPath.row]

        }
        cell.cosmosView.settings.fillMode = .half
        cell.cosmosView.rating = place.rating
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place: Place
            if isFiltring {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            let newPlaceVC = segue.destination as! NewPlaceTableViewController
            newPlaceVC.currentPlace = place
        }
    }

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        guard let newPlaceVC = segue.source as? NewPlaceTableViewController else {return}
        newPlaceVC.saveNewPlace()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        ascendingSorting.toggle()
        if ascendingSorting == true{
            reversedSort.image = #imageLiteral(resourceName: "AZ")
        }
        else{
            reversedSort.image = #imageLiteral(resourceName: "ZA")
        }
        sorting()
    }
    private func sorting(){
        if segmentedControl.selectedSegmentIndex == 0{
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        }
        else{
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
}
extension TableViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String){
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}
