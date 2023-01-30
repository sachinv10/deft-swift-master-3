//
//  PdfViewController.swift
//  Wifinity
//
//  Created by Apple on 10/11/22.
//

import UIKit
import PDFKit
class PdfViewController: UIViewController {
    var pdf = PDFView()
    var pdfUrl: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(pdf)
        
        if let document = PDFDocument(url: pdfUrl!)
        {
            pdf.document = document
            pdf.autoScales = true
            pdf.displayMode = .singlePageContinuous
        }
 
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didTapViewmenu(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
            self.pdf.addGestureRecognizer(swipeRight)
 
    }
    @objc func didTapViewmenu(_ sender: UITapGestureRecognizer) {
        print("Swiped right")
   dismiss(animated: true)
     }
    override func viewDidLayoutSubviews() {
        pdf.frame = self.view.frame
    }
    func respondToSwipeGesture(gesture: UIGestureRecognizer)
    {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer
        {
            switch swipeGesture.direction
            {
            case UISwipeGestureRecognizer.Direction.right:
                     //write your logic for right swipe
                      print("Swiped right")

            case UISwipeGestureRecognizer.Direction.left:
                     //write your logic for left swipe
                      print("Swiped left")

                default:
                    break
            }
        }
    }
}
