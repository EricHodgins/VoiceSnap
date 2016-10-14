//
//  RecordCell.swift
//  VoiceSnap
//
//  Created by Eric Hodgins on 2016-10-13.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class RecordCell: UICollectionViewCell {
    static let reuseIdentifier = "\(RecordCell.self)"
    
    var recordingName = UILabel()
    
    override func layoutSubviews() {
        contentView.backgroundColor = UIColor.orange
        contentView.addSubview(recordingName)
        recordingName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            recordingName.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            recordingName.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
