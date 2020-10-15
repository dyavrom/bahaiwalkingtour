import Foundation
import Contacts
import MapKit

class Artwork: NSObject, MKAnnotation {
let title: String?
let blurbT: String
let locationDescription: String
let locationURL: String
let discipline: String
let coordinate: CLLocationCoordinate2D

    init(title: String, locationDescription: String, locationURL: String, discipline: String, blurbT: String, coordinate: CLLocationCoordinate2D) {
  self.title = title
        self.blurbT = blurbT
  self.locationDescription = locationDescription
  self.locationURL = locationURL
  self.discipline = discipline
  self.coordinate = coordinate
  
    super.init()
  }
    
    var blurb: String? {
      return blurbT
    }
      
    var subtitle: String? {
        return locationURL
    }
    
    var locationlink: String? {
      return locationURL
    }
    
    
  init?(json: [Any]) {
    // 1
    if let title = json[1] as? String {
      self.title = title
    } else {
      self.title = "No Title"
    }
    // json[11] is the long description
    //self.locationName = json[11] as! String
    // json[12] is the short location string
    self.blurbT = json[2] as! String
    self.locationDescription = json[9] as! String

    self.discipline = json[10] as! String
    self.locationURL = json[3] as! String
 
    // 2
    if let latitude = Double(json[7] as! String),
      let longitude = Double(json[8] as! String) {
      self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    } else {
      self.coordinate = CLLocationCoordinate2D()
    }
  }

  // pinTintColor for disciplines: Sculpture, Plaque, Mural, Monument, other
  var markerTintColor: UIColor  {
    switch discipline {
    case "Monument":
      return .red
    case "Mural":
      return .cyan
    case "Plaque":
      return .blue
    case "Sculpture":
      return .purple
    default:
      return .green
    }
  }

  var imageName: String? {
    if discipline == "Mural" { return "Flag" }
    return "Flag"
  }

  // Annotation right callout accessory opens this mapItem in Maps app
  func mapItem() -> MKMapItem {
    let addressDict = [CNPostalAddressStreetKey: subtitle!]
    let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = title
    return mapItem
  }
}
