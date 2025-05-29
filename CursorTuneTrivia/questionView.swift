import SwiftUI
import AVFoundation
import Foundation

// Struct to represent a question
struct QuestionMetadata: Codable {
    let songTitle: String
    let artist: String
    let album: String
    let releaseYear: Int
    let genre: String
    let difficulty: String
}

struct Question: Identifiable, Codable {
    let id: String
    let audioURL: URL
    let startTime: Double
    let endTime: Double
    let questionText: String
    let options: [String]
    let correctAnswer: String
    let metadata: QuestionMetadata
    
    enum CodingKeys: String, CodingKey {
        case id, audioURL, startTime, endTime, questionText, options, correctAnswer, metadata
    }
}

// View for displaying a question with options
struct QuestionView: View {
    @State private var questions: [Question] = []  // List to hold questions
    @State private var currentQuestionIndex = 0  // Tracks the current question
    @State private var score = 0  // User's score
    @State private var showAlert = false  // Flag to show alert after answering
    @State private var alertMessage = ""  // Message to show in the alert
    @State private var goToResults = false  // Flag to navigate to results
    @State private var player: AVPlayer?  // Audio player
    @State private var isLoading = true  // Flag to indicate loading state
    @State private var isPlaying = false  // Flag to indicate if audio is playing
    @State private var selectedAnswer: String?  // Selected answer
    @State private var showFeedback = false  // Flag to show feedback
    @State private var isCorrect = false  // Flag to indicate if the answer is correct

    var body: some View {
        NavigationStack {
            ZStack {
                // Set background image
                Image("questionView")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                if isLoading {
                    LoadingView()
                } else if !questions.isEmpty {
                    VStack(spacing: 20) {
                        ProgressBar(current: currentQuestionIndex + 1, total: questions.count)
                            .padding(.top)
                        
                        QuestionHeader(questionNumber: currentQuestionIndex + 1, total: questions.count)
                        
                        QuestionContent(
                            question: questions[currentQuestionIndex],
                            isPlaying: $isPlaying,
                            selectedAnswer: $selectedAnswer,
                            showFeedback: $showFeedback,
                            isCorrect: $isCorrect,
                            onPlayTapped: playAudioSnippet,
                            onAnswerSelected: checkAnswer
                        )
                    }
                    .padding()
                    .background(Color(red: 203/255, green: 108/255, blue: 230/255).opacity(0.80))
                    .cornerRadius(25)
                    .padding(.horizontal)
                    .animation(.easeInOut, value: currentQuestionIndex)
                }
            }
            .navigationBarBackButtonHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertMessage),
                    dismissButton: .default(Text("Next")) {
                        withAnimation {
                            goToNextQuestion()
                        }
                    }
                )
            }
            .navigationDestination(isPresented: $goToResults) {
                // Navigate to results view when all questions are answered
                ResultView(score: score, total: questions.count)
            }
        }
        .onAppear {
            loadQuestionsFromJSON()  // Load questions when view appears
        }
    }

    // Play the audio snippet for the current question
    private func playAudioSnippet() {
        guard let question = questions[safe: currentQuestionIndex] else { return }
        
        let start = CMTime(seconds: question.startTime, preferredTimescale: 1)
        let duration = question.endTime - question.startTime
        
        let playerItem = AVPlayerItem(url: question.audioURL)
        player = AVPlayer(playerItem: playerItem)
        
        let observer = playerItem.observe(\.status, options: [.initial, .new]) { item, _ in
            if item.status == .readyToPlay {
                player?.seek(to: start) { _ in
                    player?.play()
                    isPlaying = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        player?.pause()
                        isPlaying = false
                    }
                }
            } else if item.status == .failed {
                alertMessage = "Failed to load audio. Please try again."
                showAlert = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            observer.invalidate()
        }
    }

    // Stop the audio if it's playing
    private func stopAudio() {
        player?.pause()
        player = nil
        isPlaying = false
    }

    // Check if the selected answer is correct
    private func checkAnswer(selected: String) {
        selectedAnswer = selected
        let correct = questions[currentQuestionIndex].correctAnswer
        isCorrect = selected == correct
        
        if isCorrect {
            score += 1
            alertMessage = "Correct! 🎉"
        } else {
            alertMessage = "Wrong! The correct answer was '\(correct)' 😔"
        }
        
        showFeedback = true
        stopAudio()  // Stop audio playback
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showAlert = true
            showFeedback = false
        }
    }

    // Move to the next question or go to the results if it's the last question
    private func goToNextQuestion() {
        selectedAnswer = nil
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1  // Go to the next question
        } else {
            goToResults = true  // Navigate to the results
        }
    }

    // Load questions from a JSON file
    private func loadQuestionsFromJSON() {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            print("Failed to find questions.json")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            var decodedQuestions = try JSONDecoder().decode([Question].self, from: data)
            decodedQuestions.shuffle()  // Shuffle the questions for random order
            questions = Array(decodedQuestions.prefix(10))  // Limit to 10 questions
            isLoading = false
        } catch {
            print("Failed to load questions: \(error)")
            alertMessage = "Failed to load questions. Please restart the app."
            showAlert = true
        }
    }
}

