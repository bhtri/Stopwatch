//
//  ViewController.swift
//  Stopwatch
//
//  Created by bht on 2021/01/01.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {
    // MARK: - Variables
    fileprivate let mainStopwatch: Stopwatch = Stopwatch()
    fileprivate let lapStopwatch: Stopwatch = Stopwatch()
    fileprivate var isPlay: Bool = false
    fileprivate var laps: [String] = []
    
    // MARK: - UI components
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var lapTimerLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var lapRestButton: UIButton!
    @IBOutlet weak var lapsTableView: UITableView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let initCircleButton: (UIButton) -> Void = { button in
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.backgroundColor = UIColor.clear
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
        }
        
        initCircleButton(self.playPauseButton)
        initCircleButton(self.lapRestButton)
        
        self.lapRestButton.isEnabled = false
        self.playPauseButton.isEnabled = true
        
        self.lapsTableView.delegate = self
        self.lapsTableView.dataSource = self
    }
    
    // MARK: - UI Settings
    override var shouldAutorotate: Bool { return false}
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    
    // MARK: - Actions
    @IBAction func playPauseTimer(_ sender: Any) {
        self.lapRestButton.isEnabled = true
        
        self.changeButton(self.lapRestButton, title: "Lap", titleColor: .black)
        
        if !self.isPlay {
            unowned let weakSelf = self
            
            self.mainStopwatch.timer = Timer.scheduledTimer(timeInterval: 0.035, target: weakSelf, selector: .updateMainTimer, userInfo: nil, repeats: true)
            self.lapStopwatch.timer = Timer.scheduledTimer(timeInterval: 0.035, target: weakSelf, selector: .updateLapTimer, userInfo: nil, repeats: true)
            
            RunLoop.current.add(self.mainStopwatch.timer, forMode: .common)
            RunLoop.current.add(self.lapStopwatch.timer, forMode: .common)
            
            self.isPlay = true
            
            changeButton(self.playPauseButton, title: "Stop", titleColor: .red)
            
        } else {
            
            self.mainStopwatch.timer.invalidate()
            self.lapStopwatch.timer.invalidate()
            self.isPlay = false
            self.changeButton(self.playPauseButton, title: "Start", titleColor: .green)
            self.changeButton(self.lapRestButton, title: "Reset", titleColor: .black)
        }
    }
    
    @IBAction func lapResetTimer(_ sender: Any) {
        if !self.isPlay {
            self.resetMainTimer()
            self.resetLapTimer()
            self.changeButton(self.lapRestButton, title: "Lap", titleColor: UIColor.lightGray)
            self.lapRestButton.isEnabled = false
        } else {
            if let timerLabelText = self.timerLabel.text {
                self.laps.append(timerLabelText)
            }
            self.lapsTableView.reloadData()
            self.resetLapTimer()
            unowned let weakSelf = self
            self.lapStopwatch.timer = Timer.scheduledTimer(timeInterval: 0.035, target: weakSelf, selector: Selector.updateLapTimer, userInfo: nil, repeats: true)
            RunLoop.current.add(self.lapStopwatch.timer, forMode: .common)
        }
    }
    
    // MARK: - Private Helpers
    fileprivate func changeButton (_ button: UIButton, title: String, titleColor: UIColor) {
        button.setTitle(title, for: UIControl.State())
        button.setTitleColor(titleColor, for: UIControl.State())
    }
    
    fileprivate func resetMainTimer() {
        resetTimer(self.mainStopwatch, label: self.timerLabel)
        self.laps.removeAll()
        self.lapsTableView.reloadData()
    }
    
    fileprivate func resetLapTimer() {
        resetTimer(self.lapStopwatch, label: self.lapTimerLabel)
    }
    
    fileprivate func resetTimer(_ stopwatch: Stopwatch, label: UILabel) {
        stopwatch.timer.invalidate()
        stopwatch.counter = 0.0
        label.text = "00:00:00"
    }
    
    @objc func updateMainTimer() {
        self.updateTimer(self.mainStopwatch, label: self.timerLabel)
    }
    
    @objc func updateLapTimer() {
        self.updateTimer(self.lapStopwatch, label: self.lapTimerLabel)
    }
    
    func updateTimer(_ stopwatch: Stopwatch, label: UILabel) {
        stopwatch.counter = stopwatch.counter + 0.035
        
        var minutes: String = "\((Int)(stopwatch.counter / 60))"
        if (Int)(stopwatch.counter / 60) < 10 {
            minutes = "0\((Int)(stopwatch.counter / 60))"
        }
        
        var seconds: String = String(format: "%.2f", (stopwatch.counter.truncatingRemainder(dividingBy: 60)))
        if stopwatch.counter.truncatingRemainder(dividingBy: 60) < 10 {
            seconds = "0" + seconds
        }
        
        label.text = minutes + ":" + seconds
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String = "lapCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let labelNum = cell.viewWithTag(11) as? UILabel {
            labelNum.text = "Lap \(laps.count - (indexPath as NSIndexPath).row)"
        }
        
        if let labelTimer = cell.viewWithTag(12) as? UILabel {
            labelTimer.text = laps[laps.count - (indexPath as NSIndexPath).row - 1]
        }
        
        return cell
    }
    
}

// MARK: - Extension
fileprivate extension Selector {
    static let updateMainTimer = #selector(ViewController.updateLapTimer)
    static let updateLapTimer = #selector(ViewController.updateLapTimer)
}

