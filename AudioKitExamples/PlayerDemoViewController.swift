//
//  PlayerDemoViewController.swift
//  AudioKitExamples
//
//  Created by yin.yan on 2018/05/29.
//  Copyright © 2018年 yin.yan. All rights reserved.
//

import UIKit
import AudioKit

class PlayerDemoViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    fileprivate var player: AKPlayer!
    fileprivate var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        guard
            let url = Bundle.main.url(forResource: "1391843923", withExtension: "mp3"),
            let file = try? AKAudioFile(forReading: url) else {
                fatalError("load audio file error")
        }

        try? AKSettings.setSession(category: .playback)

        slider.minimumValue = 0
        slider.maximumValue = Float(file.duration)

        player = AKPlayer(audioFile: file)
        player.completionHandler = playingEnded

        AudioKit.output = player
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkProgress), userInfo: nil, repeats: true)
        do {
            try AudioKit.start()
        } catch {
            debugPrint(error)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.stop()
        do {
            try AudioKit.stop()
        } catch {
            debugPrint(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func playingEnded() {

    }

    @objc dynamic func checkProgress() {
        slider.value = Float(player.currentTime)
    }

    @IBAction func progressChanged(_ sender: UISlider) {
        let startTime = Double(sender.value)
        if player.isPlaying {
            player.setPosition(startTime)
        } else {
            player.startTime = startTime
        }
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        if player.isPlaying {
            sender.isSelected = false
            player.pause()
        } else {
            player.play()
            sender.isSelected = true
        }
    }
}
