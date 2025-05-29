import SwiftUI

struct ResultView: View {
    let score: Int
    let total: Int
    @State private var isAnimating = false
    @State private var showConfetti = false
    
    var scorePercentage: Double {
        Double(score) / Double(total) * 100
    }
    
    var scoreMessage: String {
        switch scorePercentage {
        case 100:
            return "Perfect Score! 🎉"
        case 80..<100:
            return "Amazing! 🌟"
        case 60..<80:
            return "Great Job! 👏"
        case 40..<60:
            return "Good Try! 💪"
        default:
            return "Keep Practicing! 🎵"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Image
                Image("backgroundImage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // Confetti View
                if showConfetti {
                    ConfettiView()
                }
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Score Message
                    Text(scoreMessage)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                    
                    // Score Display
                    ScoreCircle(score: score, total: total, isAnimating: isAnimating)
                    
                    Spacer()
                    
                    // Play Again Button
                    NavigationLink(destination: ContentView()) {
                        PlayAgainButton(isAnimating: $isAnimating)
                    }
                    .padding(.bottom, 80)
                }
                .padding()
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfetti = scorePercentage >= 80
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ScoreCircle: View {
    let score: Int
    let total: Int
    let isAnimating: Bool
    
    private var percentage: Double {
        Double(score) / Double(total)
    }
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 15)
                .frame(width: 200, height: 200)
            
            // Score Circle
            Circle()
                .trim(from: 0, to: isAnimating ? percentage : 0)
                .stroke(
                    LinearGradient(
                        colors: [.purple, Color(red: 1.0, green: 0.0, blue: 0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: isAnimating)
            
            // Score Text
            VStack(spacing: 5) {
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                Text("out of")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))
                Text("\(total)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            .opacity(isAnimating ? 1 : 0)
            .scaleEffect(isAnimating ? 1 : 0.5)
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isAnimating)
        }
    }
}

struct PlayAgainButton: View {
    @Binding var isAnimating: Bool
    let hotPink = Color(red: 1.0, green: 0.0, blue: 0.6)
    
    var body: some View {
        Text("PLAY AGAIN")
            .font(.system(size: 30, weight: .medium))
            .foregroundColor(hotPink)
            .padding(.vertical, 18)
            .frame(width: 280)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.9), Color.purple.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 5)
            .scaleEffect(isAnimating ? 1 : 0.8)
            .opacity(isAnimating ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3), value: isAnimating)
    }
}

struct ConfettiView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<50) { index in
                ConfettiPiece(
                    color: colors[index % colors.count],
                    size: geometry.size
                )
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let size: CGSize
    
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .position(
                x: .random(in: 0...size.width),
                y: isAnimating ? size.height + 50 : -50
            )
            .opacity(isAnimating ? 0 : 1)
            .animation(
                .linear(duration: Double.random(in: 2...4))
                .repeatForever(autoreverses: false)
                .delay(Double.random(in: 0...2)),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

#Preview {
    ResultView(score: 8, total: 10)
}
