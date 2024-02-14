//
//  GeofencingListViewController.swift
//  Wifinity
//
//  Created by Apple on 03/01/24.
//

import UIKit

class GeofencingListViewController: BaseController, UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "GeoCell", for: indexPath) as! GeoListTableViewCell
        cell.loaddata()
        return cell
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
       }

    @IBOutlet weak var listViewTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Geo Fencing"
        subTitle = nil
        listViewTableView.register(UINib(nibName: "GeoListTableViewCell", bundle: nil), forCellReuseIdentifier: "GeoCell")
      //  listViewTableView.register(GeoListTableViewCell.self, forCellReuseIdentifier: "GeoCell")
        listViewTableView.dataSource = self
        listViewTableView.delegate = self
     
        listViewTableView.reloadData()
        listViewTableView.rowHeight = UITableView.automaticDimension
        listViewTableView.estimatedRowHeight = 70.0
    }
    


}
