//
//  DemoListViewController.swift
//  AudioKitExamples
//
//  Created by yin.yan on 2018/05/29.
//  Copyright © 2018年 yin.yan. All rights reserved.
//

import UIKit

class DemoListViewController: UITableViewController {

    fileprivate var dataSource: [String: String] = [
        "Player Demo"  : "showPlayerDemo",
        "Record Demo"  : "showRecordDemo",
        "KARAOKE Demo" : "showKaraokeDemo",
        ]
    fileprivate lazy var keys: [String] = {
        return Array(dataSource.keys)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = keys[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let segueIdentifier = dataSource[keys[indexPath.row]] {
            self.performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
    }
}
