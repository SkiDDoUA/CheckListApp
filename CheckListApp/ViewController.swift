//
//  ViewController.swift
//  CheckListApp
//
//  Created by Anton Kolesnikov on 23.11.2022.
//

import UIKit
import CoreData

final class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    var selectedRows = [IndexPath]()
    var currentList: [Task] = []
    var taskForSegue: Task?
    var isSubtasks = false
    
    weak var task: Task? {
        didSet {
            currentList = (task?.subtasks?.allObjects as? [Task])?.sorted {$0.dateOfCreation! < $1.dateOfCreation!} ?? []
            isSubtasks = true
        }
    }
    
    //MARK: - Add Sorting
    var tasksList: [Task] = [] {
        didSet {
            currentList = self.tasksList
            isSubtasks = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        if !isSubtasks {
            tasksList = CoreDataService.shared.fetch(Task.self, predicate: NSPredicate(format: "task == nil"))
        }
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
                    if self!.isSubtasks {
                        self?.saveNewSubtask(with: name)
                    } else {
                        self?.saveNewTask(with: name)
                    }
//                    self?.tableView.reloadData()
//                    DispatchQueue.main.async {
//                        self?.tableView.reloadData()
//                    }
                } else {
                    CoreDataService.shared.write {
                        list?.title = name
//                        self?.tableView.reloadData()
                    }
//                    self?.tableView.reloadData()
                }
//                self?.tableView.reloadData()
            }
        })
        
        present(createListAlert, animated: true, completion: nil)
    }
    
    private func showAlertEditNote(for list: Task? = nil) {
        let editNoteAlert = UIAlertController(title: "Edit note!", message: "Write note text", preferredStyle: .alert)
        editNoteAlert.addTextField()
        editNoteAlert.textFields?.first?.text = list?.note
        
        editNoteAlert.addAction(.init(title: "Save", style: .default) { _ in
            if let note = editNoteAlert.textFields?.first?.text {
                CoreDataService.shared.write {
                    list?.note = note
                }
                self.tableView.reloadData()
            }
        })
        
        present(editNoteAlert, animated: true, completion: nil)
    }
    
    private func saveNewTask(with name: String) {
        CoreDataService.shared.write {
            let object = CoreDataService.shared.create(Task.self) { object in
                object.title = name
                object.dateOfCreation = .init()
            }
            
            tasksList.append(object)
        }
        
//        tableView.reloadData()

    }
    
    private func saveNewSubtask(with name: String) {
        CoreDataService.shared.write {
            CoreDataService.shared.create(Task.self) { object in
                object.title = name
                object.dateOfCreation = .init()
                object.task = self.task
            }
        }
        
//        tableView.reloadData()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? ViewController)?.task = taskForSegue
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentList.count == 0 {
            tableView.setEmptyView(title: "My To Do.", message: "Add new Task.")
        }
        else {
            tableView.restore()
        }
        
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        if let cell = cell as? TaskTableViewCell {
            cell.taskLabel?.text = currentList[indexPath.row].title
            cell.noteLabel?.text = "Note: \(currentList[indexPath.row].note ?? "")"
        }
        
        if let buttonTapped = cell.contentView.viewWithTag(1) as? UIButton {
            buttonTapped.addTarget(self, action: #selector(checkboxTapped(_ :)), for: .touchUpInside)
            
            if currentList[indexPath.row].done == true {
                buttonTapped.isSelected = true
            } else {
                buttonTapped.isSelected = false
            }
        }
        
        return cell
    }
    
    @objc func checkboxTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        let point = sender.convert(CGPoint.zero, to: tableView)
        let tableIndexPath = tableView.indexPathForRow(at: point)
        let taskToCheck = currentList[tableIndexPath!.row]
        
        var checked = taskToCheck.done
        if checked == true {
            checked = false
        } else {
            checked = true
        }
        
        if isSubtasks {
            CoreDataService.shared.write {
                taskToCheck.done = checked
            }
        }
        
        tableView.reloadRows(at: [tableIndexPath!], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var objectToRemove = currentList.remove(at: indexPath.row)
            if isSubtasks {
                objectToRemove = currentList[indexPath.row]
            }
            
            CoreDataService.shared.write {
                CoreDataService.shared.delete(objectToRemove)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        showAlertEditNote(for: currentList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        taskForSegue = currentList[indexPath.row]
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
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
