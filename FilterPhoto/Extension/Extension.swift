//
//  Extension.swift
//  FilterPhoto
//
//  Created by hyunsu han on 2018. 2. 15..
//  Copyright © 2018년 hyunsu han. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(_ text: String, handler: ((UIAlertAction) -> Void)? ) {
        let alertController = UIAlertController(title: "FilterPhoto", message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .destructive, handler: handler)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
