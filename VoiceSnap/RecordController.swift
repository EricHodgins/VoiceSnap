//
//  ViewController.swift
//  VoiceSnap
//
//  Created by Eric Hodgins on 2016-10-09.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import AVFoundation

class RecordController: UIViewController {
    
    var newSavedFileName: String?
    var audioPlayer: AVAudioPlayer!
    var audioEngine: AVAudioEngine!
    
    var audioRecorder: AVAudioRecorder!
    
    lazy var audioPlayingDelegate: AudioPlayingDelegate = {
        let apd = AudioPlayingDelegate(audioPlayer: self.audioPlayer, audioEngine: self.audioEngine, urlForAudioPath: self.audioURL)
        return apd
    }()
    
    var audioURL: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths.first!
        let url = documentDirectory.appendingPathComponent("TempFileName.m4a")
        
        return url
    }()
    
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
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("SAVE", for: .normal)
        button.backgroundColor = UIColor.orange
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVAudioSession.sharedInstance().requestRecordPermission { (success) in
            print("permission granted: \(success)")
        }
        
        recordButton.addTarget(self, action: #selector(RecordController.startRecording), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(RecordController.playRecording), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(RecordController.saveAndRenameRecording), for: .touchUpInside)
        
        audioEngine = AVAudioEngine()
    }
    
    override func viewDidLayoutSubviews() {
        view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 10),
            playButton.heightAnchor.constraint(equalToConstant: 100),
            playButton.widthAnchor.constraint(equalToConstant: 300),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 10),
            recordButton.heightAnchor.constraint(equalToConstant: 100.0),
            recordButton.widthAnchor.constraint(equalToConstant: 300),
            
            saveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
}

extension RecordController: AVAudioRecorderDelegate {
    func startRecording() {
        
        if recordButton.titleLabel?.text == "RECORD" {
            playButton.isEnabled = false
            let session = AVAudioSession.sharedInstance()
            
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                // 4. create the audio recording, and assign ourselves as the delegate
                audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
                audioRecorder.record()
                recordButton.setTitle("STOP", for: .normal)
            } catch {
                print(error)
            }
        } else {
            stopRecording()
            playButton.isEnabled = true
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("finished recording")
    }
    
    
    func stopRecording() {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        
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






















