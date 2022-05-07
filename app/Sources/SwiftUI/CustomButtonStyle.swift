import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.custom("Shapiro Semi Wide", size: 14))
            .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
            .background(Color(DefaultColor.primary))
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .padding()
    }
}
