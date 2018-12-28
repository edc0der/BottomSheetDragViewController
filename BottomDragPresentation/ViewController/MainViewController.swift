//
//  MainViewController.swift
//  BottomDragPresentation
//
//  Created by Eduard Moya on 21/12/2018.
//  Copyright © 2018 Eduard Moya. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var bottomSheetVC: BottomSheetViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBottomSheet()
    }

    func addBottomSheet() -> Void {
        bottomSheetVC = BottomSheetViewController(frame: view.frame)
        guard let bottomSheetVC = bottomSheetVC else { return }

        addChild(bottomSheetVC)
        view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        bottomSheetVC.displayOnDefaultPosition()
    }
}
