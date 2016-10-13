//
//  SaveTableViewController.swift
//  VoiceSnap
//
//  Created by Eric Hodgins on 2016-10-10.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit

class SaveTableViewController: UITableViewController {
    
    lazy var saveTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "My New Recording"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    init() {
       super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(SaveTableViewController.cancel))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(SaveTableViewController.save))
        
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.contentView.backgroundColor = UIColor.black
        case (1, 0):
            cell.contentView.addSubview(saveTextField)
            
            NSLayoutConstraint.activate([
                saveTextField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                saveTextField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                saveTextField.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor, constant: 16),
                saveTextField.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor, constant: 20)
            ])
            
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Recording"
        case 1:
            return "Enter Recording Name"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 100
        case (1, 0):
            return tableView.rowHeight
        default:
            return tableView.rowHeight
        }
    }
    
}


extension SaveTableViewController {
    func save() {
        
        if saveTextField.text == "" {
            return
        }
        
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let oldURL = docDir.appendingPathComponent("TempFileName.m4a")
        let newURL = docDir.appendingPathComponent("\(saveTextField.text!).m4a")
        
        do {
            try FileManager.default.moveItem(at: oldURL, to: newURL)
            let _ = Record.record(withName: "\(saveTextField.text!)")
            CoreDataController.sharedInstance.saveContext()
        } catch {
            
        }
        
        showDocumentsDirectory()
        
        dismiss(animated: true, completion: nil)
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SaveTableViewController {
    //helper checks
    func showDocumentsDirectory() {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: nil, options: [])
        for p in directoryContents {
            print(p)
        }
    }
}









































