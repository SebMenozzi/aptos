//
//  CreateTeamView.swift
//  App
//
//  Created by Anthony Humay on 5/6/22.
//

import SwiftUI
import UIKit

struct CreateTeamView: View {
    var createAccountTapped:(String) -> ()

    @State private var teammateUsernames = [String]()

    var body: some View {
        VStack(alignment: .center) {
            Text("Form A Team")
                .font(.custom("Shapiro-Bold", size: 36))
                .padding(.bottom, 10)
            Form {
                ListEditor(title: "Teammates",
                           placeholderText: "Teammate username",
                           addText: "Add teammate",
                           list: $teammateUsernames)
            }
            Button("Save") {
                
            }
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(.top, 30)
        .padding(.leading, 30)
        .padding(.trailing, 30)
    }
}

struct ListEditor: View {
    var title: String
    var placeholderText: String
    var addText: String
    @Binding var list: [String]
    
    func getBinding(forIndex index: Int) -> Binding<String> {
        return Binding<String>(get: { list[index] },
                               set: { list[index] = $0 })
    }
    
    var body: some View {
        Section(header: Text(title)) {
            ForEach(0..<list.count, id: \.self) { index in
                ListItem(placeholder: placeholderText, text: getBinding(forIndex: index)) { self.list.remove(at: index) }
            }
            AddButton(text: addText) { self.list.append("") }
        }
    }
}

fileprivate struct ListItem: View {
    var placeholder: String
    @Binding var text: String
    var removeAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: removeAction) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            TextField(placeholder, text: $text)
        }
    }
    
}

fileprivate struct AddButton: View {
    var text: String
    var addAction: () -> Void
    
    var body: some View {
        Button(action: addAction) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .padding(.horizontal)
                Text(text)
            }
        }
    }
}
