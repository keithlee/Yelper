//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Keith Lee on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

struct Section {
    static let deals = 0
    static let distance = 1
    static let sort = 2
    static let categories = 3
}

struct FilterConstants {
    static let distanceExpanded = "distanceExpanded"
    static let distance = "distance"
}

struct DistanceConstants {
    static let auto: (label: String, code: Int?) = ("Auto", nil)
    static let small: (label: String, code: Int?) = ("0.1 miles", 161)
    static let oneMile: (label: String, code: Int?) = ("1 mile", 1609)
    static let fiveMile: (label: String, code: Int?) = ("5 miles", 8045)
    static let twentyMile: (label: String, code: Int?) = ( "20 miles", 32187)
}

struct SortConstants {
    static let bestMatched = (label: "Best Match", code: YelpSortMode.bestMatched)
    static let distance = (label:"Distance", code: YelpSortMode.distance)
    static let highestRated = (label: "Highest Rated", code: YelpSortMode.highestRated)
}

protocol FiltersViewControllerDelegate: class {
    func FiltersViewController(filtersViewController: FiltersViewController, didUpdateFilters updatedFilters: FilterSettings)
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FilterCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func search(_ sender: UIBarButtonItem) {
        delegate?.FiltersViewController(filtersViewController: self, didUpdateFilters: settingsFromFilters())
        dismiss(animated: true, completion: nil)
    }
    weak var delegate: FiltersViewControllerDelegate?
    
    private var filterStates = [String: AnyObject]()
    private var distanceSectionExpanded = false
    private var distanceValue = DistanceConstants.auto.label
    private var sortSectionExpanded = false
    private var sortValue = SortConstants.bestMatched.label
    private var switchStates = [Int: [Int: Bool]]()
    private var categories = [
        ["name" : "Chinese", "code": "chinese"],
        ["name" : "Italian", "code": "italian"],
        ["name" : "Japanese", "code": "japanese"],
        ["name" : "Spanish", "code": "spanish"],
    ]
    private var categoriesDictionary =  [String: Int]()
    
    var filterSettings: FilterSettings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        switchStates = [0: [Int:Bool](), 1: [Int:Bool](), 2: [Int:Bool](), 3: [Int:Bool]()]
        
        for (index, category) in categories.enumerated() {
            categoriesDictionary[category["code"]!] = index
        }
        
