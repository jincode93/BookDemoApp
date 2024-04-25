//
//  CategoryCell.swift
//  BookDemoApp
//
//  Created by Zerom on 4/25/24.
//

import UIKit
import Kingfisher

final class CategoryCell: UICollectionViewCell {
    static let id = "CategoryCell"
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    private func setUI() {
        addSubview(imageView)
        addSubview(stack)
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(descLabel)
        
        imageView.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
            make.width.equalTo(96)
        }
        
        stack.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }

    func configure(title: String, desc: String, url: String) {
        titleLabel.text = title
        descLabel.text = desc
        imageView.kf.setImage(with: URL(string: url))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
