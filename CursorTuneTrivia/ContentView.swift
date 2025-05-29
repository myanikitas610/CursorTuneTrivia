import SwiftUI

struct ContentView: View {
    @State private var isStartHovered = false
    @State private var isHowToPlayHovered = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Image
                Image("contentView")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    // Animated Title
                    VStack(spacing: 0) {
                        glowingText("TUNE")
                            .offset(y: -10)
                            .animation(.easeInOut(duration: 1).repeatForever(), value: isStartHovered)
                        glowingText("TRIVIA")
                            .offset(y: 10)
                            .animation(.easeInOut(duration: 1).delay(0.2).repeatForever(), value: isStartHovered)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 65)
                    
                    Spacer()
                    
                    // Start Button
                    NavigationLink(destination: QuestionView()) {
                        StartButton(isHovered: $isStartHovered)
                    }
                    .padding(.bottom, 50)
                    
                    // How to Play Button
                    NavigationLink(destination: HowToPlayView()) {
                        HowToPlayButton(isHovered: $isHowToPlayHovered)
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                withAnimation {
                    isStartHovered = true
                    isHowToPlayHovered = true
                }
            }
        }
    }
    
    // Glowy Neon Text with Animation
    @ViewBuilder
    func glowingText(_ text: String) -> some View {
        let glowColor = Color(red: 1.0, green: 0.0, blue: 0.6)
        let innerColor = Color(red: 1.0, green: 0.6, blue: 0.8)
        
        Text(text)
            .font(.system(size: 80, weight: .bold))
            .foregroundColor(innerColor)
            .shadow(color: glowColor.opacity(0.8), radius: 20)
            .shadow(color: glowColor.opacity(0.5), radius: 40)
            .accessibilityLabel(text)
    }
}

struct StartButton: View {
    @Binding var isHovered: Bool
    let hotPink = Color(red: 1.0, green: 0.0, blue: 0.6)
    
    var body: some View {
        Text("START")
            .font(.system(size: 35, weight: .medium))
            .fontWeight(.semibold)
            .foregroundColor(hotPink)
            .padding(.vertical, 20)
            .frame(width: 310)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.9), Color.purple.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color.purple.opacity(0.9), radius: 8, x: 0, y: 5)
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
            .accessibilityLabel("Start Game")
            .accessibilityHint("Tap to begin playing TuneTrivia")
    }
}

struct HowToPlayButton: View {
    @Binding var isHovered: Bool
    
    var body: some View {
        Text("How to Play")
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(.white.opacity(0.9))
            .padding(.horizontal, 100)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.purple, lineWidth: 5)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
            .accessibilityLabel("How to Play")
            .accessibilityHint("Tap to learn how to play TuneTrivia")
    }
}

#Preview {
    ContentView()
}

