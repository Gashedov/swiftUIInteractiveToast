import SwiftUI

extension Toast {
    enum DefaultViewType {
        case coppied
        case success
        case warning
    }
    
    init(
        _ type: DefaultViewType,
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.content = switch type {
        case .coppied: AnyView(CoppiedView(id: id))
        case .success: AnyView(SuccessSignInView(id: id))
        case .warning: AnyView(SomethingWentWrongView(id: id))
        }
    }
    
    struct CoppiedView: View {
        var id: String
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: "document.on.document.fill")
                    .frame(width: 24, height: 24)
                
                Text("Coppied")
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }
    
    struct SuccessSignInView: View {
        var id: String
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .frame(width: 24, height: 24)
                
                Text("Success")
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }
    
    struct SomethingWentWrongView: View {
        var id: String
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .frame(width: 24, height: 24)
                
                Text("Something went wrong")
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }
}
