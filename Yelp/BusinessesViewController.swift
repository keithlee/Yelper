//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, FiltersViewControllerDelegate{
    
    var businesses: [Business]!
    
    @IBOutlet weak var tableView: UITableView!
    let searchBar = UISearchBar()
    var filterSettings = FilterSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        Business.searchWithTerm(term: searchBar.text!, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            //Perform selector needed to resign first responder
            searchBar.performSelector(onMainThread: #selector(resignFirstResponder), with: nil, waitUntilDone: false)
            Business.searchWithTerm(term: "",
                                    sort: filterSettings.sort,
                                    categories: filterSettings.categories,
                                    deals: filterSettings.deals ?? true,
                                    distance: filterSettings.distance)
                                    { (businesses: [Business]?, error: Error?) -> Void in
                                        if let businesses = businesses {
                                            self.businesses = businesses
                                            self.tableView.reloadData()
                                        }
                                    }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        Business.searchWithTerm(term: searchBar.text!,
                                sort: filterSettings.sort,
                                categories: filterSettings.categories,
                                deals: filterSettings.deals ?? true,
                                distance: filterSettings.distance)
                                { (businesses: [Business]?, error: Error?) -> Void in
                                    if let businesses = businesses {
                                        self.businesses = businesses
                                        self.tableView.reloadData()
                                    }
                                }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        
        return cell
    }
    
    func FiltersViewController(filtersViewController: FiltersViewController, didUpdateFilters updatedFilters: FilterSettings) {
        filterSettings = updatedFilters
        Business.searchWithTerm(term: searchBar.text!,
                                sort: filterSettings.sort,
                                categories: filterSettings.categories,
                                deals: filterSettings.deals,
                                distance: filterSettings.distance)
                                { (businesses: [Business]?, error: Error?) -> Void in
                                    if let businesses = businesses {
                                        self.businesses = businesses
                                        self.tableView.reloadData()
                                    }
                                }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "FilterSegue" {
            let filterNav = segue.destination as! UINavigationController
            let fvc = filterNav.topViewController as! FiltersViewController
            fvc.filterSettings = filterSettings
            fvc.delegate = self
        }
     }
    
}
