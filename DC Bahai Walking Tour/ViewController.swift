//  Created by Deeba Yavrom on 12/1/19.
//  Copyright © 2019 Deeba Yavrom. All rights reserved.

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    var artworks: [Artwork] = []
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet var leadingC: NSLayoutConstraint!
    @IBOutlet var trailingC: NSLayoutConstraint!
    @IBOutlet var ubeView: UIView!

    private var sidebarView: SidebarView?
    private let sidebarWidth: CGFloat = 300
    private weak var hamburgerButton: UIButton?

    @IBAction func hamburgerBtnTapped(_ sender: Any) {
        hamburgerButton = hamburgerButton ?? (sender as? UIButton)
        let isOpen = (sidebarView?.frame.origin.x ?? -sidebarWidth) >= 0
        if isOpen {
            collapseSidebar()
        } else {
            hamburgerButton?.alpha = 0
            addDismissOverlay()
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                self.sidebarView?.frame.origin.x = 0
            }
            sidebarView?.flashScrollHint()
        }
    }

    func collapseSidebar() {
        let overlay = view.viewWithTag(9999)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.sidebarView?.frame.origin.x = -self.sidebarWidth
            overlay?.alpha = 0
        }, completion: { _ in
            overlay?.removeFromSuperview()
            UIView.animate(withDuration: 0.15) {
                self.hamburgerButton?.alpha = 1
            }
        })
    }

    private func addDismissOverlay() {
        guard let sidebar = sidebarView else { return }
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0)
        overlay.frame = view.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.tag = 9999
        overlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(overlayTapped)))
        view.insertSubview(overlay, belowSubview: sidebar)
        UIView.animate(withDuration: 0.25) {
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        }
    }

    @objc private func overlayTapped() {
        collapseSidebar()
    }

    @IBAction func changeMapView(_ sender: UISegmentedControl) {
        mapView.mapType = sender.selectedSegmentIndex == 0 ? .standard : .hybrid
    }

    let regionRadius: CLLocationDistance = 18000
    let initialLocation = CLLocation(latitude: 38.89002, longitude: -77.0369)

    func centerMapOnLocation(location: CLLocation) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        mapView.setRegion(region, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        centerMapOnLocation(location: initialLocation)

        mapView.register(
            ArtworkView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        mapView.isRotateEnabled = false

        loadInitialData()
        mapView.addAnnotations(artworks)
        setupSidebar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }

    // MARK: - Sidebar

    private func setupSidebar() {
        // ubeView was the old constraint-based slide mechanism — no longer needed
        ubeView.isHidden = true

        view.clipsToBounds = true

        let sidebar = SidebarView(artworks: artworks, delegate: self)
        sidebar.frame = CGRect(x: -sidebarWidth, y: 0, width: sidebarWidth, height: view.bounds.height)
        sidebar.autoresizingMask = [.flexibleHeight]
        view.insertSubview(sidebar, belowSubview: ubeView)
        sidebarView = sidebar
    }

    // MARK: - Location

    let locationManager = CLLocationManager()

    func checkLocationAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorizationStatus()
    }

    // MARK: - Data

    func loadInitialData() {
        guard
            let url = Bundle.main.url(forResource: "data", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let locations = json["locations"] as? [[String: Any]]
        else { return }

        artworks = locations.compactMap { Artwork(dict: $0) }
    }
}

// MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Artwork else { return nil }

        let annotationView: ArtworkView
        if let dequeued = mapView.dequeueReusableAnnotationView(
            withIdentifier: ArtworkView.reuseIdentifier) as? ArtworkView {
            dequeued.annotation = annotation
            annotationView = dequeued
        } else {
            annotationView = ArtworkView(annotation: annotation, reuseIdentifier: ArtworkView.reuseIdentifier)
        }
        annotationView.detailCallout.presentingDelegate = self
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard let location = view.annotation as? Artwork else { return }
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}

// MARK: - UIViewControllerPresenter

extension ViewController: UIViewControllerPresenter {
    func presentDetails(of location: Artwork) {
        let nav = UINavigationController(rootViewController: LocationDetailsViewController(with: location))
        present(nav, animated: true)
    }
}

// MARK: - SidebarDelegate

extension ViewController: SidebarDelegate {
    func sidebarDidSelectAbout(_ sidebar: SidebarView) {
        collapseSidebar()
        let nav = UINavigationController(rootViewController: AboutViewController())
        present(nav, animated: true)
    }

