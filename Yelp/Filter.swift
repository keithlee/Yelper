//
//  Filter.swift
//  Yelp
//
//  Created by Keith Lee on 10/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import Foundation

class Filter: NSObject {
    private let distanceSectionExpanded: Bool = false
    
    func distanceSectionRows() -> Int {
        return distanceSectionExpanded ? 5 : 1
    }
}
