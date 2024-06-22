//
//  Logging.swift
//  basenana
//
//  Created by Hypo on 2024/4/17.
//

import SwiftyBeaver

// https://github.com/SwiftyBeaver/SwiftyBeaver
let log = SwiftyBeaver.self

func setupLogging(){
    let console = ConsoleDestination()
    console.format = "$DHH:mm:ss$d $L $M"
    log.addDestination(console)
    
    let file = FileDestination()
    log.addDestination(file)
}

