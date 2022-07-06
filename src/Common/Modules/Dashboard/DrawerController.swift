//
//  DrawerController.swift
//  DEFT
//
//  Created by Rupendra on 21/08/20.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit

class DrawerController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var menuTableView: AppTableView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var emailAddressLabel: UILabel!
    
    var isExpanded :Bool = false
    
    var snapshotView :UIView?
    
    fileprivate var menus = Array<Menu>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = false
        self.view.layer.masksToBounds = false
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowRadius = 10
        self.view.layer.shadowOpacity = 0.3
        
        self.iconImageView.layer.masksToBounds = false
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.height / 2.0
        self.iconImageView.layer.borderWidth = 1.0
        self.iconImageView.layer.borderColor = UIColor.darkGray.cgColor
        
        let aTableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.menuTableView.frame.size.width, height: 19.0))
        let aLabel = UILabel()
        aLabel.font = UIFont.systemFont(ofSize: 10.0)
        aLabel.textColor = UIColor.gray
        aLabel.textAlignment = NSTextAlignment.center
        aLabel.text = String(format: "v%@ (%@)", (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""), (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""))
        aTableFooterView.addSubview(aLabel)
        self.menuTableView.tableFooterView = aTableFooterView
        
        aLabel.translatesAutoresizingMaskIntoConstraints = false
        let aHorizontalLabelConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[aLabel]-15-|", options: [], metrics: nil, views: ["aLabel":aLabel])
        aTableFooterView.addConstraints(aHorizontalLabelConstraint)
        let aVerticalLabelConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[aLabel]-0-|", options: [], metrics: nil, views: ["aLabel":aLabel])
        aTableFooterView.addConstraints(aVerticalLabelConstraint)
        
        self.menus.append(Menu(icon: Menu.OnAppliance.icon, title: Menu.OnAppliance.title, urc: Menu.OnAppliance.urc))
        self.menus.append(Menu(icon: Menu.Locks.icon, title: Menu.Locks.title, urc: Menu.Locks.urc))
        if ConfigurationManager.shared.appType == ConfigurationManager.AppType.deft {
            self.menus.append(Menu(icon: Menu.TankRegulators.icon, title: Menu.TankRegulators.title, urc: Menu.TankRegulators.urc))
        }
        self.menus.append(Menu(icon: Menu.Schedules.icon, title: Menu.Schedules.title, urc: Menu.Schedules.urc))
        self.menus.append(Menu(icon: Menu.Core.icon, title: Menu.Core.title, urc: Menu.Core.urc))
        self.menus.append(Menu(icon: Menu.OfferZone.icon, title: Menu.OfferZone.title, urc: Menu.OfferZone.urc))
        self.menus.append(Menu(icon: Menu.Notifications.icon, title: Menu.Notifications.title, urc: Menu.Notifications.urc))
        switch ConfigurationManager.shared.appType {
        case .deft:
            self.menus.append(Menu(icon: Menu.Rules.icon, title: Menu.Rules.title, urc: Menu.Rules.urc))
        case .wifinity:
            break
        }
        if ConfigurationManager.shared.appType == ConfigurationManager.AppType.deft {
            self.menus.append(Menu(icon: Menu.Support.icon, title: Menu.Support.title, urc: Menu.Support.urc))
        }
        if ConfigurationManager.shared.appType == ConfigurationManager.AppType.wifinity {
            self.menus.append(Menu(icon: Menu.Device.icon, title: Menu.Device.title, urc: Menu.Device.urc))
        } else {
            self.menus.append(Menu(icon: Menu.SearchDevice.icon, title: Menu.SearchDevice.title, urc: Menu.SearchDevice.urc))
        }
        self.menus.append(Menu(icon: Menu.Logout.icon, title: Menu.Logout.title, urc: Menu.Logout.urc))
    }
    
    
    func toggle() {
        self.isExpanded = !self.isExpanded
        
        if self.snapshotView != nil {
            self.snapshotView!.removeFromSuperview()
            self.snapshotView = nil
        }
        
        self.snapshotView = self.parent?.view.snapshotView(afterScreenUpdates: false)
        if self.snapshotView != nil {
            self.snapshotView!.isUserInteractionEnabled = false
            self.snapshotView!.layer.shadowOpacity = 1.0
            
            let aBlurEffect = UIBlurEffect(style: .light)
            let aBlurEffectView = UIVisualEffectView(effect: aBlurEffect)
            aBlurEffectView.frame = self.snapshotView!.bounds
            self.snapshotView!.addSubview(aBlurEffectView)
            
            self.containerView.clipsToBounds = true
            self.containerView.addSubview(self.snapshotView!)
            self.containerView.sendSubviewToBack(self.snapshotView!)
        }
        
        self.view.layer.shadowColor = UIColor.black.cgColor
        UIView.animate(withDuration: 0.3, animations: {
            let aWidth: CGFloat = (self.parent?.view.bounds.width ?? 300) * 2 / 3
            let anAbscissa: CGFloat = self.isExpanded ? 0 : -aWidth
            self.view.frame = CGRect(x: anAbscissa, y: 0, width: aWidth, height: self.view.bounds.height)
        }, completion: {pCompletion in
            if self.isExpanded == false {
                self.view.layer.shadowColor = UIColor.clear.cgColor
            }
        })
    }
    
    
    func open() {
        self.isExpanded = false
        self.toggle()
    }
    
    

    func close() {
        self.isExpanded = true
        self.toggle()
    }
    
    
    @IBAction func didSelectMenuButton(_ pSender: UIButton?) {
        self.close()
    }
}



