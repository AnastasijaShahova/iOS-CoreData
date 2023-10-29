import UIKit
import CoreData

class DealListTableViewController: UITableViewController {

    var tasks: [Task] = []
    
    private func getContext() ->  NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let sortDescription = NSSortDescriptor(key: "title", ascending: false)
        fetchRequest.sortDescriptors = [sortDescription]

        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    
    @IBAction func deleteAllNotes(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete", message: "Delete all tasks?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default) { action in
            self.deleteTasks()
            self.tableView.reloadData()
        }
        
        let no = UIAlertAction(title: "No", style: .default) { _ in
        }
        
        alertController.addAction(yes)
        alertController.addAction(no)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteTasks() {
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        if let objects = try? context.fetch(fetchRequest) {
            for object in objects {
                context.delete(object)
                tasks.removeAll()
            }
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Task", message: "Please add new task", preferredStyle: .alert)
        
        let saveActrion = UIAlertAction(title: "Save", style: .default) { action in
            let textField = alertController.textFields?.first
            
            if let newTask = textField?.text {
                self.saveTask(withTitle: newTask)
                self.tableView.reloadData()
            }
        }
        
        alertController.addTextField { _ in
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
        }
        
        alertController.addAction(saveActrion)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func saveTask(withTitle title: String) {
        let context = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        
        let taskObject = Task(entity: entity, insertInto: context)
        taskObject.title = title
        taskObject.isFinish = false
        
        do {
            try context.save()
            tasks.append(taskObject)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        
        if task.isFinish {
            cell.backgroundColor = .green
        }

        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = doneAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [done])
    }
    
    func doneAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Done") { [self] (action, view, completion) in
            changeDone(at: indexPath)
            completion(true)
        }
        
        let row = tasks[indexPath.row]
        action.image = UIImage(systemName: "checkmark.square")
        if row.isFinish {
            action.image = UIImage(systemName: "checkmark.square.fill")
            action.backgroundColor = .systemRed

        } else {
            action.backgroundColor = .systemGray
        }
        
        return action
    }
    
    private func changeDone(at indexPath: IndexPath) {
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let title = tasks[indexPath.row].title
        fetchRequest.predicate = NSPredicate(format: "title == %@", title!)
        
        do {
            let results = try context.fetch(fetchRequest)
            tasks[indexPath.row] = results.first!
            tasks[indexPath.row].isFinish = !tasks[indexPath.row].isFinish

            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

}
