import UIKit
import MapKit

class LocationDetailsViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let artwork: Artwork

    init(with artwork: Artwork) {
        self.artwork = artwork
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        title = artwork.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Close", style: .plain, target: self, action: #selector(closeDetails)
        )

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        let aboutCard = makeCard(sectionTitle: "TITLE", body: artwork.blurb)
        let locationCard = makeLocationCard()
        let historyCard = makeCard(sectionTitle: "HISTORY", body: artwork.locationDescription)

        let stack = UIStackView(arrangedSubviews: [aboutCard, locationCard, historyCard])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func makeCategoryBadge() -> UIView {
        let container = UIView()

        let dot = UIView()
        dot.backgroundColor = artwork.markerTintColor
        dot.layer.cornerRadius = 5
        dot.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = artwork.category.capitalized
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(dot)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 10),
            dot.heightAnchor.constraint(equalToConstant: 10),
            dot.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 6),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor)
        ])

        return container
    }

    private func makeCard(sectionTitle: String, body: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12

        let sectionLabel = UILabel()
        sectionLabel.text = sectionTitle
        sectionLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        sectionLabel.textColor = .secondaryLabel

        let para = NSMutableParagraphStyle()
        para.lineHeightMultiple = 1.35
        para.paragraphSpacing = 10

        let bodyLabel = UILabel()
        bodyLabel.attributedText = NSAttributedString(
            string: body,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label,
                .paragraphStyle: para
            ]
        )
        bodyLabel.numberOfLines = 0
        bodyLabel.adjustsFontForContentSizeCategory = true

        let stack = UIStackView(arrangedSubviews: [sectionLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        return card
    }

    private func makeLocationCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12

        let sectionLabel = UILabel()
        sectionLabel.text = "LOCATION"
        sectionLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        sectionLabel.textColor = .secondaryLabel

        let addressLabel = UILabel()
        addressLabel.text = artwork.address
        addressLabel.font = UIFont.preferredFont(forTextStyle: .body)
        addressLabel.textColor = .label
        addressLabel.numberOfLines = 0

        let directionsButton = UIButton(type: .system)
        directionsButton.setTitle("  Get Walking Directions", for: .normal)
        directionsButton.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        directionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        directionsButton.contentHorizontalAlignment = .left
        directionsButton.addTarget(self, action: #selector(getDirections), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [sectionLabel, addressLabel, directionsButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        return card
    }

    @objc private func getDirections() {
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        artwork.mapItem().openInMaps(launchOptions: launchOptions)
    }

    @objc private func closeDetails() {
        navigationController?.dismiss(animated: true)
    }
}
