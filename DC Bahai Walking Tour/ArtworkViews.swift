import Foundation
import MapKit

class ArtworkView: MKAnnotationView {
    static let reuseIdentifier = "artworkAnnotationView"
    let detailCallout: CustomArtworkCalloutView
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        detailCallout = CustomArtworkCalloutView(frame: .zero)
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        canShowCallout = true
        displayPriority = .required
        calloutOffset = CGPoint(x: -5, y: 5)
        let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                size: CGSize(width: 40, height: 40)))
        mapsButton.setImage(UIImage(named: "Maps-icon"), for: .normal)
        mapsButton.imageEdgeInsets = .init(top: 0, left: -8, bottom: 0, right: 8)
        rightCalloutAccessoryView = mapsButton
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let artwork = newValue as? Artwork else {return}
            if let imageName = artwork.imageName {
                image = UIImage(named: imageName)
            } else {
                image = nil
            }
            if detailCalloutAccessoryView == nil {
                detailCalloutAccessoryView = detailCallout
            }
            (detailCalloutAccessoryView as! CustomArtworkCalloutView).setContent(title: artwork.subtitle!, description: artwork.locationDescription, blurb: artwork.blurbT,  artwork: artwork)
        }
    }
}






