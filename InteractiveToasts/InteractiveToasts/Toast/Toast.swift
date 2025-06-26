import SwiftUI

struct Toast: Identifiable {
    var id: String
    var content: AnyView
    
    init(
        @ViewBuilder content: @escaping (String) -> some View,
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.content = .init(content(id))
    }
    
    var offsetX: CGFloat  = 0
    var isDeleting: Bool = false
    var isSheduledForAutoclose: Bool = false
}

extension View {
    @ViewBuilder
    func interactiveToasts(
        _ toasts: Binding<[Toast]>,
        isExpandable: Bool = false,
        autocloseDuration: Double? = nil
    ) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                ToastsView(
                    toasts: toasts,
                    isExpandable: isExpandable,
                    autocloseDuration: autocloseDuration
                )
            }
    }
}

fileprivate struct ToastsView: View {
    @Binding var toasts: [Toast]
    var isExpandable: Bool
    var autocloseDuration: Double?
    
    @State private var isExpanded: Bool = false
    @State private var isAutocloseSheduled = false
    
    init(
        toasts: Binding<[Toast]>,
        isExpandable: Bool = false,
        autocloseDuration: Double? = nil
    ) {
        self._toasts = toasts
        self.isExpandable = isExpandable
        self.autocloseDuration = autocloseDuration
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isExpanded {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture { isExpanded = false }
            }
            
            let layout = isExpanded ?
            AnyLayout(VStackLayout(spacing: 10)) :
            AnyLayout(ZStackLayout())
            
            layout {
                ForEach($toasts) { $toast in
                    let index = (toasts.count - 1) - (toasts.firstIndex(where: { $0.id == toast.id
                    }) ?? 0)
                    
                    if #available(iOS 17.0, *) {
                        toast.content
                            .offset(x: toast.offsetX)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        guard autocloseDuration == nil else { return }
                                        let xOffset = value.translation.width < 0  ? value.translation.width : 0
                                        toast.offsetX = xOffset
                                    }
                                    .onEnded { value in
                                        guard autocloseDuration == nil else { return }
                                        let xOffset = value.translation.width + (value.velocity.width/2)
                                        
                                        if -xOffset > 200 {
                                            $toasts.delete(toast.id)
                                        } else {
                                            toast.offsetX = 0
                                        }
                                    }
                            )
                            .visualEffect { [isExpanded] content, proxy in
                                content
                                    .scaleEffect(isExpanded ? 1 : scale(index), anchor: .bottom)
                                    .offset(y: isExpanded ? 0 : offsetY(index))
                            }
                            .zIndex(toast.isDeleting ? 0 : 1000)
                            .frame(maxWidth: .infinity)
                            .transition(
                                .asymmetric(
                                    insertion: .offset(y: 100),
                                    removal: .move(edge: .leading)
                                )
                            )
                            .onAppear {
                                startAutocloseIfEnabled()
                            }
                    } else {
                        toast.content
                            .offset(x: toast.offsetX)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        guard autocloseDuration == nil else { return }
                                        let xOffset = value.translation.width < 0  ? value.translation.width : 0
                                        toast.offsetX = xOffset
                                    }
                                    .onEnded { value in
                                        guard autocloseDuration == nil else { return }
                                        let xOffset = value.translation.width + (value.velocity.width/2)
                                        
                                        if -xOffset > 200 {
                                            $toasts.delete(toast.id)
                                        } else {
                                            toast.offsetX = 0
                                        }
                                    }
                            )
                            .zIndex(toast.isDeleting ? 0 : 1000)
                            .frame(maxWidth: .infinity)
                            .transition(
                                .asymmetric(
                                    insertion: .offset(y: 100),
                                    removal: .move(edge: .leading)
                                )
                            )
                            .onAppear {
                                startAutocloseIfEnabled()
                            }
                    }
                }
            }
            .onTapGesture {
                if isExpandable { isExpanded.toggle() }
            }
            .padding(.bottom, 15)
        }
        .animation(.bouncy, value: isExpanded)
        .onChange(of: toasts.isEmpty) { _, newValue in
            if newValue { isExpanded = false }
        }
    }
    
    nonisolated func offsetY(_ index: Int) -> CGFloat {
        let offset = min(CGFloat(index) * 15, 30)
        return -offset
    }
    nonisolated func scale(_ index: Int) -> CGFloat {
        let scale = min(CGFloat(index) * 0.1, 1)
        return 1-scale
    }
    
    func startAutocloseIfEnabled() {
        guard let autocloseDuration else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + autocloseDuration) {
            $toasts.deleteAll()
        }
    }
}

extension Binding<[Toast]> {
    func delete(_ id: String) {
        if let toast = first(where: { $0.id == id }) {
            toast.wrappedValue.isDeleting = true
        }
        withAnimation(.bouncy) {
            self.wrappedValue.removeAll { $0.id == id }
        }
    }
    
    func deleteAll() {
        forEach { toast in
            toast.wrappedValue.isDeleting = true
        }
        
        withAnimation(.bouncy) {
            self.wrappedValue.removeAll()
        }
    }
}
