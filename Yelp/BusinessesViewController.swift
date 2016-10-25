//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import FTIndicator

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
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        Business.searchWithTerm(term: searchBar.text!, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        })
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        search(refreshControl.endRefreshing)
    }
    
    func search(_ callback: @escaping (() -> Void) = {}) {
        FTIndicator.showProgressWithmessage("")
        Business.searchWithTerm(term: searchBar.text!,
                                sort: filterSettings.sort,
                                categories: filterSettings.categories,
                                deals: filterSettings.deals,
                                distance: filterSettings.distance)
                                { (businesses: [Business]?, error: Error?) -> Void in
                                    if let businesses = businesses {
                                        self.businesses = businesses
                                        self.tableView.reloadData()
                                        FTIndicator.dismissProgress()
                                        callback()
                                    }
                                }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            //Perform selector needed to resign first responder
            searchBar.performSelector(onMainThread: #selector(resignFirstResponder), with: nil, waitUntilDone: false)
            search()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        FTIndicator.showProgressWithmessage("")
        search()
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
        cell.selectionStyle = .none
        
        return cell
    }
    
    func FiltersViewController(filtersViewController: FiltersViewController, didUpdateFilters updatedFilters: FilterSettings) {
        filterSettings = updatedFilters
        search()
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
