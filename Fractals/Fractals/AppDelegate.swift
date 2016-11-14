//
//  AppDelegate.swift
//  Fractals
//
//  Created by Dmitry Rodionov on 07/11/2016.
//  Copyright © 2016 Internals Exposed. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var fractalView: FractalView!
    @IBOutlet weak var rulesTable: NSTableView!

    @objc var axiom: String = "F++F++F"
    @objc var angleValue: Double = 60.0
    @objc var stepValue: Double = 2.0
    @objc var iterations: Int = 5

    var rules: [Fractal.Rule] = [("F", "F-F++F-F")]

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        // Insert code here to initialize your application
        stateChanged(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }

    @IBAction func stateChanged(_ sender: AnyObject?)
    {
        let f = Fractal(axiom: axiom, rules: rules, angle: CGFloat(angleValue),
                        stepSize: CGFloat(stepValue), iterations: iterations)
        self.fractalView.fractal = f
    }

    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return rules.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        guard let cell = (tableView.make(withIdentifier: tableColumn!.identifier, owner: nil) as? NSTableCellView) else {
            return nil
        }
        switch tableColumn!.identifier {
        case "lhs":
            cell.textField!.stringValue = rules[row].0
        case "rhs":
            cell.textField!.stringValue = rules[row].1
        default:
            fatalError("Unexpected column")
        }
        cell.textField?.delegate = self
        return cell
    }

    @IBAction func addRule(_ sender: AnyObject?)
    {
        DispatchQueue.main.async {
            self.rules.append(("F", "F"))
            let newRuleIndex = self.rules.endIndex - 1
            self.window.makeFirstResponder(self.rulesTable)
            self.rulesTable.insertRows(at: IndexSet(integer: newRuleIndex), withAnimation: .effectFade)
            self.rulesTable.scrollRowToVisible(newRuleIndex)
            self.rulesTable.selectRowIndexes(IndexSet(integer: newRuleIndex), byExtendingSelection: false)
            self.rulesTable.editColumn(0, row: newRuleIndex, with: nil, select: true)
        }
    }

    @IBAction func deleteRule(_ sender: AnyObject?)
    {
        let selectedRow = rulesTable.selectedRow
        if selectedRow != -1 {
            rules.remove(at: selectedRow)
            rulesTable.removeRows(at: IndexSet(integer: selectedRow), withAnimation: .effectFade)
            self.stateChanged(nil)
        }
    }

    override func controlTextDidEndEditing(_ obj: Notification)
    {
        let editor = obj.object as! NSTextField
        let row = rulesTable.row(for: editor)
        let column = rulesTable.column(for: editor)

        switch column {
        case 0:
            rules[row] = (editor.stringValue, rules[row].1)
        case 1:
            rules[row] = (rules[row].0, editor.stringValue)
        default:
            fatalError("Unexpected column")
        }
    }
}

