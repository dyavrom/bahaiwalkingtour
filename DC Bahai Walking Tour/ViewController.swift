//  Created by Deeba Yavrom on 12/1/19.
//  Copyright © 2019 Deeba Yavrom. All rights reserved.
//
import UIKit
import MapKit
import SafariServices

class ViewController: UIViewController, SFSafariViewControllerDelegate, CLLocationManagerDelegate {
    var artworks: [Artwork] = []
    @IBOutlet weak var mapView: MKMapView!
    
    //add safari link
    @IBOutlet var leadingC: NSLayoutConstraint!
    @IBOutlet var trailingC: NSLayoutConstraint!
    @IBOutlet var ubeView: UIView!
    
    var hamburgerMenuIsVisible = false
    
    @IBAction func hamburgerBtnTapped(_ sender: Any) {
        //if the hamburger menu is NOT visible, then move the ubeView back to where it used to be
        if !hamburgerMenuIsVisible {
            leadingC.constant = 300
            //this constant is NEGATIVE because we are moving it 150 points OUTWARD and that means -150
            trailingC.constant = 200
            
            //1
            hamburgerMenuIsVisible = true
        } else {
            //if the hamburger menu IS visible, then move the ubeView back to its original position
            leadingC.constant = 0
            trailingC.constant = 0
            
            //2
            hamburgerMenuIsVisible = false
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { (animationComplete) in
            print("The animation is complete!")
        }
        
    }
    
    @IBAction func changeMapView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            mapView.mapType = .standard
        } else {
            mapView.mapType = .hybrid
        }
    }
    
    let regionRadius: CLLocationDistance = 18000
    
    // set initial location in Washington DC
    let initialLocation = CLLocation(latitude: 38.89002, longitude: -77.0369);
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Do any additional setup after loading the view.
        centerMapOnLocation(location: initialLocation)
        
        //add the flag icon
        mapView.register(ArtworkView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        mapView.isRotateEnabled = false
        //  mapView.userTrackingMode = .follow
        //  mapView.showsUserLocation = true

        loadInitialData()
        mapView.addAnnotations(artworks)
        
//        this automatically displays the text for a selected point leaves on load.
//         let yourAnnotationAtIndex = 12
//         mapView.selectAnnotation(mapView.annotations[yourAnnotationAtIndex], animated: true)
    }
    
    // SFSafariViewControllerDelegate delegate method
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    //prompt and show user location
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        print("Entropy")
    }

    // MARK: - CLLocationManager
    let locationManager = CLLocationManager()
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestAlwaysAuthorization()
        }
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func loadInitialData() {
        // 1
        guard let fileName = Bundle.main.path(forResource: "data", ofType: "json")
            else { return }
        let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName))
        
        guard
            let data = optionalData,
            // 2
            let json = try? JSONSerialization.jsonObject(with: data),
            // 3
            let dictionary = json as? [String: Any],
            // 4
            let works = dictionary["data"] as? [[Any]]
            else { return }
        // 5
        let validWorks = works.compactMap { Artwork(json: $0) }
        artworks.append(contentsOf: validWorks)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Artwork else { return nil }
        var annotationView: ArtworkView!
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: ArtworkView.reuseIdentifier)
            as? ArtworkView {
            dequeuedView.annotation = annotation
            annotationView = dequeuedView
        } else {
            // 5
            annotationView = ArtworkView(annotation: annotation, reuseIdentifier: ArtworkView.reuseIdentifier)
        }
        annotationView.detailCallout.presentingDelegate = self
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Artwork
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}

extension ViewController: UIViewControllerPresenter {
    func presentDetails(of location: Artwork) {
        let nav = UINavigationController(rootViewController: LocationDetailsViewController(with: location))
        self.show(nav, sender: self)
    }
}