// MARK: - Supporting Views

struct LoadingView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack {
            Image(systemName: "music.note")
                .font(.system(size: 50))
                .foregroundColor(.white)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            Text("Loading Questions...")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

struct ProgressBar: View {
    let current: Int
    let total: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 8)
                    .opacity(0.3)
                    .foregroundColor(.white)
                
                Rectangle()
                    .frame(width: geometry.size.width * CGFloat(current) / CGFloat(total), height: 8)
                    .foregroundColor(.purple)
                    .animation(.linear, value: current)
            }
            .cornerRadius(4)
        }
        .frame(height: 8)
        .padding(.horizontal)
    }
}

struct QuestionHeader: View {
    let questionNumber: Int
    let total: Int
    
    var body: some View {
        VStack {
            Text("Question \(questionNumber) of \(total)")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
            
            Text("Quiz Time")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .foregroundColor(.white)
                .background(Color(red: 206/255, green: 89/255, blue: 203/255))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.purple, lineWidth: 3)
                )
                .cornerRadius(10)
        }
    }
}

struct QuestionContent: View {
    let question: Question
    @Binding var isPlaying: Bool
    @Binding var selectedAnswer: String?
    @Binding var showFeedback: Bool
    @Binding var isCorrect: Bool
    let onPlayTapped: () -> Void
    let onAnswerSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(question.questionText)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
                .accessibilityLabel("Question: \(question.questionText)")
            
            Button(action: onPlayTapped) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)
                    .accessibilityLabel(isPlaying ? "Pause audio" : "Play audio")
            }
            .disabled(showFeedback)
            .padding(.bottom, 10)
            
            ForEach(question.options, id: \.self) { option in
                Button(action: { onAnswerSelected(option) }) {
                    Text(option)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(backgroundForOption(option))
                        .foregroundColor(textColorForOption(option))
                        .cornerRadius(15)
                }
                .disabled(showFeedback)
                .accessibilityLabel("\(option), \(accessibilityLabelForOption(option))")
            }
        }
    }
    
    private func backgroundForOption(_ option: String) -> Color {
        guard showFeedback else {
            return selectedAnswer == option ? .white : Color.black.opacity(0.8)
        }
        
        if option == question.correctAnswer {
            return .green.opacity(0.8)
        }
        return selectedAnswer == option ? .red.opacity(0.8) : Color.black.opacity(0.8)
    }
    
    private func textColorForOption(_ option: String) -> Color {
        guard showFeedback else {
            return selectedAnswer == option ? .black : .white
        }
        return .white
    }
    
    private func accessibilityLabelForOption(_ option: String) -> String {
        if showFeedback {
            if option == question.correctAnswer {
                return "Correct answer"
            }
            return selectedAnswer == option ? "Your incorrect answer" : "Incorrect answer"
        }
        return ""
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    QuestionView()
}
