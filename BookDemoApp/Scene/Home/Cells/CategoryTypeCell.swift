//
//  CategoryTypeCell.swift
//  BookDemoApp
//
//  Created by Zerom on 4/25/24.
//

import UIKit

final class CategoryTypeCell: UICollectionViewCell {
    static let id = "CategoryTypeCell"
    
    private let imageBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 5
        return view
    }()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .center
        image.tintColor = .black
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    private func setUI() {
        addSubview(imageBackView)
        addSubview(imageView)
        addSubview(titleLabel)
        
        imageBackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(imageBackView.snp.edges)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(2)
            make.horizontalEdges.equalToSuperview()
        }
    }

    func configure(title: String, imageName: String) {
        titleLabel.text = title
        imageView.image = UIImage(systemName: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
