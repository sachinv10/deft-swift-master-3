//
//  SharedFunction.swift
//  Wifinity
//
//  Created by Apple on 01/07/22.
//

import UIKit

class SharedFunction: NSObject {
    static var shared :SharedFunction = {
        return SharedFunction()
    }()
    
    
}

extension SharedFunction{
    func gotoTimetampTodayConvert(time: Double) -> String {
        let timestamp = NSDate().timeIntervalSince1970
        let diff = timestamp - time
        let myTimeInterval = TimeInterval(diff)
        let minute = myTimeInterval / 60
        let hours = minute / 60
        let day = hours / 24
        let month = day / 30
        let year = month / 12
        if myTimeInterval < 60{
            return "a few seconds ago"
        }else if minute < 60{
            return "\(String(Int(minute))) Minute ago"
        }else if hours <= 24{
            return "\(String(Int(hours))) hours ago"
        }else if day < 31 {
            return "\(String(Int(day))) day ago"
        }else if month < 12 {
            return "\(String(Int(month))) month ago"
        }else{
            return "\(String(Int(year))) year ago"
        }
    }
    
    func timeStampToDate(time: Int)-> String{
        let timestamp: TimeInterval = TimeInterval(time / 1000)
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    func getCurrentDateandTime()-> String{
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: currentDate)
        return formattedDate
    }
    func timeStampToOnlyDate(time: Int)-> String{
        let timestamp: TimeInterval = TimeInterval(time / 1000)
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}
extension SharedFunction{
    //MARK: - remove string paranthesis
    func removeStringInParentheses(input: String) -> String {
        let regex = try! NSRegularExpression(pattern: "\\([^)]*\\)")
        let range = NSRange(location: 0, length: input.utf16.count)
        
        var result = regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "")
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return result
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
  

}


class AutoSizeFlowLayout: UICollectionViewFlowLayout {
   override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
       return true
   }
var numberOfColumns = 100
   override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
       let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
       if let collectionView = collectionView {
           let contentWidth = collectionView.frame.width - sectionInset.left - sectionInset.right
           let estimatedWidth = self.estimatedItemSize.width
           let availableWidth = contentWidth - (minimumInteritemSpacing * CGFloat(numberOfColumns - 1))
           let itemWidth = min(availableWidth, estimatedWidth)
           attributes?.frame.size.width = itemWidth
       }
       return attributes
   }
}
