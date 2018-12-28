//
//  DragIndicatorView.swift
//  BottomDragPresentation
//
//  Created by Eduard Moya on 27/12/2018.
//  Copyright © 2018 Eduard Moya. All rights reserved.
//

import UIKit
import QuartzCore

class DragIndicatorView: UIView {
    private var containerMaximumY: CGFloat = 0.0
    private var chevronSublayer = CAShapeLayer()

    private let chevronMinimumY: CGFloat = 7.0
    private let chevronMaximumY: CGFloat = 18.0
    private let chevronMinimumX: CGFloat = 6.0
    private let chevronMaximumX: CGFloat = 26.0

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure(withContainerViewMaximumY maximumY: CGFloat, andContainerViewCurrentY currentY: CGFloat) -> Void {
        containerMaximumY = maximumY
        updateChevron(forContainerViewCurrentY: currentY)
    }

    func updateChevron(forContainerViewCurrentY currentY: CGFloat) -> Void {
        let maximumChevronHeight = chevronMaximumY - chevronMinimumY
        let chevronMiddleX = frame.size.width / 2
        let percentage = currentY / containerMaximumY
        let delta = percentage * maximumChevronHeight

        let leftPoint   = CGPoint(x: chevronMinimumX, y: chevronMinimumY + delta)
        let tipPoint    = CGPoint(x: chevronMiddleX, y: chevronMaximumY - delta)
        let rightPoint  = CGPoint(x: chevronMaximumX, y: chevronMinimumY + delta)

        let path = UIBezierPath()
        path.move(to: leftPoint)
        path.addLine(to: tipPoint)
        path.addLine(to: rightPoint)

        chevronSublayer.removeFromSuperlayer()

        chevronSublayer = CAShapeLayer()
        chevronSublayer.path = path.cgPath
        chevronSublayer.strokeColor = UIColor.black.cgColor
        chevronSublayer.lineWidth = 2.75
        chevronSublayer.fillColor = nil

        layer.addSublayer(chevronSublayer)
    }
}
