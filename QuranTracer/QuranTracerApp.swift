import SwiftUI
import CoreGraphics
import Combine

// MARK: - Data Models

/// Represents a single point in a user's drawing path. Can be absolute (in view coordinates) or relative (0-1 scale).
struct PathPoint: Equatable {
    var point: CGPoint
    var isStartOfNewStroke: Bool = false
}

/// Represents a single Arabic letter, including its shape and the correct tracing path.
struct ArabicLetter: Identifiable, Hashable {
    let id: String // Use the letter's name as a stable ID
    let name: String
    let initialForm: String
    /// The correct tracing path, defined in a relative coordinate system (0.0 to 1.0).
    let correctRelativePath: [PathPoint]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ArabicLetter, rhs: ArabicLetter) -> Bool {
        lhs.id == rhs.id
    }
}

/// Represents a verse (Ayah) from the Quran.
struct Ayah: Identifiable, Hashable {
    let id = UUID()
    let surahNumber: Int
    let ayahNumber: Int
    let text: String
    // Ayahs would also have a relative path in a full implementation
    // let correctRelativePath: [PathPoint]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Ayah, rhs: Ayah) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Progress Manager
class ProgressManager: ObservableObject {
    @Published var highScores: [String: Int] = [:]
    
    private let highScoresKey = "highScores"
    
    init() {
        loadHighScores()
    }
    
    func loadHighScores() {
        let savedScores = UserDefaults.standard.dictionary(forKey: highScoresKey) as? [String: Int] ?? [:]
        // Ensure the first letter is always unlocked
        var scores = savedScores
        if scores.isEmpty {
            scores[LetterData.letters[0].id] = 0
        }
        self.highScores = scores
    }
    
    func saveHighScore(for letterId: String, stars: Int) {
        let currentBest = highScores[letterId] ?? 0
        if stars > currentBest {
            highScores[letterId] = stars
            UserDefaults.standard.set(highScores, forKey: highScoresKey)
            unlockNextLetter(after: letterId)
        }
    }
    
    func unlockNextLetter(after currentLetterId: String) {
        guard let currentIndex = LetterData.letters.firstIndex(where: { $0.id == currentLetterId }) else { return }
        let nextIndex = currentIndex + 1
        if nextIndex < LetterData.letters.count {
            let nextLetter = LetterData.letters[nextIndex]
            if highScores[nextLetter.id] == nil {
                highScores[nextLetter.id] = 0 // Unlock it with 0 stars
                UserDefaults.standard.set(highScores, forKey: highScoresKey)
            }
        }
    }
    
