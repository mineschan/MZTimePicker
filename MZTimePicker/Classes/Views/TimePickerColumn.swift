//
//  MZTimePickerColumn.swift
//  TestTimerPicker
//
//  Created by MineS Chan on 12/6/2018.
//  Copyright © 2018 DigiSalad Limied. All rights reserved.
//

import UIKit

class TimePickerColumn: UIView {
    
    var pickerView: MZTimePickerView!
    var columnIndex = 0
    var selectedTimeSlot = 0
        
    var upperTableView: TimePickerTableView!
    var lowerTableView: TimePickerTableView!
    
    private var isSyncingPicker = false
    var currentTime: Time?
  
    public var isUpperPickerHidden = false

  convenience init(pickerView: MZTimePickerView, column: Int, isUpperPickerHidden: Bool = false) {
        self.init(frame: CGRect.zero)
        self.pickerView = pickerView
        self.columnIndex = column
        self.isUpperPickerHidden = isUpperPickerHidden
        
        upperTableView = TimePickerTableView(pickerView: pickerView, position: .upper)
        upperTableView.delegate = self
        self.addSubview(upperTableView)
        
        lowerTableView = TimePickerTableView(pickerView: pickerView, position: .lower)
        lowerTableView.delegate = self
        self.addSubview(lowerTableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isUpperPickerHidden {
            upperTableView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: pickerView.selectedTimeView.frame.minY)
            upperTableView.contentInset = UIEdgeInsetsMake(pickerView.selectedTimeView.frame.minY, 0, 0, 0)
        }

        lowerTableView.frame = CGRect(x: 0, y: pickerView.selectedTimeView.frame.minY, width: self.frame.width, height: pickerView.frame.height - pickerView.selectedTimeView.frame.maxY + pickerView.selectedTimeView.frame.height)
        lowerTableView.contentInset = UIEdgeInsetsMake(pickerView.selectedTimeView.frame.height, 0, self.frame.height - pickerView.selectedTimeView.frame.maxY, 0)
        lowerTableView.contentOffset = CGPoint(x: 0, y: -pickerView.selectedTimeView.frame.height)
        syncPickerUsing(position: .lower)
    }
    
    override func didMoveToSuperview() {
        guard superview != nil else { return }
        super.didMoveToSuperview()
    }
}

extension TimePickerColumn: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == lowerTableView {
            syncPickerUsing(position: .lower)
        }else if scrollView == upperTableView {
            syncPickerUsing(position: .upper)
        }
        determineCurrentTime()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == lowerTableView {
            selectedTimeSlot = lowerTableView.snapToRow() + 1
        }else if scrollView == upperTableView {
            selectedTimeSlot = upperTableView.snapToRow()
        }
        correctTimeSlotRange()
        pickerView.delegate?.timePickerValueChanged(picker: pickerView, column: columnIndex, time: currentTime!)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        if scrollView == lowerTableView {
            selectedTimeSlot = lowerTableView.snapToRow()
        }else if scrollView == upperTableView {
            selectedTimeSlot = upperTableView.snapToRow()
        }
        correctTimeSlotRange()
        pickerView.delegate?.timePickerValueChanged(picker: pickerView, column: columnIndex, time: currentTime!)
    }
}

extension TimePickerColumn {
    
    func changeToSlot(row: Int, animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let ss = self else { return }
            ss.lowerTableView.scrollToRow(at: [0, row], at: .top, animated: animated)
        }
        selectedTimeSlot = row
    }
    
    func scrollToBottom(animated: Bool) {
        lowerTableView.setContentOffset(CGPoint(x: 0, y: lowerTableView.contentSize.height - lowerTableView.contentInset.top), animated: animated)
    }
    
    private func syncPickerUsing(position: TimePickerTableView.PickerPosition) {
        guard !isSyncingPicker else { return }
        isSyncingPicker = true
        switch position {
        case .lower:
            upperTableView.setContentOffset(CGPoint(x: 0, y: lowerTableView.contentOffset.y - upperTableView.contentInset.top + pickerView.selectedTimeView.frame.height), animated: false)
        case .upper:
            lowerTableView.setContentOffset(CGPoint(x: 0, y: upperTableView.contentOffset.y + upperTableView.contentInset.top), animated: false)
        }
        isSyncingPicker = false
    }
    
    private func determineCurrentTime() {
        guard lowerTableView.currentRow() < (pickerView.times.count) else {
            return
        }
        let time = pickerView.times[lowerTableView.currentRow()]
        
        //check if changed
        guard currentTime?.seconds != time.seconds else { return }
        
        if columnIndex == 0 {
            pickerView.valueLabel1?.text = time.format(pickerView.timeFormat)
        }else if columnIndex == 1 {
            pickerView.valueLabel2?.text = time.format(pickerView.timeFormat)
        }
        currentTime = time
        pickerView.tapticFeedback()
    }
    
    private func correctTimeSlotRange() {
        pickerView.correctEndTime()
    }
}
