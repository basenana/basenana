//
//  WorkflowItemView.swift
//  Workflow
//
//  Created by Hypo on 2024/12/8.
//
import SwiftUI
import Foundation


struct WorkflowItemView: View {
    var workflow: WorkflowItem
    
    init(workflow: WorkflowItem) {
        self.workflow = workflow
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(randomWeatherEmoji()).font(.system(size: 20))
            Spacer(minLength: 30)
            HStack {
                Text(workflow.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                
                Menu(content: {
                    Section{
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("List Jobs")
                        })
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("Trigger")
                        })
                    }
                    Section{
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("Delete").foregroundStyle(.red)
                        })
                    }
                }, label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .resizable()
                        .frame(width: 15, height: 15)
                })
                .padding(.trailing, 5)
                .buttonStyle(PlainButtonStyle())
                
            }
        }
        .frame(width: 160, alignment: .leading)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .padding(.horizontal, 10)
        .background(colorFrom(workflow.id))
        .cornerRadius(10)
    }
    
    func randomWeatherEmoji() -> String {
        let weatherEmojis = ["☀️", "☀️", "⛅️", "🌦", "🌧", "🌩"]
        if let randomEmoji = weatherEmojis.randomElement() {
            return randomEmoji
        }
        return "☀️"
    }
    
    
    func colorFrom(_ string: String) -> Color {
        let hash = string.hashValue
        let red = Double((hash & 0xFF0000) >> 16) / 255.0 * 0.5
        let green = Double((hash & 0x00FF00) >> 8) / 255.0 * 0.5
        let blue = Double(hash & 0x0000FF) / 255.0 * 0.5
        return Color(red: red, green: green, blue: blue)
    }
}

