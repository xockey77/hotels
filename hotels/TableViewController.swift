//
//  TableViewController.swift
//  hotels
//
//  Created by username on 20.12.2021.
//

import UIKit
import Alamofire

enum sortType {
    case distance
    case suitesAvailable
}

class TableViewController: UITableViewController {

    var isLoading = true
    var hotels: [Hotel] = []
    var sorting: sortType?
    
    struct TableView {
        struct CellIdentifiers {
            static let hotelCell = "HotelCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cellNib = UINib(nibName: TableView.CellIdentifiers.hotelCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.hotelCell)
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        fetchHotels()
        self.clearsSelectionOnViewWillAppear = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else {
            return hotels.count
        }
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.hotelCell, for: indexPath) as! HotelCell
            let hotel = hotels[indexPath.row]
            cell.configure(for: hotel)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if isLoading {
            return nil
        }
        else {
            return indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let hotel = hotels[indexPath.row]
            detailViewController.hotel = hotel
        }
    }

    @IBAction func sortTable(_ sender: Any) {
        
        if sorting == nil { sorting = .distance }
        switch sorting {
            case .distance:
                sorting = .suitesAvailable
                hotels.sort{ $0.suitesCount! < $1.suitesCount! }
                tableView.reloadData()
                break
            case .suitesAvailable:
                sorting = .distance
                hotels.sort{ $0.distance < $1.distance }
                tableView.reloadData()
                break
            default:
                break
        }
    }
}

extension TableViewController {
    func fetchHotels() {
        AF.request(URLS.hotelsURL)
            .validate()
            .responseDecodable(of: [Hotel].self) { (response) in
                guard let data = response.value else { return }
                self.hotels = data
                for (index, hotel) in self.hotels.enumerated() {
                    let suites = hotel.suites_availability.components(separatedBy: ":").filter { $0 != "" }
                    self.hotels[index].suitesCount = suites.count
                }
                self.isLoading = false
                self.tableView.reloadData()
        }
    }
}
