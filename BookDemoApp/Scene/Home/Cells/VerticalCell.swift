//
//  VerticalCell.swift
//  BookDemoApp
//
//  Created by Zerom on 4/26/24.
//

import UIKit

final class VerticalCell: UICollectionViewCell {
    static let id = "VerticalCell"
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    private func setUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(240)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(6)
            make.horizontalEdges.equalToSuperview().inset(2)
        }
    }
    
    func configure(title: String, url: String) {
        titleLabel.text = title
        imageView.kf.setImage(with: URL(string: url))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
