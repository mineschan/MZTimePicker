//
//  MZTimerPickerTableView.swift
//  TestTimerPicker
//
//  Created by MineS Chan on 12/6/2018.
//  Copyright © 2018 DigiSalad Limied. All rights reserved.
//

import UIKit

class TimePickerTableView: UITableView {
    
    public enum PickerPosition {
        case lower
        case upper
    }
    
    let pickerCellId = "pickerCellId"
    
    var pickerView: MZTimePickerView!
    var position: PickerPosition = .upper

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.register(UITableViewCell.self, forCellReuseIdentifier: pickerCellId)
        self.showsVerticalScrollIndicator = false
        self.allowsSelection = false
        self.bounces = false
        self.separatorStyle = .none
        self.separatorColor = UIColor.clear
    }
    
    convenience init(pickerView: MZTimePickerView, position: PickerPosition) {
        self.init(frame: CGRect.zero, style: .plain)
        self.pickerView = pickerView
        self.position = position
        self.dataSource = self
    }
}

extension TimePickerTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: pickerCellId)!
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = pickerView.pickerRowFont
        cell.textLabel?.textColor = pickerView.pickerRowTextColor
        
        if position == .lower {
            cell.textLabel?.text = pickerView.times[indexPath.row + 1].format(pickerView.timeFormat)
        }else{
            cell.textLabel?.text = pickerView.times[indexPath.row].format(pickerView.timeFormat)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickerView.times.count - 1
    }
    
    override var numberOfSections: Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return pickerView.timeRowHeight
    }
}

extension TimePickerTableView {
    func snapToRow() -> Int {
        var row = (self.contentOffset.y + self.contentInset.top) / pickerView.timeRowHeight
        row += floor(((row - floor(row)) >= 0.5) ? 1 : 0)
        let finalSnap =  max(0, Int(row))
        if finalSnap >= numberOfRows(inSection: 0) {
            snapToBottom()
            return numberOfRows(inSection: 0) - 1
        }else{
            self.scrollToRow(at: [0, finalSnap], at: .top, animated: true)
            return finalSnap
        }
    }
    
    func snapToBottom() {
        self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.contentInset.top), animated: true)
    }
    
    func currentRow() -> Int {
        var row = (self.contentOffset.y + self.contentInset.top) / pickerView.timeRowHeight
        row += floor(((row - floor(row)) >= 0.5) ? 1 : 0)
        return max(0, Int(row))
    }
}
