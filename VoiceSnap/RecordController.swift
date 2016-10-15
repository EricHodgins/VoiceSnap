//
//  ViewController.swift
//  VoiceSnap
//
//  Created by Eric Hodgins on 2016-10-09.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class RecordController: UIViewController {
    
    var fetchedResultsController: NSFetchedResultsController<Record>!
    
    var newSavedFileName: String?
    var audioPlayer: AVAudioPlayer!
    var audioEngine = AVAudioEngine()
    var reverbWetDrayPercent: Float!
    
    var audioRecorder: AVAudioRecorder!
    
    lazy var audioPlayingDelegate: AudioPlayingDelegate = {
        let apd = AudioPlayingDelegate(audioPlayer: self.audioPlayer, audioEngine: self.audioEngine, urlForAudioPath: self.audioURL)
        return apd
    }()
    
    lazy var audioRecordingDelegate: AudioRecordingDelegate = {
        let ard = AudioRecordingDelegate(audioRecorder: self.audioRecorder, audioPathURL: self.audioURL)
        
        return ard
    }()
    
    var audioURL: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths.first!
        let url = documentDirectory.appendingPathComponent("TempFileName.m4a")
        
        return url
    }()
    
    // MARK: - Buttons
    
    lazy var recordButton: UIButton = {
        let button = UIButton()
        button.setTitle("RECORD", for: .normal)
        button.backgroundColor = UIColor.red
        return button
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.backgroundColor = UIColor(colorLiteralRed: 44/255, green: 121/255, blue: 64/255, alpha: 1.0)
        return button
    }()
    
    lazy var playWithEffectsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Play With Effects", for: .normal)
        button.backgroundColor = UIColor(colorLiteralRed: 40/255, green: 115/255, blue: 50/255, alpha: 1.0)
        return button
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("SAVE", for: .normal)
        button.backgroundColor = UIColor.orange
        return button
    }()
    
    lazy var showRecordsButton: UIButton = {
        let button = UIButton()
        button.setTitle("SHOW RECORDS", for: .normal)
        button.backgroundColor = UIColor(colorLiteralRed: 51/255, green: 86/255, blue: 191/255, alpha: 1.0)
        return button
    }()
    
    // MARK: - Audio Control Settings
    
    lazy var reverbSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.isContinuous = true
        return slider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVAudioSession.sharedInstance().requestRecordPermission { (success) in
            print("permission granted: \(success)")
        }
        
        recordButton.addTarget(self, action: #selector(RecordController.startRecording), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(RecordController.playRecording), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(RecordController.saveAndRenameRecording), for: .touchUpInside)
        showRecordsButton.addTarget(self, action: #selector(RecordController.showRecords), for: .touchUpInside)
        playWithEffectsButton.addTarget(self, action: #selector(RecordController.playAudioWithEffects), for: .touchUpInside)
        reverbSlider.addTarget(self, action: #selector(RecordController.reverSliderChanged(sender:)), for: UIControlEvents.valueChanged)
        
        audioEngine = AVAudioEngine()
        
        fetchAllRecords()
    }
    
    override func viewDidLayoutSubviews() {
        view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(showRecordsButton)
        showRecordsButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playWithEffectsButton)
        playWithEffectsButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(reverbSlider)
        reverbSlider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 5),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            playButton.widthAnchor.constraint(equalToConstant: 300),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 5),
            recordButton.heightAnchor.constraint(equalToConstant: 50),
            recordButton.widthAnchor.constraint(equalToConstant: 300),
            
            saveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            showRecordsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showRecordsButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 5),
            showRecordsButton.heightAnchor.constraint(equalToConstant: 50),
            showRecordsButton.widthAnchor.constraint(equalToConstant: 300),
            
            reverbSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reverbSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            reverbSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            reverbSlider.topAnchor.constraint(equalTo: showRecordsButton.bottomAnchor, constant: 30),
            
            playWithEffectsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playWithEffectsButton.widthAnchor.constraint(equalToConstant: 300),
            playWithEffectsButton.heightAnchor.constraint(equalToConstant: 50),
            playWithEffectsButton.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10)
        ])
    }
    
}

extension RecordController: AVAudioRecorderDelegate {
    func startRecording() {
        
        if recordButton.titleLabel?.text == "RECORD" {
            playButton.isEnabled = false
            recordButton.setTitle("STOP", for: .normal)
            audioRecordingDelegate.startRecording()
        } else {
            stopRecording()
            playButton.isEnabled = true
        }
    }    
    
    func stopRecording() {
        audioRecordingDelegate.stopRecording()
        recordButton.setTitle("RECORD", for: .normal)
        audioPlayingDelegate.createAudioPlayer()
    }

}


extension RecordController: AVAudioPlayerDelegate {
    
    func playRecording() {
        audioPlayingDelegate.playRecording()
    }

}


// MARK: Save Recording

extension RecordController {
    
    func saveAndRenameRecording() {
        let saveController = SaveTableViewController()
        let nav = UINavigationController(rootViewController: saveController)
        present(nav, animated: true, completion: nil)
    }

}

// MARK: Fetching

extension RecordController {
    func fetchAllRecords() {
        let request = Record.allRecordsFetchRequest()
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataController.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            
        }
        
        for photo in self.fetchedResultsController.fetchedObjects! {
            print(photo.name)
        }
    }
}

// MARK: Show Records CollectionView

extension RecordController {
    func showRecords() {
        let recordsController = RecordsCollectionViewController(audioPlayingDelegate: self.audioPlayingDelegate)
        let navController = UINavigationController(rootViewController: recordsController)
        present(navController, animated: true, completion: nil)
    }
}

// MARK: Configuring Audio Settings

extension RecordController {
    func reverSliderChanged(sender: UISlider!) {
        reverbWetDrayPercent = sender.value
    }
    
    func playAudioWithEffects() {
        audioPlayingDelegate.playAudioWithEffect(reverbAmount: reverbWetDrayPercent)
    }
}


















