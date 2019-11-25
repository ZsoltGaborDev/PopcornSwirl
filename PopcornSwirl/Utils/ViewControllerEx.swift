//
//  CustomButtom.swift
//  PopcornSwirl
//
//  Created by zsolt on 29/10/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
//
//
//    func showSimpleAlert(title: String, message: String) {
//        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: NSLocalizedString("COMMON_ALERT_OK", comment: ""), style: UIAlertAction.Style.default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//
//
//    /* Keyboard manager */
//    func hideKeyboardWhenTappedAround() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//
//
//    /* hide all seconfary views: emptycase, connectionerror, activityindicator */
//    func hideAllCaseView(emptyView: EmptyCase?, connectionView: ConnectionErrorView?, activityIndicatorView: UIView?) {
//        if emptyView != nil {
//            emptyView!.isHidden = true
//        }
//        if connectionView != nil {
//            connectionView!.isHidden = true
//        }
//        if activityIndicatorView != nil {
//            activityIndicatorView!.backgroundColor = Colors.BACKGROUND_ACTIVITYINDICATOR
//            activityIndicatorView!.isHidden = true
//        }
//    }
//
//    /* hide main view to show view empty */
//    func showEmptyView(mainView: UIView, emptyView: EmptyCase, emptyText: String) {
//        mainView.isHidden = true
//        emptyView.isHidden = false
//        emptyView.setInfoLabel(text: emptyText)
//    }
//
    func showActivityIndicatorView(activityIndicatorView: UIView, activityIndicator: UIActivityIndicatorView) {
        activityIndicatorView.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideActivityIndicatorView(activityIndicatorView: UIView, activityIndicator: UIActivityIndicatorView) {
        activityIndicatorView.isHidden = true
        activityIndicator.stopAnimating()
    }
//
//    func showErrorView(mainView: UIView, errorView: ConnectionErrorView) {
//        mainView.isHidden = true
//        errorView.isHidden = false
//    }
//
//    func hideErrorView(mainView: UIView, errorView: ConnectionErrorView) {
//        mainView.isHidden = false
//        errorView.isHidden = true
//    }
}
