//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Keith Lee on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

enum Section: Int {
    case deals = 0
    case distance = 1
    case sort = 2
    case categories = 3
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func search(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    var expanded: Bool = false
    var filterStates = [String: Bool]()
    
    /*
    Deal -> true
    Distance ->
    Cate
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let array = [IndexPath.init(row: 1, section:1), IndexPath.init(row: 2, section:1)]
            if expanded {
                expanded = false
                tableView.deleteRows(at: array, with: .automatic)
            } else {
                expanded = true
                tableView.insertRows(at: array, with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        
        switch Section(rawValue: indexPath.section)! {
        case .deals:
            cell.filterLabel.text = "Offering a Deal"
        case .distance:
            cell.filterLabel.text = "Auto"
        case .sort:
            cell.filterLabel.text = "Best Match"
        case .categories:
            cell.filterLabel.text = "Category"
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)!{
        case .distance:
            return "Distance"
        case .sort:
            return "Sort By" 
        case .categories:
            return "Category" 
        default:
            return "" 
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)!{
        case .deals:
            return 1
        case .distance:
            return expanded ? 3 : 1
        case .sort:
            return 1
        case .categories:
            return 10
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
