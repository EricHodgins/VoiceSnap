//
//  AudioPlayingDelegate.swift
//  VoiceSnap
//
//  Created by Eric Hodgins on 2016-10-11.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayingDelegate: NSObject, AVAudioPlayerDelegate {
    
    var reverb: AVAudioUnitReverb!
    var distortion: AVAudioUnitDistortion!
    var effect: AVAudioUnitDelay!
    
    var audioPlayer: AVAudioPlayer?
    var audioEngine: AVAudioEngine?
    var audioURL: URL!
    
    lazy var audioFile: AVAudioFile = {
        let file = try! AVAudioFile(forReading: self.audioURL)
        return file
    }()
    
    init(audioPlayer: AVAudioPlayer?, audioEngine: AVAudioEngine?, urlForAudioPath url: URL) {
        self.audioPlayer = audioPlayer
        self.audioEngine = audioEngine
        self.audioURL = url
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Audio Finished Playing")
    }
    
    func playRecording() {
        if audioPlayer != nil {
            audioPlayer!.stop()
            audioEngine!.stop()
            audioEngine!.reset()
            audioPlayer!.play()
        } else if recordingIsSaved() {
            createAudioPlayer()
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSessionCategoryPlayback, with: .defaultToSpeaker)
            } catch {
                print(error)
            }
            audioPlayer!.play()
        }
        
    }
    
    // For playing when in collectionView
    func play(withRecord record: Record) {
        audioURL = record.URLToDocumentsDirectory(withFileName: record.name)
        createAudioPlayer()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback, with: .defaultToSpeaker)
        } catch {
            print(error)
        }
        audioPlayer?.play()
    }
    
    func createAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer!.enableRate = true
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
        } catch {
            print(error)
        }
    }
    
    func recordingIsSaved() -> Bool {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
            for p in directoryContents {
                print(p)
            }
            if directoryContents.count > 0 {
                audioURL = directoryContents.last!
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    // Include Sound Effects
    
    func playAudioWithEffect(reverbAmount: Float) {
        audioPlayer!.stop()
        audioEngine!.stop()
        audioEngine!.reset()
        
        // Player A Node
        let playerANode = AVAudioPlayerNode()
        audioEngine!.attach(playerANode)
        
        // Reverb Node
        reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.cathedral)
        reverb.wetDryMix = reverbAmount
        audioEngine!.attach(reverb)
        
        // Distortion Node
        distortion = AVAudioUnitDistortion()
        distortion.loadFactoryPreset(AVAudioUnitDistortionPreset.speechRadioTower)
        distortion.wetDryMix = 25
        audioEngine!.attach(distortion)
        
        // Effect
        effect = AVAudioUnitDelay()
        effect.delayTime = TimeInterval.abs(0.5)
        audioEngine!.attach(effect)
        
        
        // Make buffer
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
        
        do {
            try audioFile.read(into: buffer)
        } catch {
            print(error)
        }
        
        // Connect nodes
        audioEngine!.connect(playerANode, to: reverb, format: buffer.format)
        audioEngine!.connect(reverb, to: distortion, format: buffer.format)
        audioEngine!.connect(distortion, to: effect, format: buffer.format)
        audioEngine!.connect(effect, to: audioEngine!.outputNode, format: buffer.format)
        
        playerANode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        
        do {
            try audioEngine!.start()
            playerANode.play()
        } catch {
            print(error)
        }
        
    }

}