    func sidebar(_ sidebar: SidebarView, didSelectArtwork artwork: Artwork) {
        collapseSidebar()

        let region = MKCoordinateRegion(
            center: artwork.coordinate,
            latitudinalMeters: 1200,
            longitudinalMeters: 1200
        )
        mapView.setRegion(region, animated: true)

        if let annotation = mapView.annotations.first(where: { ($0 as? Artwork)?.title == artwork.title }) {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
}

// MARK: - Sidebar Views

protocol SidebarDelegate: AnyObject {
    func sidebar(_ sidebar: SidebarView, didSelectArtwork artwork: Artwork)
    func sidebarDidSelectAbout(_ sidebar: SidebarView)
}

class SidebarView: UIView {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let sortedArtworks: [Artwork]
    weak var delegate: SidebarDelegate?

    init(artworks: [Artwork], delegate: SidebarDelegate?) {
        self.sortedArtworks = artworks.sorted { ($0.title ?? "") < ($1.title ?? "") }
        self.delegate = delegate
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        backgroundColor = .systemBackground

        let header = SidebarHeaderView(siteCount: sortedArtworks.count)
        header.translatesAutoresizingMaskIntoConstraints = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SidebarCell.self, forCellReuseIdentifier: SidebarCell.reuseId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AboutCell")
        tableView.backgroundColor = .systemBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64

        let fade = SidebarFadeView()
        fade.translatesAutoresizingMaskIntoConstraints = false

        addSubview(header)
        addSubview(tableView)
        addSubview(fade)

        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: leadingAnchor),
            header.trailingAnchor.constraint(equalTo: trailingAnchor),
            header.topAnchor.constraint(equalTo: topAnchor),
            header.heightAnchor.constraint(equalToConstant: 130),

            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            fade.leadingAnchor.constraint(equalTo: leadingAnchor),
            fade.trailingAnchor.constraint(equalTo: trailingAnchor),
            fade.bottomAnchor.constraint(equalTo: bottomAnchor),
            fade.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    func flashScrollHint() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.tableView.flashScrollIndicators()
        }
    }
}

extension SidebarView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sortedArtworks.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
            cell.imageView?.image = UIImage(systemName: "info.circle")
            cell.imageView?.tintColor = .systemTeal
            cell.textLabel?.text = "About This Tour"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: SidebarCell.reuseId, for: indexPath) as! SidebarCell
        cell.configure(with: sortedArtworks[indexPath.row - 1])
        return cell
    }
}

extension SidebarView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            delegate?.sidebarDidSelectAbout(self)
        } else {
            delegate?.sidebar(self, didSelectArtwork: sortedArtworks[indexPath.row - 1])
        }
    }
}

private class SidebarHeaderView: UIView {
    init(siteCount: Int) {
        super.init(frame: .zero)
        setupViews(siteCount: siteCount)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews(siteCount: Int) {
        backgroundColor = UIColor { tc in
            tc.userInterfaceStyle == .dark
                ? UIColor.systemGray6
                : UIColor(red: 0.95, green: 0.93, blue: 0.90, alpha: 1)
        }

        let titleLabel = UILabel()
        titleLabel.text = "DC Bahá'í\nWalking Tour"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2

        let subtitleLabel = UILabel()
        subtitleLabel.text = "\(siteCount) Historic Sites"
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        addSubview(divider)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),

            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

private class SidebarCell: UITableViewCell {
    static let reuseId = "SidebarCell"

    private let dot: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let blurbLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        accessoryType = .disclosureIndicator

        let textStack = UIStackView(arrangedSubviews: [nameLabel, blurbLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let row = UIStackView(arrangedSubviews: [dot, textStack])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .top
        row.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(row)

        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 10),
            dot.heightAnchor.constraint(equalToConstant: 10),
            dot.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 3),

            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with artwork: Artwork) {
        nameLabel.text = artwork.title
        blurbLabel.text = artwork.blurb
        dot.backgroundColor = artwork.markerTintColor
    }
}

// MARK: - About View Controller

private class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About This Tour"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done", style: .done, target: self, action: #selector(dismiss(_:))
        )
        view.backgroundColor = .systemGroupedBackground
        setupViews()
    }

    private func setupViews() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let contentView = UIView()
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

        let zaynLabel = UILabel()
        zaynLabel.text = "...for Zayn"
        zaynLabel.font = UIFont.italicSystemFont(ofSize: 12)
        zaynLabel.textColor = .tertiaryLabel
        zaynLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [
            makeCard(title: "THE TOUR", body: "Welcome to the DC Bahá'í walking tour app, which provides historical insight into the Washington, D.C. visit of 'Abdu'l-Bahá, son of Bahá'u'lláh, the Founder of the Bahá'í Faith.\n\nThe Bahá'ís of Washington DC have organized this self-guided tour to better learn the rich history of 'Abdu'l-Bahá's time spent in our great city. This tool also offers the ability to navigate to each site using Apple Maps.\n\nFor more information about the Bahá'í Faith, please visit www.dcbahai.org."),
            makeCard(title: "HOW TO USE", body: "Tap any pin on the map to see a brief description of that site. Tap the callout to read the full history. Use the list icon to browse all sites alphabetically.\n\nFor walking directions to any site, open the location detail and tap \"Get Walking Directions\"."),
            zaynLabel
        ])
        stack.setCustomSpacing(600, after: stack.arrangedSubviews[1])
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

    private func makeCard(title: String, body: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

        let para = NSMutableParagraphStyle()
        para.lineHeightMultiple = 1.35
        para.paragraphSpacing = 10

        let bodyLabel = UILabel()
        bodyLabel.attributedText = NSAttributedString(string: body, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label,
            .paragraphStyle: para
        ])
        bodyLabel.numberOfLines = 0
        bodyLabel.adjustsFontForContentSizeCategory = true

        let inner = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        inner.axis = .vertical
        inner.spacing = 8
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)

        NSLayoutConstraint.activate([
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
        return card
    }

    @objc private func dismiss(_ sender: Any) {
        dismiss(animated: true)
    }
}

// Gradient overlay that signals scrollable content below
private class SidebarFadeView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        applyColors()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyColors()
        }
    }

    private func applyColors() {
        let g = layer as! CAGradientLayer
        g.colors = [
            UIColor.systemBackground.withAlphaComponent(0).cgColor,
            UIColor.systemBackground.cgColor
        ]
    }
}
