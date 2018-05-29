//
//  RecordDemoViewController.swift
//  AudioKitExamples
//
//  Created by yin.yan on 2018/05/29.
//  Copyright © 2018年 yin.yan. All rights reserved.
//

import UIKit
import AudioKit

class RecordDemoViewController: UIViewController {

    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    var player: AKPlayer?
    var tape: AKAudioFile!
    var micBooster: AKBooster!
    var moogLadder: AKMoogLadder!
    var mainMixer: AKMixer!
    var delay: AKVariableDelay!
    var delayMixer: AKDryWetMixer!

    let mic = AKMicrophone()

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Clean tempFiles !
        AKAudioFile.cleanTempDirectory()

        // Session settings
        AKSettings.bufferLength = .medium

        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
        } catch {
            AKLog("Could not set session category.")
        }
        AKSettings.defaultToSpeaker = true

        micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)
        micBooster.gain = 2

        recorder = try! AKNodeRecorder(node: micMixer)

        delay = AKVariableDelay(micBooster)
        delay.rampTime = 1.0
        delay.time = 0.1
        delayMixer = AKDryWetMixer(micBooster, delay)

        AudioKit.output = delayMixer
        do {
            try AudioKit.start()
        } catch {
            debugPrint(error)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player?.stop()
        do {
            try AudioKit.stop()
        } catch {
            debugPrint(error)
        }
    }

    @IBAction func recordStart(_ sender: UIButton) {
        if recorder.isRecording {
            sender.isSelected = false

            if let file = recorder.audioFile {
                playButton.isEnabled = true
                player = AKPlayer(audioFile: file)
            }
            recorder.stop()
        } else {
            do {
                try recorder.record()
                sender.isSelected = true
            } catch {
                debugPrint(error)
            }
        }
    }

    @IBAction func playRecord(_ sender: Any) {
        AudioKit.output = player
        player?.play()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