    func isUnlocked(_ letterId: String) -> Bool {
        return highScores[letterId] != nil
    }
}

// MARK: - Letter Data
struct LetterData {
    static let letters: [ArabicLetter] = [
        ArabicLetter(id: "Alif", name: "Alif", initialForm: "ا", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.5, y: 0.15), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.85))
        ]),
        ArabicLetter(id: "Ba", name: "Ba", initialForm: "ب", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.8, y: 0.6), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.7, y: 0.7)), PathPoint(point: CGPoint(x: 0.5, y: 0.8)), PathPoint(point: CGPoint(x: 0.3, y: 0.7)), PathPoint(point: CGPoint(x: 0.2, y: 0.6)),
            PathPoint(point: CGPoint(x: 0.5, y: 0.85), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.851))
        ]),
        ArabicLetter(id: "Ta", name: "Ta", initialForm: "ت", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.8, y: 0.6), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.7, y: 0.7)), PathPoint(point: CGPoint(x: 0.5, y: 0.8)), PathPoint(point: CGPoint(x: 0.3, y: 0.7)), PathPoint(point: CGPoint(x: 0.2, y: 0.6)),
            PathPoint(point: CGPoint(x: 0.4, y: 0.55), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.4, y: 0.551)),
            PathPoint(point: CGPoint(x: 0.6, y: 0.55), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.6, y: 0.551))
        ]),
        ArabicLetter(id: "Thaa", name: "Thaa", initialForm: "ث", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.8, y: 0.6), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.7, y: 0.7)), PathPoint(point: CGPoint(x: 0.5, y: 0.8)), PathPoint(point: CGPoint(x: 0.3, y: 0.7)), PathPoint(point: CGPoint(x: 0.2, y: 0.6)),
            PathPoint(point: CGPoint(x: 0.5, y: 0.5), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.501)),
            PathPoint(point: CGPoint(x: 0.4, y: 0.6), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.4, y: 0.601)),
            PathPoint(point: CGPoint(x: 0.6, y: 0.6), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.6, y: 0.601))
        ]),
        ArabicLetter(id: "Jiim", name: "Jiim", initialForm: "ج", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.75, y: 0.3), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.25, y: 0.4)),
            PathPoint(point: CGPoint(x: 0.25, y: 0.4), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.5, y: 0.85)), PathPoint(point: CGPoint(x: 0.8, y: 0.6)),
            PathPoint(point: CGPoint(x: 0.5, y: 0.65), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.651))
        ]),
        ArabicLetter(id: "Haa", name: "Haa", initialForm: "ح", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.75, y: 0.3), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.25, y: 0.4)),
            PathPoint(point: CGPoint(x: 0.25, y: 0.4), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.5, y: 0.85)), PathPoint(point: CGPoint(x: 0.8, y: 0.6))
        ]),
        ArabicLetter(id: "Khaa", name: "Khaa", initialForm: "خ", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.75, y: 0.3), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.25, y: 0.4)),
            PathPoint(point: CGPoint(x: 0.25, y: 0.4), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.5, y: 0.85)), PathPoint(point: CGPoint(x: 0.8, y: 0.6)),
            PathPoint(point: CGPoint(x: 0.5, y: 0.2), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.201))
        ]),
        ArabicLetter(id: "Daal", name: "Daal", initialForm: "د", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.7, y: 0.3), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.4, y: 0.8)), PathPoint(point: CGPoint(x: 0.75, y: 0.8))
        ]),
        ArabicLetter(id: "Dhal", name: "Dhal", initialForm: "ذ", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.7, y: 0.3), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.4, y: 0.8)), PathPoint(point: CGPoint(x: 0.75, y: 0.8)),
            PathPoint(point: CGPoint(x: 0.6, y: 0.2), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.6, y: 0.201))
        ]),
        ArabicLetter(id: "Raa", name: "Raa", initialForm: "ر", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.6, y: 0.4), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.4, y: 0.85))
        ]),
        ArabicLetter(id: "Zai", name: "Zai", initialForm: "ز", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.6, y: 0.4), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.4, y: 0.85)),
            PathPoint(point: CGPoint(x: 0.55, y: 0.3), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.55, y: 0.301))
        ]),
        ArabicLetter(id: "Siin", name: "Siin", initialForm: "س", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.8, y: 0.5), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.7, y: 0.4)), PathPoint(point: CGPoint(x: 0.6, y: 0.5)),
            PathPoint(point: CGPoint(x: 0.6, y: 0.5), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.5, y: 0.4)), PathPoint(point: CGPoint(x: 0.4, y: 0.5)),
            PathPoint(point: CGPoint(x: 0.4, y: 0.5), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.1, y: 0.8)), PathPoint(point: CGPoint(x: 0.5, y: 0.9))
        ]),
        ArabicLetter(id: "Shiin", name: "Shiin", initialForm: "ش", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.8, y: 0.5), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.7, y: 0.4)), PathPoint(point: CGPoint(x: 0.6, y: 0.5)),
            PathPoint(point: CGPoint(x: 0.6, y: 0.5), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.5, y: 0.4)), PathPoint(point: CGPoint(x: 0.4, y: 0.5)),
            PathPoint(point: CGPoint(x: 0.4, y: 0.5), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.1, y: 0.8)), PathPoint(point: CGPoint(x: 0.5, y: 0.9)),
            PathPoint(point: CGPoint(x: 0.6, y: 0.25), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.6, y: 0.251)),
            PathPoint(point: CGPoint(x: 0.5, y: 0.3), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.301)),
            PathPoint(point: CGPoint(x: 0.7, y: 0.3), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.7, y: 0.301))
        ]),
        ArabicLetter(id: "Saad", name: "Saad", initialForm: "ص", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.2, y: 0.7), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.8, y: 0.7)), PathPoint(point: CGPoint(x: 0.6, y: 0.5)), PathPoint(point: CGPoint(x: 0.2, y: 0.7)),
            PathPoint(point: CGPoint(x: 0.6, y: 0.5), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.4, y: 0.8)), PathPoint(point: CGPoint(x: 0.7, y: 0.9))
        ]),
        ArabicLetter(id: "Daad", name: "Daad", initialForm: "ض", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.2, y: 0.7), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.8, y: 0.7)), PathPoint(point: CGPoint(x: 0.6, y: 0.5)), PathPoint(point: CGPoint(x: 0.2, y: 0.7)),
            PathPoint(point: CGPoint(x: 0.6, y: 0.5), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.4, y: 0.8)), PathPoint(point: CGPoint(x: 0.7, y: 0.9)),
            PathPoint(point: CGPoint(x: 0.7, y: 0.4), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.7, y: 0.401))
        ]),
        ArabicLetter(id: "Taa", name: "Taa", initialForm: "ط", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.2, y: 0.8), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.8, y: 0.8)), PathPoint(point: CGPoint(x: 0.6, y: 0.6)), PathPoint(point: CGPoint(x: 0.2, y: 0.8)),
            PathPoint(point: CGPoint(x: 0.65, y: 0.6), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.6, y: 0.2))
        ]),
        ArabicLetter(id: "Thhaa", name: "Thhaa", initialForm: "ظ", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.2, y: 0.8), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.8, y: 0.8)), PathPoint(point: CGPoint(x: 0.6, y: 0.6)), PathPoint(point: CGPoint(x: 0.2, y: 0.8)),
            PathPoint(point: CGPoint(x: 0.65, y: 0.6), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.6, y: 0.2)),
            PathPoint(point: CGPoint(x: 0.35, y: 0.5), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.35, y: 0.501))
        ]),
        ArabicLetter(id: "Ayn", name: "Ayn", initialForm: "ع", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.7, y: 0.4), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.3)), PathPoint(point: CGPoint(x: 0.3, y: 0.5)),
            PathPoint(point: CGPoint(x: 0.3, y: 0.5), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.2, y: 0.8)), PathPoint(point: CGPoint(x: 0.7, y: 0.9))
        ]),
        ArabicLetter(id: "Ghayn", name: "Ghayn", initialForm: "غ", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.7, y: 0.4), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.3)), PathPoint(point: CGPoint(x: 0.3, y: 0.5)),
            PathPoint(point: CGPoint(x: 0.3, y: 0.5), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.2, y: 0.8)), PathPoint(point: CGPoint(x: 0.7, y: 0.9)),
            PathPoint(point: CGPoint(x: 0.6, y: 0.2), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.6, y: 0.201))
        ]),
        ArabicLetter(id: "Faa", name: "Faa", initialForm: "ف", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.6, y: 0.4), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.3)), PathPoint(point: CGPoint(x: 0.4, y: 0.4)), PathPoint(point: CGPoint(x: 0.6, y: 0.4)),
            PathPoint(point: CGPoint(x: 0.4, y: 0.4), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.2, y: 0.7)), PathPoint(point: CGPoint(x: 0.8, y: 0.7)),
            PathPoint(point: CGPoint(x: 0.5, y: 0.2), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.201))
        ]),
        ArabicLetter(id: "Qaaf", name: "Qaaf", initialForm: "ق", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.6, y: 0.4), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.3)), PathPoint(point: CGPoint(x: 0.4, y: 0.4)), PathPoint(point: CGPoint(x: 0.6, y: 0.4)),
            PathPoint(point: CGPoint(x: 0.4, y: 0.4), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.2, y: 0.8)), PathPoint(point: CGPoint(x: 0.8, y: 0.8)),
            PathPoint(point: CGPoint(x: 0.45, y: 0.2), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.45, y: 0.201)),
            PathPoint(point: CGPoint(x: 0.55, y: 0.2), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.55, y: 0.201))
        ]),
        ArabicLetter(id: "Kaaf", name: "Kaaf", initialForm: "ك", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.8, y: 0.2), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.2, y: 0.2)), PathPoint(point: CGPoint(x: 0.2, y: 0.8)), PathPoint(point: CGPoint(x: 0.8, y: 0.8)),
            PathPoint(point: CGPoint(x: 0.6, y: 0.4), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.4, y: 0.6)), PathPoint(point: CGPoint(x: 0.6, y: 0.6)), PathPoint(point: CGPoint(x: 0.5, y: 0.7))
        ]),
        ArabicLetter(id: "Laam", name: "Laam", initialForm: "ل", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.7, y: 0.1), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.7, y: 0.7)), PathPoint(point: CGPoint(x: 0.3, y: 0.8)), PathPoint(point: CGPoint(x: 0.6, y: 0.9))
        ]),
        ArabicLetter(id: "Miim", name: "Miim", initialForm: "م", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.7, y: 0.4), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.6, y: 0.3)), PathPoint(point: CGPoint(x: 0.5, y: 0.4)), PathPoint(point: CGPoint(x: 0.7, y: 0.4)),
            PathPoint(point: CGPoint(x: 0.5, y: 0.4), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.3, y: 0.9))
        ]),
        ArabicLetter(id: "Nuun", name: "Nuun", initialForm: "ن", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.8, y: 0.4), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.8)), PathPoint(point: CGPoint(x: 0.2, y: 0.4)),
            PathPoint(point: CGPoint(x: 0.5, y: 0.3), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.301))
        ]),
        ArabicLetter(id: "Haa (end)", name: "Haa (end)", initialForm: "ه", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.5, y: 0.3), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.7, y: 0.5)), PathPoint(point: CGPoint(x: 0.5, y: 0.7)), PathPoint(point: CGPoint(x: 0.3, y: 0.5)), PathPoint(point: CGPoint(x: 0.5, y: 0.3))
        ]),
        ArabicLetter(id: "Waaw", name: "Waaw", initialForm: "و", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.6, y: 0.4), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.5, y: 0.3)), PathPoint(point: CGPoint(x: 0.4, y: 0.4)), PathPoint(point: CGPoint(x: 0.6, y: 0.4)),
            PathPoint(point: CGPoint(x: 0.4, y: 0.4), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.3, y: 0.8))
        ]),
        ArabicLetter(id: "Yaa", name: "Yaa", initialForm: "ي", correctRelativePath: [
            PathPoint(point: CGPoint(x: 0.8, y: 0.5), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.7, y: 0.4)), PathPoint(point: CGPoint(x: 0.6, y: 0.5)),
            PathPoint(point: CGPoint(x: 0.6, y: 0.5), isStartOfNewStroke: false), PathPoint(point: CGPoint(x: 0.2, y: 0.8)), PathPoint(point: CGPoint(x: 0.7, y: 0.9)),
            PathPoint(point: CGPoint(x: 0.45, y: 0.9), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.45, y: 0.901)),
            PathPoint(point: CGPoint(x: 0.55, y: 0.9), isStartOfNewStroke: true), PathPoint(point: CGPoint(x: 0.55, y: 0.901))
        ])
    ]
}

