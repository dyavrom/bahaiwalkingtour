import UIKit

protocol SidebarDelegate: AnyObject {
    func sidebar(_ sidebar: SidebarView, didSelectArtwork artwork: Artwork)
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .systemBackground

        let header = SidebarHeaderView(siteCount: sortedArtworks.count)
        header.translatesAutoresizingMaskIntoConstraints = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SidebarCell.self, forCellReuseIdentifier: SidebarCell.reuseId)
        tableView.backgroundColor = .systemBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64

        addSubview(header)
        addSubview(tableView)

        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: leadingAnchor),
            header.trailingAnchor.constraint(equalTo: trailingAnchor),
            header.topAnchor.constraint(equalTo: topAnchor),
            header.heightAnchor.constraint(equalToConstant: 130),

            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension SidebarView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sortedArtworks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SidebarCell.reuseId, for: indexPath) as! SidebarCell
        cell.configure(with: sortedArtworks[indexPath.row])
        return cell
    }
}

extension SidebarView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.sidebar(self, didSelectArtwork: sortedArtworks[indexPath.row])
    }
}

// MARK: - Header

private class SidebarHeaderView: UIView {

    init(siteCount: Int) {
        super.init(frame: .zero)
        setupViews(siteCount: siteCount)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

// MARK: - Cell

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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
