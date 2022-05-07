//
//  CreateAccountView.swift
//  App
//
//  Created by Anthony Humay on 5/6/22.
//

import SwiftUI
import UIKit

struct CreateAccountView: View {
    var createAccountTapped:(String) -> ()

    @State private var username: String = ""
    @State private var showCreateTeamPage: Bool = false

    var body: some View {
        VStack(alignment: .center) {
            Text("Register")
                .font(.custom("Shapiro-Bold", size: 36))
                .padding(.bottom, 10)
            Text("Create a personal account to set up a team.")
            TextField("Username", text: $username)
                .frame(height: 100, alignment: .center)
            Button("Create Account") {
                createAccountTapped($username.wrappedValue)
            }

            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding(.top, 30)
        .padding(.leading, 30)
        .padding(.trailing, 30)
    }
}
