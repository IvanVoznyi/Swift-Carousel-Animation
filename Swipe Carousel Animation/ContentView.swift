import SwiftUI

struct CarouselItem: View {
    let image: String
    
    var body: some View {
        GeometryReader { geometry in
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(maxHeight: geometry.size.height)
        }
    }
}

class MyState {
    var currentItem = 0
}

struct ContentView: View {
    @State private var offset: CGFloat = 0
    let items: [String] = ["NY_1","NY_2", "NY_3", "NY_4", "NY_5", "NY_6", "NY_7", "NY_8", "NY_9"]
    @State var currentIndex = 0
    @State var isSwipingLeft = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(items, id: \.self) { item in
                    CarouselItem(image: item)
                        .frame(width: geometry.size.width)
                        .clipShape(
                            Rectangle()
                                .offset(x: (!(isSwipingLeft && currentIndex == 0) && !(!isSwipingLeft && currentIndex == items.count - 1)) && item == items[currentIndex] ? offset : 0)
                            )
                        .zIndex(zIndex(item: item))
                }
            }
            .ignoresSafeArea()

            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    ForEach(items, id: \.self) { index in
                        GeometryReader { innerView in
                            CarouselItem(image: index)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.white, lineWidth: 10)
                                )
                                .offset(x: offset)
                        }
                        .padding(.horizontal, 70)
                        .frame(width: geometry.size.width, height: 400)
                        .offset(x: -CGFloat(currentIndex) * geometry.size.width)
                    }
                }
                .frame(height: geometry.size.height)
                .frame(maxWidth: .infinity, alignment: .center)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isSwipingLeft = value.translation.width > 0
                            offset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold = geometry.size.width * 0.3
                            
                            if value.translation.width > threshold && currentIndex != 0 {
                                withAnimation {
                                    offset = geometry.size.width
                                } completion: {
                                    currentIndex = max(0, currentIndex - 1)
                                    offset = 0
                                }
                            } else if value.translation.width < -threshold && currentIndex != items.count - 1 {
                                withAnimation {
                                    offset = -geometry.size.width
                                } completion: {
                                    currentIndex = min(currentIndex + 1, items.count - 1)
                                    offset = 0
                                }
                            } else {
                                offset = 0
                            }
                        }
                )
            }
        }
        .animation(.interpolatingSpring(.smooth), value: offset)
    }
    
    private func zIndex(item: String) -> Double {
        let index = items.firstIndex(of: item) ?? 0
        
        if isSwipingLeft {
            return index == currentIndex ? Double(items.count) - Double(index) :
            (index > currentIndex) ? -Double(items.count) - Double(index) :
            Double(items.count) - Double(currentIndex)
        } else if index < currentIndex {
            return  -Double(items.count) - Double(index)
        }
        return Double(items.count) - Double(index)
    }
}

#Preview {
    ContentView()
}
