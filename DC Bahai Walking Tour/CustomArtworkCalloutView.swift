import UIKit

protocol UIViewControllerPresenter: AnyObject {
    func presentDetails(of: Artwork)
}

class CustomArtworkCalloutView: UIView {

    private let blurbLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let tapHintLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to read more →"
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = .systemTeal
        return label
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var presentingDelegate: UIViewControllerPresenter?
    private var artwork: Artwork?

    private func setupViews() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: -12),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        contentStack.addArrangedSubview(blurbLabel)
        contentStack.addArrangedSubview(addressLabel)
        contentStack.addArrangedSubview(tapHintLabel)

        let tap = UITapGestureRecognizer(target: self, action: #selector(calloutTapped))
        addGestureRecognizer(tap)
    }

    func setContent(address: String, description: String, blurb: String, artwork: Artwork) {
        blurbLabel.text = blurb
        addressLabel.text = address
        self.artwork = artwork
    }

    @objc private func calloutTapped() {
        guard let artwork = artwork else { return }
        presentingDelegate?.presentDetails(of: artwork)
    }
}
