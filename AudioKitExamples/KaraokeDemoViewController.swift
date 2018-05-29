//
//  KaraokeDemoViewController.swift
//  AudioKitExamples
//
//  Created by yin.yan on 2018/05/29.
//  Copyright © 2018年 yin.yan. All rights reserved.
//

import UIKit
import AudioKit

class KaraokeDemoViewController: UIViewController {

    var micMixer: AKMixer!
    var recorder: AKNodeRecorder!
    var bgmPlayer: AKPlayer!
    var player: AKPlayer!
    var tape: AKAudioFile!
    var micBooster: AKBooster!
    var moogLadder: AKMoogLadder!
    var mainMixer: AKMixer!
    var delay: AKVariableDelay!
    var delayMixer: AKDryWetMixer!

    let mic = AKMicrophone()
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var bgmVolumnSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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

        // Patching
        micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)

        delay = AKVariableDelay(micBooster)
        delay.rampTime = 0.5
        delay.feedback = 0.5
        delay.time = 0.1
        delayMixer = AKDryWetMixer(micBooster, delay)

        // Will set the level of microphone monitoring
        micBooster.gain = 2
        recorder = try? AKNodeRecorder(node: micMixer)
        if let url = Bundle.main.url(forResource: "1391843923", withExtension: "mp3"),
            let file = try? AKAudioFile(forReading: url) {
            bgmPlayer = AKPlayer(audioFile: file)
        }
        bgmPlayer.isLooping = true
        bgmPlayer.completionHandler = playingEnded

        moogLadder = AKMoogLadder(bgmPlayer)

        mainMixer = AKMixer(moogLadder, delayMixer)

        AudioKit.output = mainMixer
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player?.stop()
        bgmPlayer?.stop()
        do {
            try AudioKit.stop()
        } catch {
            debugPrint(error)
        }
    }

    func playingEnded() {

    }

    @IBAction func bgmVolumnChanged(_ sender: UISlider) {
        bgmPlayer.volume = Double(sender.value)
    }

    @IBAction func recordStart(_ sender: UIButton) {
        if !recorder.isRecording {
            bgmPlayer.play()
            do {
                try recorder.record()
            } catch {
                debugPrint(error)
            }
            sender.isSelected = true
        } else {
            bgmPlayer.stop()
            if let file = recorder.audioFile {
                player = AKPlayer(audioFile: file)
                playButton.isEnabled = file.duration > 0
            }
            recorder.stop()
        }
    }

    @IBAction func playRecord(_ sender: Any) {
        do {
            try AudioKit.stop()
        } catch {
            debugPrint(error)
        }
        mic.disconnectOutput()

        delay = AKVariableDelay(player)
        delay.rampTime = 0.5
        delay.feedback = 0.5
        delay.time = 0.1
        delayMixer = AKDryWetMixer(player, delay)

        moogLadder = AKMoogLadder(bgmPlayer)
        mainMixer = AKMixer(delayMixer, moogLadder)
        AudioKit.output = mainMixer

        do {
            try AudioKit.start()
        } catch {
            debugPrint(error)
        }

        player.volume = 1.0
        bgmPlayer.startTime = 0
        bgmPlayer.play()
        player.play()
    }

}