        if let filterSettings = filterSettings {
            if let distance = filterSettings.distance {
                distanceValue = convertedDistance(from: distance)
            }
            if let sort = filterSettings.sort {
                sortValue = convertedSort(from: sort)
            }
            if let filterCategories = filterSettings.categories {
                for category in filterCategories {
                    let index = categoriesDictionary[category]!
                    switchStates[Section.categories]?[index] = true
                }
            }
            switchStates[Section.deals]?[0] = filterSettings.deals ?? false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.distance{
            let array = [IndexPath.init(row: 1, section:Section.distance), IndexPath.init(row: 2, section:Section.distance), IndexPath.init(row: 3, section: Section.distance), IndexPath.init(row: 4, section: Section.distance)]
            let cell = tableView.cellForRow(at: indexPath) as! FilterCell
            if distanceSectionExpanded {
                distanceValue = cell.filterLabel.text!
                distanceSectionExpanded = false
                tableView.deleteRows(at: array, with: .automatic)
                tableView.reloadRows(at: [IndexPath.init(row: 0, section: indexPath.section)], with: .automatic)
            } else {
                distanceSectionExpanded = true
                tableView.insertRows(at: array, with: .automatic)
                tableView.reloadRows(at: [IndexPath.init(row: 0, section: indexPath.section)], with: .automatic)
            }
        } else if indexPath.section == Section.sort {
            let array = [IndexPath.init(row: 1, section:Section.sort), IndexPath.init(row: 2, section:Section.sort)]
            let cell = tableView.cellForRow(at: indexPath) as! FilterCell
            if sortSectionExpanded {
                sortValue = cell.filterLabel.text!
                sortSectionExpanded = false
                tableView.deleteRows(at: array, with: .automatic)
                tableView.reloadRows(at: [IndexPath.init(row: 0, section: indexPath.section)], with: .automatic)
            } else {
                sortSectionExpanded = true
                tableView.insertRows(at: array, with: .automatic)
                tableView.reloadRows(at: [IndexPath.init(row: 0, section: indexPath.section)], with: .automatic)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.delegate = self
        
        //Handle in cell?
        
        switch indexPath.section {
        case Section.deals:
            cell.filterLabel.text = "Offering a Deal"
            cell.filterSwitch.isOn = switchStates[indexPath.section]?[indexPath.row] ?? false
        case Section.distance:
            if indexPath.row == 0 {
                cell.accessoryType = .detailButton
            } else {
                cell.accessoryType = .none
            }
            cell.filterSwitch.isHidden = true
            setDistanceLabel(cell: cell, row: indexPath.row)
        case Section.sort:
            cell.filterSwitch.isHidden = true
            if indexPath.row == 0 {
                cell.accessoryType = .detailButton
            } else {
                cell.accessoryType = .none
            }
            cell.filterSwitch.isHidden = true
            setSortLabel(cell: cell, row: indexPath.row)
        case Section.categories:
            cell.filterLabel.text = categories[indexPath.row]["name"]
            cell.filterSwitch.isHidden = false
            cell.filterSwitch.isOn = switchStates[indexPath.section]?[indexPath.row] ?? false
            cell.accessoryType = .none
        default:
            break
        }
        return cell
    }
    
    func setDistanceLabel(cell: FilterCell, row: Int) {
        switch row {
        case 0:
            cell.filterLabel.text = distanceSectionExpanded ? DistanceConstants.auto.label : distanceValue
        case 1:
            cell.filterLabel.text = DistanceConstants.small.label
        case 2:
            cell.filterLabel.text = DistanceConstants.oneMile.label
        case 3:
            cell.filterLabel.text = DistanceConstants.fiveMile.label
        case 4:
            cell.filterLabel.text = DistanceConstants.twentyMile.label
        default:
            cell.filterLabel.text = ""
        }
    }
    
    func setSortLabel(cell: FilterCell, row: Int) {
        switch row {
        case 0:
            cell.filterLabel.text = sortSectionExpanded ? SortConstants.bestMatched.label : sortValue
        case 1:
            cell.filterLabel.text = SortConstants.distance.label
        case 2:
            cell.filterLabel.text = SortConstants.highestRated.label
        default:
            cell.filterLabel.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Section.distance:
            return "Distance"
        case Section.sort:
            return "Sort By" 
        case Section.categories:
            return "Category" 
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.deals:
            return 1
        case Section.distance:
            return distanceSectionExpanded ? 5 : 1
        case Section.sort:
            return sortSectionExpanded ? 3 : 1
        case Section.categories:
            return categories.count
        default:
            return 0
        }
    }
    
    func filterCell(filterCell: FilterCell, switchChangedValue newValue: Bool) {
        let indexPath = tableView.indexPath(for: filterCell)!
        switchStates[indexPath.section]?[indexPath.row] = newValue
    }
    
    
    func settingsFromFilters() -> FilterSettings {
        let filterSettings = FilterSettings()
        
        filterSettings.distance = convertedDistance(from: distanceValue)
        filterSettings.deals = switchStates[Section.deals]?[0] ?? false
        
        var categoriesArray: [String] = [String]()
        for (row, isSelected) in switchStates[Section.categories]! {
            if isSelected {
                categoriesArray.append(categories[row]["code"]!)
            }
        }
        filterSettings.categories = categoriesArray
        filterSettings.sort = convertedSort(from: sortValue)
        
        return filterSettings
    }
    
    
    func convertedDistance(from label: String) -> Int?{
        switch label {
        case DistanceConstants.auto.label:
            return DistanceConstants.auto.code
        case DistanceConstants.small.label:
            return DistanceConstants.small.code
        case DistanceConstants.oneMile.label:
            return DistanceConstants.oneMile.code
        case DistanceConstants.fiveMile.label:
            return DistanceConstants.fiveMile.code
        case DistanceConstants.twentyMile.label:
            return DistanceConstants.twentyMile.code
        default:
            return nil
        }
    }
    
    func convertedDistance(from code: Int) -> String{
        switch code {
        case nil:
            return DistanceConstants.auto.label
        case DistanceConstants.small.code!:
            return DistanceConstants.small.label
        case DistanceConstants.oneMile.code!:
            return DistanceConstants.oneMile.label
        case DistanceConstants.fiveMile.code!:
            return DistanceConstants.fiveMile.label
        case DistanceConstants.twentyMile.code!:
            return DistanceConstants.twentyMile.label
        default:
            return ""
        }
    }
    
    func convertedSort(from code: YelpSortMode) -> String{
        switch code {
        case SortConstants.bestMatched.code:
            return SortConstants.bestMatched.label
        case SortConstants.distance.code:
            return SortConstants.distance.label
        case SortConstants.highestRated.code:
            return SortConstants.highestRated.label
        default:
            return ""
        }
    }
    
    func convertedSort(from label: String) -> YelpSortMode?{
        switch label {
        case SortConstants.bestMatched.label:
            return SortConstants.bestMatched.code
        case SortConstants.distance.label:
            return SortConstants.distance.code
        case SortConstants.highestRated.label:
            return SortConstants.highestRated.code
        default:
            return nil
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
