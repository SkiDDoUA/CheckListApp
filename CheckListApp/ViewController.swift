//
//  ViewController.swift
//  CheckListApp
//
//  Created by Anton Kolesnikov on 23.11.2022.
//

import UIKit
import CoreData

final class ViewController: UIViewController {
    var tasksList: [Task] = []
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var predicate: NSPredicate?
        tasksList = CoreDataService.shared.fetch(Task.self, predicate: predicate)
    }
    
    @IBAction private func new() {
        showAlertNewTask()
    }

    private func showAlertNewTask(for list: Task? = nil) {
        let createListAlert = UIAlertController(title: "New!", message: "Write list title", preferredStyle: .alert)
        createListAlert.addTextField()
        createListAlert.textFields?.first?.text = list?.title
        
        createListAlert.addAction(.init(title: "Save", style: .default) { [weak self] _ in
            if let name = createListAlert.textFields?.first?.text {
                if list == nil {
                    self?.saveNewList(with: name)
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
    
    private func showAlertEditNote(for list: Task? = nil) {
        let editNoteAlert = UIAlertController(title: "Edit note!", message: "Write note text", preferredStyle: .alert)
        editNoteAlert.addTextField()
        editNoteAlert.textFields?.first?.text = list?.note
        
        editNoteAlert.addAction(.init(title: "Save", style: .default) { [weak self] _ in
            if let note = editNoteAlert.textFields?.first?.text {
                CoreDataService.shared.write {
                    list?.note = note
                }
            }
        })
        
        show(editNoteAlert, sender: nil)
    }
    
    private func saveNewList(with name: String) {
        CoreDataService.shared.write {
            let object = CoreDataService.shared.create(Task.self) { object in
                object.title = name
                object.dateOfCreation = .init()
            }
            
            tasksList.append(object)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? ItemsViewController)?.task = sender as? Task
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "id")
        cell.textLabel?.text = tasksList[indexPath.row].title
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let objectToRemove = tasksList.remove(at: indexPath.row)
            CoreDataService.shared.write {
                CoreDataService.shared.delete(objectToRemove)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        showAlertEditNote(for: tasksList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openList", sender: tasksList[indexPath.row])
    }
    
}


