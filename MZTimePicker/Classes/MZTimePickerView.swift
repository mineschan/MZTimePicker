//
//  MZTimePickerView.swift
//  TestTimerPicker
//
//  Created by MineS Chan on 12/6/2018.
//  Copyright © 2018 DigiSalad Limied. All rights reserved.
//

import UIKit

public struct Time {
    public var seconds: TimeInterval
    
    public init(seconds: TimeInterval) {
        self.seconds = seconds
    }
    
    public func format(_ format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df.string(from: Date(timeIntervalSince1970: seconds))
    }
}

public protocol MZTimePickerViewDelegate {
    func timePickerValueChanged(picker: MZTimePickerView, column: Int, time: Time)
}

public class MZTimePickerView: UIView {
    
    public enum PickerType {
        case single
        case range
    }
    
    public enum PickerTimeInterval {
        case hourly
        case every15mins
        case every30mins
    }
    
    //configurations
    public var pickerType: PickerType = .single {
        didSet {
            setupPickers()
        }
    }
    
    public var timeInterval: PickerTimeInterval = .hourly {
        didSet {
            updateTimeSettings()
        }
    }
    
    public var minimumRangeStep = 1
    public var maxRangeStep = 0
    
    public var timeFormat = "HH:mm"
    
    public var disableEndTimeSelection = false {
        didSet {
            column2?.isUserInteractionEnabled = !disableEndTimeSelection
        }
    }
    
    //styles
    public var selectedTimeViewBgColor = UIColor.darkGray {
        didSet {
            selectedTimeView.backgroundColor = selectedTimeViewBgColor
        }
    }
    
    public var timeValueTextColor = UIColor.white {
        didSet {
            valueLabel1?.textColor = timeValueTextColor
            valueLabel2?.textColor = timeValueTextColor
        }
    }
    public var timeValueFont = UIFont.systemFont(ofSize: 24, weight: .bold) {
        didSet {
            valueLabel1?.font = timeValueFont
            valueLabel2?.font = timeValueFont
        }
    }
    
    public var rangeToTextColor = UIColor.white {
        didSet {
            rangeToLabel?.textColor = rangeToTextColor
        }
    }
    
    public var pickerRowFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    public var pickerRowTextColor = UIColor.black

    public var rangeToFont = UIFont.systemFont(ofSize: 14, weight: .regular) {
        didSet {
            rangeToLabel?.font = rangeToFont
        }
    }
    
    public var selectedTimeViewHeight: CGFloat = 100.0
    public var selectedTimeViewOffsetY: CGFloat = 0
    
    public var timeRowHeight: CGFloat = 44.0
    
    //views
    var selectedTimeView: UIView!
    var column1: TimePickerColumn?
    var column2: TimePickerColumn?
    
    var valueLabel1: UILabel?
    var valueLabel2: UILabel?
    var rangeToLabel: UILabel?
    