// MARK: - Main App Entry
@main
struct QuranTracerApp: App {
    @StateObject private var progressManager = ProgressManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progressManager)
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @State private var selection: AppScreen = .menu

    enum AppScreen {
        case menu
        case letterSelection
        case ayahSelection
        case tracing(AnyHashable)
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.teal.opacity(0.8), Color.blue.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            switch selection {
            case .menu:
                MainMenuView(selection: $selection)
            case .letterSelection:
                LetterSelectionView(selection: $selection)
            case .ayahSelection:
                AyahSelectionView(selection: $selection)
            case .tracing(let item):
                if let letter = item as? ArabicLetter {
                    TracingView(item: letter, onBack: { selection = .letterSelection })
                } else if let ayah = item as? Ayah {
                    TracingView(item: ayah, onBack: { selection = .ayahSelection })
                }
            }
        }
    }
}

// MARK: - Main Menu View
struct MainMenuView: View {
    @Binding var selection: ContentView.AppScreen

    var body: some View {
        VStack(spacing: 40) {
            Text("Quran Tracer")
                .font(.system(size: 48, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .shadow(radius: 10)

            VStack(spacing: 20) {
                Button(action: { selection = .letterSelection }) {
                    MenuButton(title: "Practice Letters", icon: "a.square.fill")
                }
                
                Button(action: { selection = .ayahSelection }) {
                    MenuButton(title: "Trace Ayahs", icon: "text.book.closed.fill")
                }
            }
        }
        .padding()
    }
}

struct MenuButton: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.9))
        .foregroundColor(.teal)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}


