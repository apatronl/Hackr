//
//  SettingsViewController.swift
//  Hackr
//
//  Created by Alejandrina Patron on 3/4/19.
//  Copyright © 2019 Alejandrina Patron. All rights reserved.
//

import UIKit

final class SettingsViewController: UIViewController {

  // MARK: - Constants

  enum Constants {
    static let interfaceTitle = "Interface"
    static let hackrSettingNames = ["Dark Mode"]
  }

  // MARK: - Private Properties

  private let tableView = UITableView(frame: .zero, style: .grouped)

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.frame = view.bounds
    tableView.tableHeaderView =
      UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    tableView.tableFooterView = UIView(frame: .zero)
    tableView.dataSource = self
    tableView.delegate = self
    view.addSubview(tableView)

    let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                     target: self,
                                     action: #selector(doneButtonTapped))
    doneButton.tintColor = UIColor.hackerNewsOrange
    navigationItem.rightBarButtonItem = doneButton
  }

  // MARK: - Private

  private func setUpDarkModeSwitch() -> UISwitch {
    let switchButton = UISwitch(frame: .zero)
    switchButton.onTintColor = UIColor.hackerNewsOrange
    switchButton.isOn = DarkModeController.getDarkModeState() == .on
    switchButton.addTarget(self, action: #selector(darkModeSwitchTapped(_:)), for: .valueChanged)
    return switchButton
  }

  @objc private func doneButtonTapped() {
    dismiss(animated: true, completion: nil)
  }

  @objc private func darkModeSwitchTapped(_ sender: UISwitch) {
    let state = sender.isOn ? DarkModeState.on : DarkModeState.off
    DarkModeController.setDarkModeState(state)
  }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return Constants.interfaceTitle
    default:
      return nil
    }
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return Constants.hackrSettingNames.count
    default:
      return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
    cell.textLabel?.text = Constants.hackrSettingNames[indexPath.row]
    switch indexPath.row {
    case 0:
      cell.accessoryView = setUpDarkModeSwitch()
    default:
      break
    }
    return cell
  }
}
