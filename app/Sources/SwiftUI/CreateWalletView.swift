import SwiftUI
import UIKit

struct CreateWalletView: View {
    
    var createWalletTapped: ([String]) -> ()

    @State private var publicKeys = [String]()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(alignment: .center) {
                ModalViewIndicator()
                Text("Create a wallet")
                    .font(.custom("Shapiro ExtraBold Wide", size: 28))
                    .foregroundColor(.white)
                Form {
                    ListEditor(
                        title: "Friends",
                        placeholderText: "Friend Public Key",
                        addText: "Add Public Key",
                        list: $publicKeys
                    )
                }
                    .onAppear {
                       UITableView.appearance().backgroundColor = .black
                    }
                    .foregroundColor(.white)
                    .padding(.top, -20)

                Button("CREATE A WALLET") {
                    createWalletTapped(publicKeys)
                }
                    .buttonStyle(CustomButtonStyle())
                    .foregroundColor(.white)
                Spacer()
            }
                .multilineTextAlignment(.center)
                .padding(.leading, 10)
                .padding(.trailing, 10)
        }
    }
}

struct ListEditor: View {
    var title: String
    var placeholderText: String
    var addText: String
    @Binding var list: [String]
    
    func getBinding(forIndex index: Int) -> Binding<String> {
        return Binding<String>(
            get: { list[index] },
            set: { list[index] = $0 }
        )
    }
    
    var body: some View {
        Section(header: Text(title).font(.custom("Shapiro Semi", size: 18))) {
            ForEach(0..<list.count, id: \.self) { index in
                ListItem(placeholder: "\(placeholderText) #\(index + 1)", text: getBinding(forIndex: index)) { self.list.remove(at: index) }
            }
            AddButton(text: addText) { self.list.append("") }
        }
        .listRowBackground(Color.black)
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
                .multilineTextAlignment(.leading)
                .font(.custom("Shapiro Medium", size: 18))
        }
    }
    
}
