//  Copyright © 2020 Deeba Yavrom. All rights reserved.
//

import UIKit

class CustomArtworkCalloutView: UIView {
    
    //created with code instead of IBOutlets
    
    // label address
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Heiti TC", size: 13)
        //label.textColor = .secondaryLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    //label blurb
    let blurbT: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Heiti TC", size: 13)
      //  label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)
        label.numberOfLines = 3
        label.textColor = .label
        return label
    }()
    
    //label description main text
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Heiti TC", size: 13)
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
    
    
    lazy var expandButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("..tap to read more ↓", for: .normal)
        btn.titleLabel?.font =  UIFont(name: "Heiti TC", size: 13)
        btn.setTitleColor(.secondaryLabel, for: .normal)
        btn.addTarget(self, action: #selector(expandClicked), for: .touchUpInside)
        return btn
    }()
    
    let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 3
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //weak to prevent reference cycle leading to memory leaks
    weak var presentingDelegate: UIViewControllerPresenter?
    var artwork: Artwork?
    func setupViews() {
        //i prefer to create layout programmatically using AutoLayout instead of storyboards
        self.addSubview(contentStack)
        self.addSubview(expandButton)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: self.topAnchor, constant: -16),
        ])
        
        NSLayoutConstraint.activate([
            expandButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            expandButton.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            expandButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            expandButton.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: -8)
        ])
        
        contentStack.addArrangedSubview(blurbT)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(descriptionLabel)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandClicked))
        self.addGestureRecognizer(gestureRecognizer) //comment this to disable whole popup being tappable
    }
    
    func setContent(title: String, description: String, blurb: String, artwork: Artwork) {
        titleLabel.text = title
        descriptionLabel.text = description
        blurbT.text = blurb
        self.artwork = artwork
    }
    
    @objc func expandClicked() {
        if let artwork = artwork {
            //delegete is our main ViewController which is able to show some child view controller
            presentingDelegate?.presentDetails(of: artwork)
        }
    }
}

protocol UIViewControllerPresenter: class {
    func presentDetails(of: Artwork)
}
