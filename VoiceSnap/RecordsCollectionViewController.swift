//
//  RecordsCollectionViewController.swift
//  VoiceSnap
//
//  Created by Eric Hodgins on 2016-10-13.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import CoreData

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
    
    var audioPlayingDelegate: AudioPlayingDelegate
    
    init(audioPlayingDelegate: AudioPlayingDelegate) {
        self.audioPlayingDelegate = audioPlayingDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordsDataSource.executeFetch()
        collectionView.dataSource = recordsDataSource
        collectionView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(RecordsCollectionViewController.done))
        navigationItem.rightBarButtonItem = doneButton
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


// MARK: UICollectionViewDelegate

extension RecordsCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recording = recordsDataSource.fetchedResultsController.object(at: indexPath)
        audioPlayingDelegate.play(withRecord: recording)
    }
    
    func done() {
        dismiss(animated: true, completion: nil)
    }
}



















