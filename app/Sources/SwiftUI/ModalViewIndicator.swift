import SwiftUI

struct ModalViewIndicator: View {
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "minus")
                .imageScale(.large)
                .font(Font.title.weight(.heavy))
                .foregroundColor(Color(UIColor.tertiaryLabel))
            Spacer()
        }.padding(4)
    }
}
