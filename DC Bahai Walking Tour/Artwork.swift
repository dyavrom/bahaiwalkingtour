import Foundation
import MapKit

class Artwork: NSObject, MKAnnotation {
    let title: String?
    let blurb: String
    let locationDescription: String
    let address: String
    let category: String
    let coordinate: CLLocationCoordinate2D

    init(title: String, blurb: String, locationDescription: String, address: String, category: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.blurb = blurb
        self.locationDescription = locationDescription
        self.address = address
        self.category = category
        self.coordinate = coordinate
        super.init()
    }

    convenience init?(dict: [String: Any]) {
        guard
            let title = dict["title"] as? String,
            let blurb = dict["blurb"] as? String,
            let description = dict["description"] as? String,
            let address = dict["address"] as? String,
            let category = dict["category"] as? String,
            let latitude = dict["latitude"] as? Double,
            let longitude = dict["longitude"] as? Double
        else { return nil }

        self.init(
            title: title,
            blurb: blurb,
            locationDescription: description,
            address: address,
            category: category,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        )
    }

    var subtitle: String? { address }

    var markerTintColor: UIColor {
        switch category.lowercased() {
        case "monument": return .systemRed
        case "mural":    return .systemTeal
        case "plaque":   return .systemBlue
        case "sculpture": return .systemPurple
        default:         return UIColor(red: 0.18, green: 0.49, blue: 0.40, alpha: 1)
        }
    }

    var imageName: String? { "Flag" }

    func mapItem() -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = title
        return item
    }
}
