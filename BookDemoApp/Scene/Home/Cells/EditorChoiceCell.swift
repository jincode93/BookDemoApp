//
//  EditorChoiceCell.swift
//  BookDemoApp
//
//  Created by Zerom on 4/20/24.
//

import UIKit
import SnapKit
import Kingfisher

final class EditorChoiceCell: UICollectionViewCell {
    static let id = "EditorChoiceCell"
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    private func setUI() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(url: String) {
        imageView.kf.setImage(with: URL(string: url))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
