//
//  ItemsViewController.swift
//  CheckListApp
//
//  Created by Anton Kolesnikov on 23.11.2022.
//

import UIKit

final class ItemsViewController: UIViewController {
    weak var task: Task?
    
    @IBOutlet weak var tableView: UITableView!
        
    var tasksList: [Task] {
        (task?.subtasks?.allObjects as? [Task])?.sorted {$0.dateOfCreation! < $1.dateOfCreation! } ?? []
    }
    
    func configure(for taskData: Task) {
        task = taskData
        
    }
    
    private func showAlertNewTask(for list: Task? = nil) {
        let createListAlert = UIAlertController(title: "New!", message: "Add item to \(list?.title ?? "list")", preferredStyle: .alert)
        createListAlert.addTextField()
        createListAlert.textFields?.first?.text = list?.title
        
        createListAlert.addAction(.init(title: "Save", style: .default) { [weak self] _ in
            if let name = createListAlert.textFields?.first?.text {
                if list == nil {
                    self?.saveNewItem(with: name)
                } else {
                    CoreDataService.shared.write {
                        list?.title = name
                    }
                }
                self?.tableView.reloadData()
            }
        })
        
        present(createListAlert, animated: true, completion: nil)
    }
    
    private func saveNewItem(with name: String) {
        CoreDataService.shared.write {
            let object = CoreDataService.shared.create(Task.self) { object in
                object.title = name
                object.dateOfCreation = .init()
                object.task = self.task
            }
        }
    }
    
    @IBAction private func new() {
        showAlertNewTask()
    }
    
}

extension ItemsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasksList.count == 0 {
            tableView.setEmptyView(title: "You don't have any tasks.", message: "Add new Task.")
        }
        else {
            tableView.restore()
        }
        return tasksList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "id")
        
        cell.textLabel?.text = tasksList[indexPath.row].title
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let objectToRemove = items.remove(at: indexPath.row)
//            CoreDataService.shared.write {
//                CoreDataService.shared.delete(objectToRemove)
//            }
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        showAlert(for: items[indexPath.row])
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "openList", sender: items[indexPath.row])
//    }
}


extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
