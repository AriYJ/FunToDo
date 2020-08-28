//
//  ViewController.swift
//  Todoey
//
//  Created by Ari Jane on 5/23/20.
//  Copyright © 2020 Ari Jane. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    var navAppearance: UINavigationBarAppearance?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //customize color of the nav bar when it's large
        //let navBarAppearance = UINavigationBarAppearance()
        if let navBarAppearance = navAppearance {
            //navBarAppearance.configureWithOpaqueBackground() //commenting out bcs we got the setting from CategoryViewController
            
            if let colorHex = selectedCategory?.color {
//                guard let navBar = navigationController?.navigationBar else {
//                    fatalError("Navigation controller doesn't exist")
//                }
                title = selectedCategory!.name
                if let navColor = UIColor(hexString: colorHex) {
                    navBarAppearance.backgroundColor = navColor //nav bar color
                    navigationController?.navigationBar.tintColor = ContrastColorOf(navColor, returnFlat: true) //navigation item color
                    //searchBar.backgroundImage = UIImage()//trying to get rid of the border of the search bar
                    searchBar.barTintColor = navColor //search bar color
                    navBarAppearance.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(navColor, returnFlat: true)]
                }
            }
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
    }
    
    //MARK: - Tablevivew Datasource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            let darkenPercentage = (todoItems!.count > 1) ? (CGFloat(indexPath.row) + CGFloat(0.4))/CGFloat(todoItems!.count):(CGFloat(indexPath.row) + CGFloat(0.2))/CGFloat(todoItems!.count)
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: darkenPercentage) { //selectedCategory can be force unwrapped bcs we already checked todoItems isn't nil above, and todoItems comes from selectedCategory. We added ? after UIColor to check and see if it's nil (in case a invalid string is passed in as hex string)
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }

            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var alertTextField = UITextField() //to store input in alart textField
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Create new item"
            alertTextField = textField
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if alertTextField.text != "" {  //bcs the text of a text field is never nil, if it's empty it's an empty string
                
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = alertTextField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print("Error saving new items, \(error)")
                    }
                }
            }
            self.tableView.reloadData()
        }
        alert.addAction(action)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Delete from Swiping
    
    override func updateModel(at indexPath: IndexPath) {
        do {
            try realm.write{
                if let itemToDelete = todoItems?[indexPath.row] {
                    realm.delete(itemToDelete)
                }
            }
        } catch {
            print("Error deleting, \(error)")
        }
        
    }
    
    //MARK: - Model Manipulation Methods

    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async { //even when there are other background tasks, we need this to happen
                searchBar.resignFirstResponder() //go back to original state before it was activated
            }
        }
    }
}