// MARK: - Letter Selection View
struct LetterSelectionView: View {
    @Binding var selection: ContentView.AppScreen
    @EnvironmentObject var progressManager: ProgressManager

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    ForEach(LetterData.letters, id: \.id) { letter in
                        let isUnlocked = progressManager.isUnlocked(letter.id)
                        let stars = progressManager.highScores[letter.id] ?? 0
                        
                        Button(action: {
                            if isUnlocked {
                                selection = .tracing(letter)
                            }
                        }) {
                            VStack {
                                if isUnlocked {
                                    Text(letter.initialForm)
                                        .font(.system(size: 60))
                                    HStack {
                                        ForEach(1...3, id: \.self) { index in
                                            Image(systemName: index <= stars ? "star.fill" : "star")
                                                .foregroundColor(index <= stars ? .yellow : .gray.opacity(0.5))
                                                .font(.caption)
                                        }
                                    }
                                } else {
                                    Image(systemName: "lock.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                            }
                            .frame(width: 100, height: 100)
                            .padding()
                            .background(isUnlocked ? Color.white.opacity(0.9) : Color.gray.opacity(0.4))
                            .cornerRadius(20)
                            .foregroundColor(.black)
                        }
                        .disabled(!isUnlocked)
                    }
                }
                .padding()
            }
            .navigationTitle("Select a Letter")
            .navigationBarItems(leading: Button(action: { selection = .menu }) {
                Image(systemName: "arrow.backward.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
            })
            .background(Color.clear)
        }
        .accentColor(.white)
    }
}

