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
    static let hackrSourceCodeUrl = URL(string: "https://github.com/apatronl/Hackr")
    static let interfaceTitle = "Interface"
    static let interfaceSettingNames = ["Dark Mode"]
    static let sourcesSettingsNames = ["Source Code"]
    static let sections = 2
  }

  // MARK: - Private Properties

  private let tableView = UITableView(frame: .zero, style: .grouped)
  private var darkModeState: DarkModeState = .off

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

  private func setUpDarkModeSwitch() -> UISwitch {
    let switchButton = UISwitch(frame: .zero)
    switchButton.onTintColor = UIColor.hackerNewsOrange
    switchButton.isOn = DarkModeController.getDarkModeState() == .on
    switchButton.addTarget(self, action: #selector(darkModeSwitchTapped(_:)), for: .valueChanged)
    return switchButton
  }

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
      return Constants.interfaceTitle
    default:
      return nil
    }
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return Constants.interfaceSettingNames.count
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
    // NOTE: - If more rows are added to one of these sections, then we also need to check
    // indexPath.row when creating the cell
    switch indexPath.section {
    case 0:
      cell.textLabel?.text = Constants.interfaceSettingNames[indexPath.row]
      cell.accessoryView = setUpDarkModeSwitch()
      cell.selectionStyle = .none
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
