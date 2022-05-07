import SwiftUI

struct AddButton: View {
    var text: String
    var addAction: () -> Void
    
    var body: some View {
        Button(action: addAction) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .padding(.horizontal)
                Text(text)
                    .font(.custom("Shapiro Medium", size: 18))
            }
        }
    }
}
