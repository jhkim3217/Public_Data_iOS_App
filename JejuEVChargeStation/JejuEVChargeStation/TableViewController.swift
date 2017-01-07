//
//  TableViewController.swift
//  JejuEVChargeStation
//
//  Created by Tae Jong Yoo on 2016. 11. 21..
//  Copyright © 2016년 Tae-Jong Yu. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate, UISearchControllerDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tvMain: UITableView!
    
    let filteredAnnotations = [StationPoint]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return annotations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowIndex = indexPath.row
        
        let CellIdentifier = "searchCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: CellIdentifier)
        }

        cell?.textLabel?.text = annotations[rowIndex].title
        cell?.detailTextLabel?.text = annotations[rowIndex].subtitle

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        print("\(cell?.textLabel?.text):\(cell?.detailTextLabel?.text)")
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
