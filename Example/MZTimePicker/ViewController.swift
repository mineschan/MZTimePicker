//
//  ViewController.swift
//  TestTimerPicker
//
//  Created by MineS Chan on 12/6/2018.
//  Copyright © 2018 DigiSalad Limied. All rights reserved.
//

import UIKit
import MZTimePicker

class ViewController: UIViewController {
    
    var timePicker: MZTimePickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timePicker = MZTimePickerView(pickerType: .range)
        timePicker.timeInterval = .every30mins
        timePicker.frame = CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 160)
        timePicker.layer.borderColor = UIColor.gray.cgColor
        timePicker.layer.borderWidth = 1.0
        timePicker.delegate = self
        timePicker.minimumRangeStep = 2
        
        let getValueButton = UIButton(type: .system)
        getValueButton.setTitle("Get Time", for: .normal)
        getValueButton.frame = CGRect(x: 0, y: 50, width: 100, height: 20)
        getValueButton.addTarget(self, action: #selector(getTime), for: .touchUpInside)
        self.view.addSubview(getValueButton)
        
        let setValueButton = UIButton(type: .system)
        setValueButton.setTitle("Set Time", for: .normal)
        setValueButton.frame = CGRect(x: 100, y: 50, width: 100, height: 20)
        setValueButton.addTarget(self, action: #selector(setTime), for: .touchUpInside)
        self.view.addSubview(setValueButton)
        
        self.view.addSubview(timePicker)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func getTime() {
        if let time1 = timePicker.getTime(column: 0) {
            print("timePicker Value1: \(time1)")
        }
        if let time2 = timePicker.getTime(column: 1) {
            print("timePicker Value2: \(time2)")
        }
    }
    
    @objc func setTime() {
        timePicker.setTime(column: 1, time: 7200, animated: true)
    }
}


extension ViewController: MZTimePickerViewDelegate {
    func timePickerValueChanged(picker: MZTimePickerView, column: Int, time: Time) {
        print(time)
    }
}
