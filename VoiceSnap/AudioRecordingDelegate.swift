//
//  AudioRecordingDelegate.swift
//  VoiceSnap
//
//  Created by Eric Hodgins on 2016-10-11.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import Foundation
import AVFoundation

class AudioRecordingDelegate: NSObject, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder?
    var audioURL: URL
    
    init(audioRecorder: AVAudioRecorder?, audioPathURL url: URL) {
        self.audioRecorder = audioRecorder
        self.audioURL = url
    }
    
    func startRecording() {
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
            audioRecorder!.delegate = self
            audioRecorder!.isMeteringEnabled = true
            audioRecorder!.prepareToRecord()
            audioRecorder!.record()
        } catch {
            print(error)
        }
    }
    
    func stopRecording() {
        audioRecorder!.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("finished recording")
    }
    
}
