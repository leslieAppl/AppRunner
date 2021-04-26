//
//  RunLogCell.swift
//  Tread
//
//  Created by leslie on 12/31/19.
//  Copyright © 2019 leslie. All rights reserved.
//

import UIKit

class RunLogCell: UITableViewCell {

    @IBOutlet weak var runDateLbl: UILabel!
    @IBOutlet weak var runDurationLbl: UILabel!
    @IBOutlet weak var totalDistanceLbl: UILabel!
    @IBOutlet weak var averagePaceLbl: UILabel!
    @IBOutlet weak var averageSpeedLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(run: Run) {
        runDateLbl.text = "Date: \(run.date!.formatDateToString())"
        let dur = Int(run.duration)
        runDurationLbl.text = "Duration: \(dur.formatTimeDurationToString())"
        totalDistanceLbl.text = "distance: \(run.distance.metersToKmForString(places: 2)) Km"
        let ap = Int(run.avePace)
        averagePaceLbl.text = "average pace: \(ap.formatTimeDurationToString()) H/Km"
        averageSpeedLbl.text = "average speed: \(run.aveSpeed.metersToKmForString(places: 2)) Km/H"
    }

}

// MARK: - Helper
extension RunLogCell {
    
    func convertTimeInteral(interval: TimeInterval) {
        
        let absInterval = abs(Int(interval))
        
        let secs = absInterval % 60
        let mins = (absInterval / 60) % 60
        let hrs = (absInterval / 3600)
        
        if hrs == 0 {
            runDurationLbl.text = String(format: "%.2d", mins) + ":" + String(format: "%.2d", secs)
        }
        else {
            runDurationLbl.text = String(hrs) + ":" + String(format: "%.2d", mins) + ":" + String(format: "%.2d", secs)
        }
        
        runDurationLbl.font = UIFont.monospacedDigitSystemFont(ofSize: 40, weight: .bold)
    }

}
