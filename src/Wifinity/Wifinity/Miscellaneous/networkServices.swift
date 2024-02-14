//
//  networkServices.swift
//  Wifinity
//
//  Created by Apple on 17/01/24.
//

import Foundation
protocol DataService {
    func fetchData(completion: @escaping (Result<Data, Error>) -> Void)
}

class DataManager {
    let dataService: DataService

    init(dataService: DataService) {
        self.dataService = dataService
    }

    func performDataFetch() {
        dataService.fetchData { result in
            // Handle the result
        }
    }
}
