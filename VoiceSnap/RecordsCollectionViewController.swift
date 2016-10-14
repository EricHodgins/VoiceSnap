//
//  RecordsCollectionViewController.swift
//  VoiceSnap
//
//  Created by Eric Hodgins on 2016-10-13.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class RecordsCollectionViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 10
        let itemSize = (screenWidth - padding) / 2.0
        
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(RecordCell.self, forCellWithReuseIdentifier: RecordCell.reuseIdentifier)
        
        return collectionView
    }()
    
    lazy var recordsDataSource: RecordDataSource = {
        let dataSource = RecordDataSource(fetchRequest: Record.allRecordsFetchRequest(), collectionView: self.collectionView)
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordsDataSource.executeFetch()
        collectionView.dataSource = recordsDataSource
        automaticallyAdjustsScrollViewInsets = false
    }

    override func viewDidLayoutSubviews() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
}
