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
    
    var audioPlayer: AVAudioPlayer?
    var audioEngine: AVAudioEngine?
    var audioURL: URL!
    
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

}
