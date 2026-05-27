//
//  ToDoListWidgetBundle.swift
//  ToDoListWidget
//
//  Created by macbook pro on 26/05/26.
//

import WidgetKit
import SwiftUI

@main
struct ToDoListWidgetBundle: WidgetBundle {
    var body: some Widget {
        ToDoListWidget()
        ToDoListWidgetControl()
        ToDoListWidgetLiveActivity()
    }
}
