//  Copyright © 2020 Deeba Yavrom. All rights reserved.

import UIKit
import MapKit

class LocationDetailsViewController: UIViewController {
    let contentTextView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        return view
    }()
    
    let artwork: Artwork
    
    init(with artwork: Artwork) {
        self.artwork = artwork
        super.init(nibName: nil, bundle: nil)
    }
    //these has to be written when adding or overriding an init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupViews()
    }
    
    func setupViews() {
        title = artwork.title
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = .init(title: "Close", style: .plain, target: self, action: #selector(closeDetails))
        
        //again, some programmatically-created layout with Auto Layout
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentTextView)
        [
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ].forEach { $0.isActive = true }
        
        
        //since the whole content is located inside one UITextView (to make it scrollable)
        //we should use NSAttributedString for different parts of contents (heading, address, description), which allows to set different font, color etc for parts of string using attributes
        
        //by the way, using fonts from UIFont.preferredFont improves app's usability for people who use Accessibiltiy functions on their phones (font size becomes adaptive to system settings)
        //and UIColor.label and colors other from that group are automatically switched when darkMode is enabled
        let attributedTitle = NSMutableAttributedString(string: "\(artwork.title!)\n", attributes: [.font : UIFont.preferredFont(forTextStyle: .headline), .foregroundColor : UIColor.label])
        // \n symbols of new line to add some gap between content
        let attributedAddress = NSAttributedString(string: "\(artwork.locationURL)\n\n\n", attributes: [.font : UIFont.preferredFont(forTextStyle: .subheadline), .foregroundColor : UIColor.secondaryLabel])
        let attributedDescription = NSAttributedString(string: artwork.locationDescription, attributes: [.font : UIFont.preferredFont(forTextStyle: .body), .foregroundColor : UIColor.label])
        
 
        
        
        attributedTitle.append(attributedAddress)
        attributedTitle.append(attributedDescription)
        contentTextView.attributedText = attributedTitle
        //set to zero manually because otherwise it will be shown already scrolled a bit
        contentTextView.contentOffset = .zero
    }
    
    @objc func closeDetails() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
