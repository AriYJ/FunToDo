//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ari Jane on 5/23/20.
//  Copyright © 2020 Ari Jane. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm() //failure of initializing realm could only happen the first time
    
    var categories: Results<Category>? //This auto-update so we don't need to append new results to it
    
    let navBarAppearance = UINavigationBarAppearance()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //customize color of the nav bar when it's large
        //let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white] //need this when we scroll down and title becomes small
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor.systemBlue
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }

    
    //MARK: - TableView Datasource Methods
    /*override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }*/
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) //set up default swipe cell so that we can modify it. Bcs the original function returns a cell, we have to use a variable to get it
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            if let categoryColor = UIColor(hexString: category.color) {
                cell.backgroundColor = categoryColor
                cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            }
        }
                
        return cell
    }
     
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row] //passing on selected category to load items
            destinationVC.navAppearance = navBarAppearance
        }
    }
    
    
    //MARK: - Data Manipulation Methods
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self) //retrieving all data in Category from Realm
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        do {
            try self.realm.write {
                if let categoryForDeletion = self.categories?[indexPath.row] {
                    self.realm.delete(categoryForDeletion)
                }
            }
        } catch {
            print("Error deleting, \(error)")
        }
    }
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var alertTextField = UITextField()
        let alert = UIAlertController(title: "Add category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Category name"
            alertTextField = textField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if alertTextField.text != "" {
                
                let newCategory = Category()
                newCategory.name = alertTextField.text!
                newCategory.color = UIColor.randomFlat().hexValue()
                self.save(category: newCategory)
            }
        }
        alert.addAction(action)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
}
