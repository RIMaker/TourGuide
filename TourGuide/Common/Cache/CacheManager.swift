//
//  CacheManager.swift
//  TourGuide
//
//  Created by Zhora Agadzhanyan on 06.01.2023.
//

import Foundation

protocol CacheManager {
    func cachedData() -> Places?
    func cache(data: Places?)
    func shouldUpdateData() -> Bool
}

class CacheManagerImpl: CacheManager {
    
    func cachedData() -> Places? {

        guard
            let data = UserDefaults.standard.object(forKey: UserDefaultsKeys.cachedObjectKey.rawValue) as? Data,
            let companyItem = try? JSONDecoder().decode(Places.self, from: data)
        else {
            return nil
        }
        return companyItem
    }
    
    func cache(data: Places?) {
        if let data = data, let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.cachedObjectKey.rawValue)
            UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastUpdatingDateKey.rawValue)
        }
    }
    
    func shouldUpdateData() -> Bool {
        let lastUpdatingDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastUpdatingDateKey.rawValue) as? Date
        let cachedData = cachedData()
        let nowDate = Date()
        if let lastUpdatingDate = lastUpdatingDate, let _ = cachedData {
            if nowDate.timeIntervalSince(lastUpdatingDate) >= 3600 {
                return true
            }
            return false
        }
        return true
    }
}
