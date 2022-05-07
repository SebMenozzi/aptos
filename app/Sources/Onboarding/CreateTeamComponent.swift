//
//  CreateTeamComponent.swift
//  App
//
//  Created by Anthony Humay on 5/6/22.
//

import SwiftUI
import UIKit

struct CreateTeamComponent: View {
    var createAccountTapped:(String) -> ()
    
    @State private var needsCreateAccount = true

    var body: some View {
        if needsCreateAccount {
            CreateAccountView(createAccountTapped: { username in
                needsCreateAccount = false
                createAccountTapped(username)
            })
        } else {
            CreateTeamView(createAccountTapped: createAccountTapped)
        }
    }
}