    //internals
    var times: [Time] = []
    public var delegate: MZTimePickerViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(pickerType: .single)
    }
    
    public convenience init(pickerType: PickerType) {
        self.init(frame: CGRect.zero)
        defer {
            self.pickerType = pickerType
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        selectedTimeView = UIView()
        selectedTimeView.backgroundColor = UIColor.init(red: 38/255, green: 198/255, blue: 208/255, alpha: 1.0)
        selectedTimeView.isUserInteractionEnabled = false
        self.addSubview(selectedTimeView)
        
        updateTimeSettings()
        setupPickers()
    }
    
    private func updateTimeSettings() {
        var minutesToAdd: Double = 0
        switch timeInterval {
        case .every30mins:
            minutesToAdd = 30
        case .every15mins:
            minutesToAdd = 15
        default:
            minutesToAdd = 60
        }
        times.removeAll()

        let timeIntervalInDay: TimeInterval = 60 * 60 * 23 + 60 * 59
        
        let totalSlot = timeIntervalInDay / Double(minutesToAdd * 60)
        
        for i in 0...Int(totalSlot) {
            let t = Time(seconds: Double(i) * minutesToAdd * 60)
            times.append(t)
        }
    }
    
    private func setupPickers() {
        
        column1?.removeFromSuperview()
        column2?.removeFromSuperview()
        valueLabel1?.removeFromSuperview()
        valueLabel2?.removeFromSuperview()
        rangeToLabel?.removeFromSuperview()
        
        column1 = TimePickerColumn(pickerView: self, column: 0)
        column1?.pickerView = self
        self.addSubview(column1!)
        
        valueLabel1 = UILabel()
        valueLabel1?.textColor = timeValueTextColor
        valueLabel1?.font = timeValueFont
        valueLabel1?.textAlignment = .center
        valueLabel1?.sizeToFit()
        selectedTimeView.addSubview(valueLabel1!)
        
        if pickerType == .range {
            column2 = TimePickerColumn(pickerView: self, column: 1)
            column2?.pickerView = self
            column2?.isUserInteractionEnabled = !disableEndTimeSelection
            self.addSubview(column2!)
            
            valueLabel2 = UILabel()
            valueLabel2?.textColor = timeValueTextColor
            valueLabel2?.font = timeValueFont
            valueLabel2?.textAlignment = .center
            valueLabel2?.sizeToFit()
            selectedTimeView.addSubview(valueLabel2!)
            
            rangeToLabel = UILabel()
            rangeToLabel?.textColor = rangeToTextColor
            rangeToLabel?.font = rangeToFont
            rangeToLabel?.textAlignment = .center
            selectedTimeView.addSubview(rangeToLabel!)
            
            setRangeText("TO")
            column2?.changeToSlot(row: minimumRangeStep, animated: false)
        }
        
        self.bringSubview(toFront: selectedTimeView)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    public override func layoutSubviews() {
        
        selectedTimeView.frame = CGRect(x: 0, y: self.frame.size.height / 2 - selectedTimeViewHeight / 2 - (selectedTimeViewOffsetY * -1), width: self.frame.size.width, height: selectedTimeViewHeight)
        
        if self.pickerType == .single {
            column1?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            valueLabel1?.center = CGPoint(x: selectedTimeView.frame.width / 2, y: selectedTimeView.frame.height / 2)
            valueLabel1?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: selectedTimeView.frame.height)
        }else{
            column1?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width / 2, height: self.frame.size.height)
            column2?.frame = CGRect(x: self.frame.size.width / 2, y: 0, width: self.frame.size.width / 2, height: self.frame.size.height)
            valueLabel1?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width / 2, height: selectedTimeView.frame.height)
            valueLabel2?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width / 2, height: selectedTimeView.frame.height)
            valueLabel1?.center = CGPoint(x: selectedTimeView.frame.width / 4, y: selectedTimeView.frame.height / 2)
            valueLabel2?.center = CGPoint(x: selectedTimeView.frame.width / 4 * 3, y: selectedTimeView.frame.height / 2)
            rangeToLabel?.center = CGPoint(x: selectedTimeView.frame.width / 2, y: selectedTimeView.frame.height / 2)
        }
        super.layoutSubviews()
    }
}

public extension MZTimePickerView {
    public func setRangeText(_ text: String) {
        rangeToLabel?.text = text
        rangeToLabel?.sizeToFit()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    public func getTime(column: Int) -> Time? {
        switch column {
        case 0:
            if let selected = column1?.selectedTimeSlot {
                return times[selected]
            }
        case 1:
            if let selected = column2?.selectedTimeSlot {
                return times[selected]
            }
        default:
            break
        }
        return  nil

    }
    
    public func setTime(column: Int, time: TimeInterval, animated: Bool) {
        let matchedTime = times.enumerated().filter {
            $0.element.seconds == time
        }.first
        guard let timeIndex = matchedTime?.offset else { return }
        setTime(column: column, slot: timeIndex, animated: animated)
    }
    
    public func setTime(column: Int, slot: Int, animated: Bool) {
        switch (column) {
        case 0:
            guard slot < (times.count - 1) else {
                column1?.scrollToBottom(animated: animated)
                return
            }
            column1?.changeToSlot(row: slot, animated: animated)
            correctEndTime()
        case 1:
            guard slot < (times.count - 1) else {
                column2?.scrollToBottom(animated: animated)
                return
            }
            column2?.changeToSlot(row: slot, animated: animated)
            correctEndTime()
        default:
            break
        }
    }
}

extension MZTimePickerView {
    func correctEndTime() {
        guard pickerType == .range else { return }
        guard let column1 = column1, let column2 = column2 else { return }
        guard minimumRangeStep > 0 else { return }
        
        if column1.selectedTimeSlot + minimumRangeStep >= (times.count - 1) {
            //reach range max
            column1.changeToSlot(row: (times.count - 1) - minimumRangeStep, animated: true)
            column2.scrollToBottom(animated: true)
        }else{
            if column2.selectedTimeSlot < column1.selectedTimeSlot + minimumRangeStep {
                column2.changeToSlot(row: column1.selectedTimeSlot + minimumRangeStep, animated: true)
            } else if maxRangeStep != 0 && column2.selectedTimeSlot - column1.selectedTimeSlot > maxRangeStep {
                column2.changeToSlot(row: column1.selectedTimeSlot + maxRangeStep, animated: true)
            }
        }
    }
    
    func tapticFeedback() {
        if #available(iOS 10, *) {
            let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
            selectionFeedbackGenerator.prepare()
            selectionFeedbackGenerator.selectionChanged()
        }
    }
}
