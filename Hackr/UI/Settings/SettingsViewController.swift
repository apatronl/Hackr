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
    static let defaultAppIconName = "AppIcon-Default"
    static let darkAppIconName = "AppIcon-Dark"
    static let hackrSourceCodeUrl = URL(string: "https://github.com/apatronl/Hackr")
    static let appearanceTitle = "Appearance"
    static let darkMode = "Dark Mode"
    static let darkAppIcon = "Dark App Icon"
    static let appearanceSettingNames = [Constants.darkMode, Constants.darkAppIcon]
    static let sourcesSettingsNames = ["Source Code"]
    static let sections = 2
  }

  // MARK: - Private Properties

  private let tableView = UITableView(frame: .zero, style: .grouped)
  private var darkModeState: DarkModeState = .off

  private let darkModeSwitch: UISwitch = {
    let switchButton = UISwitch(frame: .zero)
    switchButton.onTintColor = UIColor.hackerNewsOrange
    switchButton.isOn = DarkModeController.getDarkModeState() == .on
    switchButton.addTarget(self, action: #selector(darkModeSwitchTapped(_:)), for: .valueChanged)
    return switchButton
  }()

  private let darkAppIconSwitch: UISwitch = {
    let switchButton = UISwitch(frame: .zero)
    switchButton.onTintColor = UIColor.hackerNewsOrange
    if let appIconName = UIApplication.shared.alternateIconName,
           appIconName == Constants.darkAppIconName {
      switchButton.isOn = true
    }
    switchButton.addTarget(self, action: #selector(darkAppIconSwitchTapped(_:)), for: .valueChanged)
    return switchButton
  }()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    DarkModeController.addListener(self)
    darkModeState = DarkModeController.getDarkModeState()
    setUpViewForDarkModeState(darkModeState)
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

  private func setUpViewForDarkModeState(_ state: DarkModeState) {
    view.backgroundColor = state == .on ? UIColor.black : UIColor.white
    navigationController?.navigationBar.barStyle = state == .on ? .black : .default
    navigationController?.view.backgroundColor =
      state == .on ? UIColor.darkModeGray : UIColor.white
    tableView.backgroundColor = state == .on ? UIColor.darkModeGray : UIColor.white
  }

  @objc private func doneButtonTapped() {
    dismiss(animated: true, completion: nil)
  }

  @objc private func darkModeSwitchTapped(_ sender: UISwitch) {
    let state = sender.isOn ? DarkModeState.on : DarkModeState.off
    DarkModeController.setDarkModeState(state)
  }

  @objc private func darkAppIconSwitchTapped(_ sender: UISwitch) {
    guard UIApplication.shared.supportsAlternateIcons else { return }
    let iconName = sender.isOn ? Constants.darkAppIconName : Constants.defaultAppIconName
    UIApplication.shared.setAlternateIconName(iconName) { (error) in
      guard let error = error else { return }
      print("App icon change failed: \(error.localizedDescription)")
    }
  }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    switch indexPath.section {
    case 1:
      guard let safariView =
        safariViewForItem(at: Constants.hackrSourceCodeUrl, defaultUrl: nil) else { return }
      present(safariView, animated: true, completion: nil)
    default:
      break
    }
  }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return Constants.sections
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return Constants.appearanceTitle
    default:
      return nil
    }
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return Constants.appearanceSettingNames.count
    case 1:
      return Constants.sourcesSettingsNames.count
    default:
      return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
    cell.textLabel?.textColor = darkModeState == .on ? .white : .black
    cell.backgroundColor = darkModeState == .on ? UIColor.darkModeGray : .white
    switch indexPath.section {
    case 0:
      cell.textLabel?.text = Constants.appearanceSettingNames[indexPath.row]
      cell.selectionStyle = .none
      switch indexPath.row {
      case 0:
        cell.accessoryView = darkModeSwitch
      case 1:
        cell.accessoryView = darkAppIconSwitch
      default:
        break
      }
    case 1:
      cell.textLabel?.text = Constants.sourcesSettingsNames[indexPath.row]
      cell.accessoryType = .disclosureIndicator
    default:
      break
    }
    return cell
  }
}

// MARK: - DarkModeDelegate

extension SettingsViewController: DarkModeDelegate {
  func darkModeStateDidChange(_ state: DarkModeState) {
    darkModeState = state
    tableView.reloadData()
    setUpViewForDarkModeState(state)
  }
}
