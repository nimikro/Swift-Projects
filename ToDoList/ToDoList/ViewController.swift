//
//  ViewController.swift
//  ToDoList
//
//  Created by Nikolaos Mikrogeorgiou on 14/11/21.
//

import UIKit

// Added a navigation controller to the main storyboard and add prefer large title
// to the navigation bar
// Add uitableviewdatasource to supply the tableview functions with data
class ViewController: UIViewController, UITableViewDataSource {

    // UI component to show a list of rows, each one holding an entry
    private let table: UITableView = {
        let table = UITableView()
        // Define cellForRowAt tableview func with identifier
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    // Hold all notes in an array of strings
    var items = [String]()
    
    // Set items to whatever is in the saved items array, else return an empty array
    override func viewDidLoad() {
        super.viewDidLoad()
        self.items = UserDefaults.standard.stringArray(forKey: "items") ?? []
        // Add a title at the top as a subview with self as a data source
        title = "To Do List"
        view.addSubview(table)
        table.dataSource = self // <- view controller will provide data
                                // by using UITableViewDataSource +2 func below
        // Add + button on top right
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    // Function for creating an alert when taping the + button
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Item", message: "Enter new to do list item!", preferredStyle: .alert)
        // Handler for 2nd action -> adds a text field to the alert
        alert.addTextField{ field in field.placeholder = "Enter item..." }
        // Add cancel button when creating a note
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // Add a done button
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (_) in if let field = alert.textFields?.first {
            if let text = field.text, !text.isEmpty {
                // Enter new to do list item (always in main.async)
                DispatchQueue.main.async {
                    // Add new entry to curent items
                    var currentItems = UserDefaults.standard.stringArray(forKey: "items") ?? []
                    currentItems.append(text)
                    UserDefaults.standard.set(currentItems, forKey: "items")
                    // Add note to items array and reload the table
                    self?.items.append(text)
                    self?.table.reloadData()
                }
            }
        }
        }))
        // present call for the alert
        present(alert, animated:  true)
    }
    
    // Create table frame equal to the entire view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    // Number of rows is the number of the items array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // Creates a cell with ID of cell and sets the text to the end of items
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }


}