extension DrawerController :UITableViewDataSource, UITableViewDelegate {
    
    // MARK:- UITableView Methods
    
    /**
     * Method that will calculate and return number of section in given table.
     * @return Int. Number of section in given table
     */
    func numberOfSections(in pTableView: UITableView) -> Int {
        return 1
    }
    
    
    /**
     * Method that will calculate and return number of rows in given section of the table.
     * @return Int. Number of rows in given section
     */
    func tableView(_ pTableView: UITableView, numberOfRowsInSection pSection: Int) -> Int {
        var aReturnVal :Int = 0
        
        if pSection == 0 {
            aReturnVal = self.menus.count
        }
        
        return aReturnVal
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, heightForRowAt pIndexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    
    /**
     * Method that will calculate and return height of row at given index path of the table.
     * @return CGFloat. Height of the row at given index path
     */
    func tableView(_ pTableView: UITableView, estimatedHeightForRowAt pIndexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    
    /**
     * Method that will init, set and return the cell view.
     * @return UITableViewCell. View of the cell in given table view.
     */
    func tableView(_ pTableView: UITableView, cellForRowAt pIndexPath: IndexPath) -> UITableViewCell {
        var aReturnVal :UITableViewCell?
        
        if pTableView.isEqual(self.menuTableView) {
            let aCellView :DrawerMenuTableCellView = pTableView.dequeueReusableCell(withIdentifier: "DrawerMenuTableCellViewId") as! DrawerMenuTableCellView
            
            if pIndexPath.row < self.menus.count {
                let aMenu = self.menus[pIndexPath.row]
                aCellView.iconImageView.image = aMenu.icon
                aCellView.titleLabel.text = aMenu.title
            }
            
            aReturnVal = aCellView
        }
        
        return aReturnVal!
    }
    
    
    /**
     * Method that will be called when user selects a table cell.
     */
    func tableView(_ pTableView: UITableView, didSelectRowAt pIndexPath: IndexPath) {
        pTableView.deselectRow(at: pIndexPath, animated: true)
        
        self.close()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            if let aDelegate = self.parent as? DrawerControllerDelegate {
                let aMenu = self.menus[pIndexPath.row]
                aDelegate.drawerController(self, didSelectMenuWithUrc: aMenu.urc!)
            }
        }
    }
    
    
    class Menu {
        var icon :UIImage?
        var title :String?
        var urc :String?
        
        
        init(icon pIcon :UIImage, title pTitle :String, urc pUrc :String) {
            self.icon = pIcon
            self.title = pTitle
            self.urc = pUrc
        }
        
        struct OnAppliance {
            static let icon = UIImage(named: "MenuOnAppliances")!
            static let title = "On Appliances"
            static let urc = "OnAppliances"
        }
        
        struct Locks {
            static let icon = UIImage(named: "MenuLocks")!
            static let title = "Locks"
            static let urc = "Locks"
        }
        
        struct TankRegulators {
            static let icon = UIImage(named: "MenuTankRegulators")!
            static let title = "Water Level Controllers"
            static let urc = "TankRegulators"
        }
        
        struct Schedules {
            static let icon = UIImage(named: "MenuSchedules")!
            static let title = "Schedules"
            static let urc = "Schedules"
        }
        
        struct Notifications {
            static let icon = UIImage(named: "MenuNotifications")!
            static let title = "Notifications"
            static let urc = "Notifications"
        }
        
        struct Rules {
            static let icon = UIImage(named: "MenuRules")!
            static let title = "Rules"
            static let urc = "Rules"
        }
        
        struct Support {
            static let icon = UIImage(named: "MenuSupport")!
            static let title = "Support"
            static let urc = "Support"
        }
        
        struct Logout {
            static let icon = UIImage(named: "MenuLogout")!
            static let title = "Logout"
            static let urc = "Logout"
        }
        
        struct OfferZone {
            static let icon = UIImage(named: "PriceTagOffer")!
            static let title = "Offer zone"
            static let urc = "OfferZone"
        }

        struct Device {
            static let icon = UIImage(named: "MenuDevice")!
            static let title = "Add Device"
            static let urc = "NewDevice"
        }
        
        struct SearchDevice {
            static let icon = UIImage(named: "MenuDevice")!
            static let title = "Controllers"
            static let urc = "SearchDevice"
        }
        
        struct Core {
            static let icon = UIImage(named: "CoreBlackIcon")!
            static let title = "C.O.R.E."
            static let urc = "Core"
        }
        
    }

}


protocol DrawerControllerDelegate {
    func drawerController(_ pDrawerController :DrawerController, didSelectMenuWithUrc pUrc :String)
}
