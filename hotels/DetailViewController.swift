//
//  DetailViewController.swift
//  hotels
//
//  Created by username on 20.12.2021.
//

import UIKit
import Alamofire
import MapKit

class DetailViewController: UIViewController {
    var hotel: Hotel = Hotel()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var suitesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        var hotelDetailInfo: Hotel = hotel
        super.viewDidLoad()
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemBackground.cgColor
        imageView.image = UIImage(systemName: "photo")
        nameLabel.text = hotel.name
        starsLabel.text = String(repeating: "★", count: Int(hotel.stars))
        addressLabel.text = hotel.address
        distanceLabel.text = String(format: "%.0f", hotel.distance) + " м от центра"
        let suites = hotel.suites_availability.components(separatedBy: ":").filter { $0 != "" }
        suitesLabel.text = "\(suites.count) номеров свободно"
        let url = URLS.hotelInfoBaseURL + "\(hotel.id)" + ".json"
        AF.request(url)
            .validate()
            .responseDecodable(of: Hotel.self) { (response) in
                guard let data = response.value else { return }
                hotelDetailInfo = data
                let initialLocation = CLLocation(latitude: hotelDetailInfo.lat!, longitude: hotelDetailInfo.lon!)
                self.mapView.centerToLocation(initialLocation)
                if let image = hotelDetailInfo.image {
                    if image.count > 0 {
                        AF.download(URLS.imageBaseURL + image)
                            .validate()
                            .responseData { response in
                            if let data = response.value {
                                if let image = UIImage(data: data) {
                                    if image.size.width > 100 {
                                        self.imageView.image = image
                                        self.imageView.contentMode = .scaleAspectFill
                                    }
                                }
                            }
                        }
                    }
                }
        }
    }

}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
