//
//  BestsellcerCell.swift
//  BookDemoApp
//
//  Created by Zerom on 4/19/24.
//

import UIKit
import SnapKit
import Kingfisher

final class BestsellcerCell: UICollectionViewCell {
    static let id = "BestsellcerCell"
    
    private let coverImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    private func setUI() {
        backgroundColor = .lightGray
        
        addSubview(coverImage)
        addSubview(titleLabel)
        addSubview(descLabel)
        
        coverImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(280)
        }
        
        descLabel.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(descLabel.snp.top).offset(-10)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(60)
        }
    }
    
    func configure(title: String, desc: String, url: String) {
        titleLabel.text = title
        descLabel.text = desc
        coverImage.kf.setImage(with: URL(string: url))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