// MARK: - Ayah Selection View
struct AyahSelectionView: View {
    @Binding var selection: ContentView.AppScreen

    let ayahs: [Ayah] = [
        Ayah(surahNumber: 1, ayahNumber: 1, text: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
    ]

    var body: some View {
        NavigationView {
            List(ayahs) { ayah in
                Button(action: { selection = .tracing(ayah) }) {
                    VStack(alignment: .trailing) {
                        Text(ayah.text)
                            .font(.system(size: 28, design: .serif))
                            .multilineTextAlignment(.trailing)
                        Text("Surah \(ayah.surahNumber), Ayah \(ayah.ayahNumber)")
                            .font(.caption)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .listRowBackground(Color.white.opacity(0.8))
            }
            .navigationTitle("Select an Ayah")
            .navigationBarItems(leading: Button(action: { selection = .menu }) {
                 Image(systemName: "arrow.backward.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
            })
            .background(Color.clear)
        }
    }
}


// MARK: - Tracing View
struct TracingView: View {
    let item: AnyHashable
    var onBack: () -> Void
    @EnvironmentObject var progressManager: ProgressManager

    @State private var userPath: [PathPoint] = []
    @State private var accuracy: Double = 0.0
    @State private var isDrawing = false
    @State private var starsEarned: Int = 0
    @State private var showCompletionView: Bool = false
    @State private var isTraceComplete: Bool = false

    private var letter: ArabicLetter? {
        item as? ArabicLetter
    }
    
    private var correctRelativePath: [PathPoint] {
        letter?.correctRelativePath ?? []
    }

    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: onBack) { Image(systemName: "arrow.backward.circle.fill").font(.largeTitle).foregroundColor(.white) }
                Spacer()
                Text("Trace the text").font(.title).fontWeight(.bold).foregroundColor(.white)
                Spacer()
                Button(action: clearDrawing) { Image(systemName: "trash.circle.fill").font(.largeTitle).foregroundColor(.white) }
            }.padding()

            // Star Rating Display
            HStack(spacing: 10) {
                ForEach(1...3, id: \.self) { index in
                    Image(systemName: index <= starsEarned ? "star.fill" : "star")
                        .foregroundColor(index <= starsEarned ? .yellow : .white.opacity(0.5))
                        .font(.largeTitle)
                }
            }
            .padding(.bottom)

            // Accuracy Display
            Text("Accuracy: \(accuracy, specifier: "%.1f")%").font(.title2).foregroundColor(.white).padding().background(Color.black.opacity(0.3)).cornerRadius(15)

            // Drawing Canvas
            GeometryReader { geometry in
                ZStack {
                    // Guideline Text
                    if let letter = letter {
                        Text(letter.initialForm)
                            .font(.system(size: anAppropriateFontSize(for: letter.initialForm, in: geometry.size)))
                            .foregroundColor(.white.opacity(0.25))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    // User's drawing path
                    Path { path in
                        draw(path: &path, from: userPath)
                    }
                    .stroke(Color.yellow, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    
                    // "Check" button
                    if isTraceComplete {
                        VStack {
                            Spacer()
                            Button(action: {
                                calculateAccuracy(in: geometry.size)
                            }) {
                                Text("Check")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 15)
                                    .padding(.horizontal, 50)
                                    .background(Color.green)
                                    .cornerRadius(25)
                                    .shadow(radius: 5)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color.black.opacity(0.2))
                .cornerRadius(20)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !isDrawing {
                                showCompletionView = false
                                isTraceComplete = false
                                starsEarned = 0
                                userPath.append(PathPoint(point: value.location, isStartOfNewStroke: true))
                                isDrawing = true
                            } else {
                                userPath.append(PathPoint(point: value.location))
                            }
                        }
                        .onEnded { value in
                            isDrawing = false
                            if !userPath.isEmpty {
                                isTraceComplete = true
                            }
                        }
                )
                .overlay(
                    showCompletionView ? CompletionView(stars: starsEarned, accuracy: accuracy, onContinue: onBack) : nil
                )
            }
            .padding()
        }
    }

    private func draw(path: inout Path, from points: [PathPoint]) {
        guard !points.isEmpty else { return }
        var currentPoint: CGPoint? = nil
        for p in points {
            if p.isStartOfNewStroke {
                currentPoint = nil
            }
            if currentPoint == nil {
                path.move(to: p.point)
                currentPoint = p.point
            } else {
                path.addLine(to: p.point)
            }
        }
    }

    private func anAppropriateFontSize(for text: String, in size: CGSize) -> CGFloat {
        let baseSize = min(size.width, size.height)
        if text.count > 10 { return baseSize / 8 }
        if text.count > 5 { return baseSize / 5 }
        return baseSize / 2.5
    }

    private func clearDrawing() {
        userPath.removeAll()
        accuracy = 0.0
        starsEarned = 0
        showCompletionView = false
        isTraceComplete = false
    }
    
    // MARK: - Accuracy Calculation Logic
    
    private func transform(relativePath: [PathPoint], in size: CGSize) -> [PathPoint] {
        return relativePath.map { rp in
            let absolutePoint = CGPoint(x: rp.point.x * size.width, y: rp.point.y * size.height)
            return PathPoint(point: absolutePoint, isStartOfNewStroke: rp.isStartOfNewStroke)
        }
    }
    
    private func calculateAccuracy(in size: CGSize) {
        let correctAbsolutePath = transform(relativePath: correctRelativePath, in: size)
        
        guard !userPath.isEmpty, !correctAbsolutePath.isEmpty, let currentLetter = letter else {
            accuracy = 0
            starsEarned = 0
            return
        }

        let gridSize = 35
        let correctCells = getCoveredCells(for: correctAbsolutePath, gridSize: gridSize, size: size)
        let userCells = getCoveredCells(for: userPath, gridSize: gridSize, size: size)

        guard !correctCells.isEmpty, !userCells.isEmpty else {
            accuracy = 0
            starsEarned = 0
            return
        }
        
        let intersection = correctCells.intersection(userCells)
        let coverageScore = Double(intersection.count) / Double(correctCells.count)
        let precisionScore = Double(intersection.count) / Double(userCells.count)
        
        let baseScore = (coverageScore * 0.9 + precisionScore * 0.1) * 100.0
        let finalScore = min(100.0, baseScore * 2.5)
        
        accuracy = finalScore
        
        if accuracy >= 85 {
            starsEarned = 3
        } else if accuracy >= 70 {
            starsEarned = 2
        } else if accuracy >= 60 {
            starsEarned = 1
        } else {
            starsEarned = 0
        }
        
        if starsEarned > 0 {
            progressManager.saveHighScore(for: currentLetter.id, stars: starsEarned)
        }
        
        isTraceComplete = false
        showCompletionView = true
    }

    private func getCoveredCells(for path: [PathPoint], gridSize: Int, size: CGSize) -> Set<[Int]> {
        var coveredCells = Set<[Int]>()
        let cellWidth = size.width / CGFloat(gridSize)
        let cellHeight = size.height / CGFloat(gridSize)
        
        guard cellWidth > 0, cellHeight > 0 else { return coveredCells }

        if let firstPoint = path.first?.point {
            let col = Int(firstPoint.x / cellWidth)
            let row = Int(firstPoint.y / cellHeight)
            if col >= 0 && col < gridSize && row >= 0 && row < gridSize {
                coveredCells.insert([col, row])
            }
        }

        for i in 0 ..< path.count - 1 {
            let p1 = path[i].point
            let p2 = path[i+1].point

            if path[i+1].isStartOfNewStroke { continue }

            let dist = distance(from: p1, to: p2)
            let steps = Int(dist / (min(cellWidth, cellHeight) / 2)) + 1

            for step in 0...steps {
                let t = CGFloat(step) / CGFloat(steps)
                let interpolatedPoint = CGPoint(
                    x: p1.x + (p2.x - p1.x) * t,
                    y: p1.y + (p2.y - p1.y) * t
                )
                
                let col = Int(interpolatedPoint.x / cellWidth)
                let row = Int(interpolatedPoint.y / cellHeight)
                
                if col >= 0 && col < gridSize && row >= 0 && row < gridSize {
                    coveredCells.insert([col, row])
                }
            }
        }
        
        return coveredCells
    }
    
    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(pow(to.x - from.x, 2) + pow(to.y - from.y, 2))
    }
}

// MARK: - Completion View
struct CompletionView: View {
    let stars: Int
    let accuracy: Double
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("Level Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            HStack(spacing: 15) {
                ForEach(1...3, id: \.self) { index in
                    Image(systemName: index <= stars ? "star.fill" : "star")
                        .foregroundColor(index <= stars ? .yellow : .white.opacity(0.5))
                        .font(.system(size: 40))
                }
            }

            Text("Accuracy: \(accuracy, specifier: "%.1f")%")
                .font(.title2)
                .foregroundColor(.white)

            Button(action: onContinue) {
                Text("Continue")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.teal)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20)
            }
            .padding(.horizontal, 40)
            .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.85))
        .edgesIgnoringSafeArea(.all)
    }
}
