//
//  HotelCell.swift
//  hotels
//
//  Created by username on 20.12.2021.
//

import UIKit
import Alamofire

class HotelCell: UITableViewCell {
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var hotelPicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(for hotel: Hotel) {
        var hotelDetailInfo: Hotel = hotel
        hotelPicture.image = UIImage(systemName: "photo")
        hotelPicture.layer.cornerRadius = 8
        hotelPicture.clipsToBounds = true
        hotelPicture.layer.borderWidth = 2
        hotelPicture.layer.borderColor = UIColor.white.cgColor
        let suites = hotel.suites_availability.components(separatedBy: ":").filter { $0 != "" }
        hotelName.text = hotel.name
        starsLabel.text = String(repeating: "★", count: Int(hotel.stars))
        let url = URLS.hotelInfoBaseURL + "\(hotel.id)" + ".json"
        AF.request(url)
            .validate()
            .responseDecodable(of: Hotel.self) { (response) in
                guard let data = response.value else { return }
                hotelDetailInfo = data
                self.addressLabel.text = hotelDetailInfo.address
                self.distanceLabel.text = String(format: "%.0f", hotelDetailInfo.distance) + " м от центра, " + "\(suites.count)" + " номеров свободно"
                if let image = hotelDetailInfo.image {
                    if image.count > 0 {
                        AF.download(URLS.imageBaseURL + image)
                            .validate()
                            .responseData { response in
                            if let data = response.value {
                                self.hotelPicture.image = UIImage(data: data)
                                self.hotelPicture.contentMode = .scaleAspectFill
                            }
                            
                        }
                    }
                }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
