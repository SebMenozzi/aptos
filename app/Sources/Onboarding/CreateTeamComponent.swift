//
//  CreateTeamComponent.swift
//  App
//
//  Created by Anthony Humay on 5/6/22.
//

import SwiftUI
import UIKit

struct CreateTeamComponent: View {
    var createTeamTapped:(String) -> ()
    
    @State private var needsCreateAccount = true
    @State private var username = ""

    var body: some View {
        if needsCreateAccount {
            CreateAccountView(createAccountTapped: { inputUsername in
                needsCreateAccount = false
                username = inputUsername
            })
        } else {
            CreateTeamView(createTeamTapped: { _ in
                createTeamTapped(username)
            })
        }
    }
}
