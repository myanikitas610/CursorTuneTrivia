import SwiftUI

struct HowToPlayView: View {
    @State private var isAnimating = false
    @State private var selectedStep = 0
    
    let steps = [
        InstructionStep(
            icon: "headphones",
            title: "Listen",
            description: "You'll hear a short snippet from a song"
        ),
        InstructionStep(
            icon: "questionmark.circle",
            title: "Guess",
            description: "Guess the title, artist, or release year"
        ),
        InstructionStep(
            icon: "checkmark.circle",
            title: "Score",
            description: "Each correct answer earns you 1 point"
        ),
        InstructionStep(
            icon: "arrow.counterclockwise",
            title: "Replay",
            description: "Play again with new questions"
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("backgroundImage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Title
                    Text("How to Play")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.8))
                        .shadow(color: Color(red: 1.0, green: 0.0, blue: 0.6).opacity(0.8), radius: 10)
                        .padding(.top, 50)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
                    
                    // Instruction Steps
                    TabView(selection: $selectedStep) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            InstructionCard(step: steps[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 200)
                    .padding(.horizontal)
                    
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Circle()
                                .fill(index == selectedStep ? Color.white : Color.white.opacity(0.5))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == selectedStep ? 1.2 : 1.0)
                                .animation(.spring(), value: selectedStep)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Start Playing Button
                    NavigationLink(destination: QuestionView()) {
                        Text("Start Playing")
                            .font(.system(size: 25, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.6))
                            .padding(.vertical, 20)
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
                            .scaleEffect(isAnimating ? 1.0 : 0.8)
                            .opacity(isAnimating ? 1.0 : 0)
                    }
                    .padding(.bottom, 40)
                }
                .padding()
            }
            .onAppear {
                withAnimation {
                    isAnimating = true
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct InstructionStep {
    let icon: String
    let title: String
    let description: String
}

struct InstructionCard: View {
    let step: InstructionStep
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: step.icon)
                .font(.system(size: 40))
                .foregroundColor(.white)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.5)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            Text(step.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(step.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.purple.opacity(0.3))
        .cornerRadius(20)
        .onAppear {
            isAnimating = true
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(step.title): \(step.description)")
    }
}

#Preview {
    HowToPlayView()
}

