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
    
    private func showAlert(for list: Task? = nil) {
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
        
        show(createListAlert, sender: nil)
    }
    
    private func saveNewItem(with name: String) {
        CoreDataService.shared.write {
            let object = CoreDataService.shared.create(Task.self) { object in
                object.title = name
                object.dateOfCreation = .init()
                object.task = self.task
//                object.subtasks?.addingObjects(from: self.task)
            }
        }
    }
    
    @IBAction private func new() {
        showAlert()
    }
}

extension ItemsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksList.count
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
