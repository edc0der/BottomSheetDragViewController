//
//  BottomSheetViewController.swift
//  BottomDragPresentation
//
//  Created by Eduard Moya on 21/12/2018.
//  Copyright © 2018 Eduard Moya. All rights reserved.
//

import UIKit

class BottomSheetViewController: UIViewController {

    typealias SuccessClosure = ((Bool) -> Void)

    @IBOutlet weak var dragIndicatorView: DragIndicatorView!

    private var state: DragState = .canDragUp
    private let defaultBottomSheetHeight: CGFloat = 130.0
    private var defaultCenterY: CGFloat = 0.0
    private var defaultFrame: CGRect = .zero {
        didSet {
            defaultCenterY = defaultFrame.origin.y + defaultFrame.size.height / 2
        }
    }
    private var safeAreaTop: CGFloat {
        if #available(iOS 11.0, *) {
            if let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top {
                return topInset
            }
        } else {
            return topLayoutGuide.length
        }
        return 0.0
    }

    private enum DragState {
        case canDragUp, canDragDown
        case isDraggingUp, isDraggingDown
    }

    init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.view.frame = CGRect(x: frame.origin.x, y: frame.height, width: frame.width, height: frame.height)
        updateDefaultFrame()
    }

    private func updateDefaultFrame() -> Void {
        let oldFrame = view.frame
        let newFrame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y - defaultBottomSheetHeight, width: oldFrame.size.width, height: oldFrame.size.height)
        self.defaultFrame = newFrame
        dragIndicatorView.configure(withContainerViewMaximumY: newFrame.origin.y, andContainerViewCurrentY: newFrame.origin.y)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func prepareView() -> Void {
        drawSheetCorners(shouldBeRounded: true)
    }

    func drawSheetCorners(shouldBeRounded: Bool) -> Void {
        UIView.animate(withDuration: 0.3) {
            self.view.layer.cornerRadius = shouldBeRounded ? 12.0 : 0.0
            self.view.clipsToBounds = shouldBeRounded
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }

    func displayOnDefaultPosition() -> Void {
        UIView.animate(withDuration: 0.7, animations: {
            self.view.frame = self.defaultFrame
        })
    }

    @IBAction func didDragView(_ sender: Any) {
        guard let recognizer = sender as? UIPanGestureRecognizer, let draggedView = recognizer.view else { return }
        let isGoingUp = recognizer.velocity(in: view).y < 0

        guard !(state == .canDragDown && isGoingUp) else {
            recognizer.state = .cancelled
            return
        }

        switch recognizer.state {
        case .began:
            state = isGoingUp ? .isDraggingUp : .isDraggingDown

            if !isGoingUp {
                drawSheetCorners(shouldBeRounded: true)
            }
        case .changed:
            let translation = draggedView.center.y + recognizer.translation(in: view).y
            draggedView.center.y = translation

            if draggedView.frame.origin.y < 0 {
                draggedView.center.y = draggedView.frame.height / 2
            } else {
                let newDragIndicatorY = draggedView.frame.origin.y < safeAreaTop ? safeAreaTop - draggedView.frame.origin.y : 0.0
                let newFrame = CGRect(x: dragIndicatorView.frame.origin.x, y: newDragIndicatorY, width: dragIndicatorView.frame.width, height: dragIndicatorView.frame.height)
                dragIndicatorView.frame = newFrame
            }
            dragIndicatorView.updateChevron(forContainerViewCurrentY: draggedView.frame.origin.y)
            recognizer.setTranslation(.zero, in: view)
        case .ended:
            let hasMovedGreaterThanHalfway = draggedView.frame.origin.y < defaultFrame.origin.y / 2
            animateBottomSheet(shouldExpand: hasMovedGreaterThanHalfway)
        default:
            break
        }
    }

    private func animateBottomSheet(shouldExpand: Bool) ->  Void {
        let targetState: DragState = shouldExpand ? .canDragDown : .canDragUp
        let targetCenterY: CGFloat = shouldExpand ? defaultFrame.size.height / 2 : defaultCenterY

        if targetState == .canDragDown {
            drawSheetCorners(shouldBeRounded: false)
        }
        animateBottomSheetYPosition(targetPosition: targetCenterY) { [weak self] _ in
            self?.state = targetState
        }
    }

    private func animateBottomSheetYPosition(targetPosition: CGFloat, completion: SuccessClosure? = nil) -> Void {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.view.center.y = targetPosition
            self.dragIndicatorView.frame = self.frameForDragIndicator()
            self.dragIndicatorView.updateChevron(forContainerViewCurrentY: self.view.frame.origin.y)
        }, completion: completion)
    }

    private func frameForDragIndicator() -> CGRect {
        var newYPosition: CGFloat = 0.0

        if view.frame.origin.y < safeAreaTop {
            newYPosition = safeAreaTop
        }
        return CGRect(x: dragIndicatorView.frame.origin.x, y: newYPosition, width: dragIndicatorView.frame.width, height: dragIndicatorView.frame.height)
    }
}
