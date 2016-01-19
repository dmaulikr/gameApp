//
//  TableCellView.swift
//  gameApp
//
//  Created by Liza on 1/17/16.
//  Copyright © 2016 Girsova. All rights reserved.
//

import Cocoa

class TableCellView: NSView {

    @IBOutlet var displayNameTF: NSTextField!
    @IBOutlet var readyTF: NSTextField!

    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
    }
    
}
