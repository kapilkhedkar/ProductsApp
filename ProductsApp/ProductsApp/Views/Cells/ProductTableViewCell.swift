//
//  ProductTableViewCell.swift
//  ProductsApp
//
//  Created by Kapil Khedkar on 21/05/26.
//

import UIKit

final class ProductTableViewCell: UITableViewCell {

    static let reuseIdentifier = "ProductTableViewCell"
    static let estimatedHeight: CGFloat = 120

    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.backgroundColor = .secondarySystemFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let categoryBadge: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = .white
        l.backgroundColor = .systemBlue
        l.layer.cornerRadius = 6
        l.clipsToBounds = true
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = .systemGreen
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chevronImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var textStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, bottomRow])
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .leading
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var bottomRow: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [categoryBadge, priceLabel, UIView()])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        return sv
    }()

    private var currentImageURL: URL?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("Use init(style:reuseIdentifier:)") }

    override func prepareForReuse() {
        super.prepareForReuse()
        if let url = currentImageURL {
            ImageLoader.shared.cancel(url: url)
        }
        productImageView.image = nil
        currentImageURL = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        categoryBadge.text = nil
        priceLabel.text = nil
    }
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        descriptionLabel.text = product.description
        priceLabel.text = product.formattedPrice
        categoryBadge.text = "  \(product.category.capitalized)  "
        
        loadImage(from: product.imageURL)
    }

    private func loadImage(from url: URL?) {
        guard let url else {
            productImageView.image = UIImage(systemName: "photo")
            productImageView.tintColor = .systemGray4
            return
        }
        currentImageURL = url
        productImageView.alpha = 0
        ImageLoader.shared.load(url: url) { [weak self] image in
            guard let self, self.currentImageURL == url else { return }
            self.productImageView.image = image ?? UIImage(systemName: "photo")
            UIView.animate(withDuration: 0.25) {
                self.productImageView.alpha = 1
            }
        }
    }
    
    private func setupViews() {
        selectionStyle = .none

        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.07
        card.layer.shadowRadius = 6
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(card)
        card.addSubview(productImageView)
        card.addSubview(textStack)
        card.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            productImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            productImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80),

            chevronImageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            chevronImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14),

            textStack.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            textStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
    }
}
