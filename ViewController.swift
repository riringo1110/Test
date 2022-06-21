//
//  ViewController.swift
//  debug3
//
//  Created by Y.TOBITA on 2021/06/13.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 27
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return battery[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = battery[row]
        Label_a.text = battery[row]
        Hidden_textfield_label.text = String((battery[row].prefix(battery[row].count - 1)))
        count_2 = Float(Hidden_textfield_label.text!)!
        count_2 = count_2 / 100
        print(count_2)
        //        print(battery[row].prefix(battery[row].count - 1))
        //        print(battery[row].count)
    }
    
    @IBOutlet var labelBatteryLevel: UILabel!
    @IBOutlet var labelBatteryStatus: UILabel!
    @IBOutlet weak var Hidden_label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var Label_a: UILabel!
    @IBOutlet weak var Hidden_textfield_label: UILabel!
    var pickerView = UIPickerView()
    //    var count: Int = 0
    var count_2: Float = 0.0
    var battery = ["100%","98%", "97%","95%", "90%", "85%", "80%", "75%", "70%", "65%", "60%", "55%", "50%", "45%", "40%", "35%", "30%", "25%", "20%", "15%", "10%", "9%", "8%", "7%", "6%", "5%", "4%", "3%", "2%", "1%"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerView()
        
        // バッテリーのモニタリングをenableにする
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        let bLevel:Float = UIDevice.current.batteryLevel
        print(bLevel)
        Hidden_label.text = String ("\(bLevel * 100) %")
        //        print(Hidden_label.text!)
        
        if(bLevel == -1){
            // バッテリーレベルがモニターできないケース
            labelBatteryLevel.text = "Battery Level: ?"
        }
        else{
            labelBatteryLevel.text = "Battery Level:  \(bLevel * 100) %"
        }
        
        // Battery Status
        var state:String = "Battery Status: "
        
        if UIDevice.current.batteryState == UIDevice.BatteryState.unplugged {
            state += "Unplugged"
        }
        
        if UIDevice.current.batteryState == UIDevice.BatteryState.charging {
            state += "Charging"
        }
        
        if UIDevice.current.batteryState == UIDevice.BatteryState.full {
            state += "Full"
        }
        
        if UIDevice.current.batteryState == UIDevice.BatteryState.unknown {
            state += "Unknown"
        }
        
        labelBatteryStatus.text = state
        
        // Do any additional setup after loading the view.
    }
    
    func createPickerView() {
        pickerView.delegate = self
        textField.inputView = pickerView
        // toolbar
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.donePicker))
        toolbar.setItems([doneButtonItem], animated: true)
        textField.inputAccessoryView = toolbar
    }
    
    @objc func donePicker() {
        textField.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.endEditing(true)
    }
    
    //タイマー処理
    @IBAction func tapButton(_ sender: UIButton) {
        
        Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(self.batteryNotification),
            userInfo: nil,
            repeats: true )
        
        let actionSheet = UIAlertController(title:"通知設定",
                                            message: "\(count_2 * 100)%に通知します", preferredStyle: .actionSheet)
        
        let 名前 = UIAlertAction(title: "OK", style: .default, handler:{(action:UIAlertAction!) in
            
        })
        actionSheet.addAction(名前)
        //        ボタンは増やせます
        let alertController = UIAlertAction(title: "NO", style: .cancel)
        actionSheet.addAction(alertController)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func batteryNotification(_sender: Timer){
        UIDevice.current.isBatteryMonitoringEnabled = true
        let bLevel:Float = UIDevice.current.batteryLevel
        print(bLevel)
        
        
        if bLevel == count_2{
            notification()
        }
        
    }
    
    
    func notification() {
        let content = UNMutableNotificationContent()
        content.title = "バッテリー通知"
        content.body = "現在\(count_2 * 100)%です"
        content.sound = UNNotificationSound.default
        
        let bLevel : Float = UIDevice.current.batteryLevel
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(1),
                                                        repeats: false)
        // 直ぐに通知を表示
        let request = UNNotificationRequest(identifier: String(bLevel), content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
}
