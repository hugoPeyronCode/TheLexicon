//
//  WordDatabase.swift
//  TheLexicon
//
//  Created by Hugo Peyron on 28/01/2026.
//

import Foundation

// MARK: - Word Database

@Observable
final class WordDatabase {

  // MARK: - Properties

  private var definitions: [String: WordDefinition] = [:] // keyed by lowercase word
  private var allWords: [WordDefinition] = []
  private var wordsByCategory: [String: [WordDefinition]] = [:]
  private var wordsByDifficulty: [Int: [WordDefinition]] = [:]
  private var isLoaded = false

  // MARK: - Initialization

  init() {
    loadDefinitions()
  }

  // MARK: - Public API

  /// Get definition for a specific word (case-insensitive)
  func definition(for word: String) -> WordDefinition? {
    definitions[word.lowercased()]
  }

  /// Check if a word has a definition
  func hasDefinition(for word: String) -> Bool {
    definitions[word.lowercased()] != nil
  }

  /// Get all definitions
  var all: [WordDefinition] {
    allWords
  }

  /// Get word of the day based on date
  func wordOfTheDay(for date: Date) -> WordDefinition? {
    guard !allWords.isEmpty else { return nil }

    let calendar = Calendar.current
    let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
    let index = (dayOfYear - 1) % allWords.count

    return allWords[index]
  }

  /// Get words for a specific category
  func words(for category: SemanticCategory) -> [WordDefinition] {
    wordsByCategory[category.rawValue] ?? []
  }

  /// Get words by difficulty level (1-10)
  func words(forDifficulty difficulty: Int) -> [WordDefinition] {
    wordsByDifficulty[difficulty] ?? []
  }

  /// Get harder words (difficulty 5+) for revision
  var harderWords: [WordDefinition] {
    allWords.filter { $0.difficulty >= 5 }
  }

  /// Search words by prefix
  func search(prefix: String) -> [WordDefinition] {
    let lowercased = prefix.lowercased()
    return allWords.filter { $0.word.lowercased().hasPrefix(lowercased) }
  }

  // MARK: - Loading

  private func loadDefinitions() {
    guard !isLoaded else { return }

    // Try loading from JSON file
    if let url = Bundle.main.url(forResource: "WordDefinitions", withExtension: "json"),
       let data = try? Data(contentsOf: url) {
      do {
        let decoder = JSONDecoder()
        let fileData = try decoder.decode(WordDefinitionsFile.self, from: data)
        processWords(fileData.words)
      } catch {
        print("Failed to decode WordDefinitions.json: \(error)")
        loadFallbackDefinitions()
      }
    } else {
      loadFallbackDefinitions()
    }

    isLoaded = true
  }

  private func processWords(_ words: [WordDefinition]) {
    allWords = words.sorted { $0.word < $1.word }

    for word in words {
      definitions[word.id] = word

      // Group by category
      if wordsByCategory[word.category] == nil {
        wordsByCategory[word.category] = []
      }
      wordsByCategory[word.category]?.append(word)

      // Group by difficulty
      if wordsByDifficulty[word.difficulty] == nil {
        wordsByDifficulty[word.difficulty] = []
      }
      wordsByDifficulty[word.difficulty]?.append(word)
    }
  }

  private func loadFallbackDefinitions() {
    processWords(FallbackDefinitions.words)
  }
}

// MARK: - Fallback Definitions

private enum FallbackDefinitions {
  static let words: [WordDefinition] = [
    // Technology (Difficulty 5-10)
    WordDefinition(word: "Algorithm", definition: "A step-by-step procedure for solving a problem or accomplishing a task", difficulty: 5, category: "Technology", example: "The search algorithm efficiently finds relevant results"),
    WordDefinition(word: "Encryption", definition: "The process of converting data into a coded format to prevent unauthorized access", difficulty: 6, category: "Technology", example: "End-to-end encryption protects your messages"),
    WordDefinition(word: "Blockchain", definition: "A decentralized digital ledger that records transactions across many computers", difficulty: 7, category: "Technology", example: "Bitcoin uses blockchain technology"),
    WordDefinition(word: "Quantum", definition: "Relating to the smallest discrete unit of a phenomenon, especially in physics", difficulty: 7, category: "Technology", example: "Quantum computing could revolutionize cryptography"),
    WordDefinition(word: "Middleware", definition: "Software that acts as a bridge between an operating system and applications", difficulty: 8, category: "Technology"),
    WordDefinition(word: "Heuristic", definition: "A practical problem-solving approach that may not be perfect but is sufficient", difficulty: 8, category: "Technology", example: "Heuristic algorithms find good-enough solutions quickly"),

    // Arts (Difficulty 5-10)
    WordDefinition(word: "Chiaroscuro", definition: "The use of strong contrasts between light and dark in art", difficulty: 8, category: "Arts", example: "Caravaggio was a master of chiaroscuro"),
    WordDefinition(word: "Staccato", definition: "Musical notes played in a short, detached manner", difficulty: 6, category: "Arts", example: "The pianist played the passage staccato"),
    WordDefinition(word: "Allegory", definition: "A story or image with a hidden meaning, usually moral or political", difficulty: 6, category: "Arts", example: "Animal Farm is an allegory for the Russian Revolution"),
    WordDefinition(word: "Motif", definition: "A recurring element that has symbolic significance in a work of art", difficulty: 5, category: "Arts", example: "The rose is a recurring motif in the novel"),
    WordDefinition(word: "Avant-garde", definition: "New and experimental ideas in art, music, or literature", difficulty: 7, category: "Arts", pronunciation: "ah-vahnt-GARD"),
    WordDefinition(word: "Pastiche", definition: "An artistic work that imitates the style of another artist or period", difficulty: 8, category: "Arts"),
    WordDefinition(word: "Timbre", definition: "The character or quality of a musical sound distinct from its pitch and intensity", difficulty: 7, category: "Arts", pronunciation: "TAM-ber"),

    // Nature (Difficulty 5-10)
    WordDefinition(word: "Biodiversity", definition: "The variety of plant and animal life in a particular habitat", difficulty: 5, category: "Nature", example: "Rainforests have incredible biodiversity"),
    WordDefinition(word: "Symbiosis", definition: "A close relationship between two different species that benefits at least one", difficulty: 6, category: "Nature", example: "Clownfish and sea anemones live in symbiosis"),
    WordDefinition(word: "Metamorphosis", definition: "A profound change in form, especially the transformation of a larva into an adult", difficulty: 6, category: "Nature", example: "Butterflies undergo metamorphosis"),
    WordDefinition(word: "Photosynthesis", definition: "The process by which plants convert light energy into chemical energy", difficulty: 5, category: "Nature"),
    WordDefinition(word: "Tectonic", definition: "Relating to the structure of the earth's crust and the movements within it", difficulty: 7, category: "Nature", example: "Tectonic plates shift over millions of years"),
    WordDefinition(word: "Bioluminescence", definition: "The production of light by living organisms", difficulty: 8, category: "Nature", example: "Deep-sea creatures often exhibit bioluminescence"),

    // History (Difficulty 5-10)
    WordDefinition(word: "Renaissance", definition: "The period of European cultural and artistic revival from the 14th to 17th century", difficulty: 5, category: "History", pronunciation: "REN-uh-sahns"),
    WordDefinition(word: "Feudalism", definition: "The medieval social system based on holding land in exchange for service", difficulty: 6, category: "History"),
    WordDefinition(word: "Imperialism", definition: "A policy of extending a country's power through colonization or military force", difficulty: 6, category: "History"),
    WordDefinition(word: "Hegemony", definition: "Leadership or dominance of one country or group over others", difficulty: 8, category: "History", pronunciation: "heh-JEM-uh-nee"),
    WordDefinition(word: "Oligarchy", definition: "A form of government where power is held by a small group of people", difficulty: 7, category: "History"),
    WordDefinition(word: "Autocracy", definition: "A system of government where one person has absolute power", difficulty: 6, category: "History"),

    // Science (Difficulty 5-10)
    WordDefinition(word: "Hypothesis", definition: "A proposed explanation made as a starting point for investigation", difficulty: 5, category: "Science", example: "The scientist tested her hypothesis through experiments"),
    WordDefinition(word: "Catalyst", definition: "A substance that speeds up a chemical reaction without being consumed", difficulty: 6, category: "Science", example: "Enzymes act as catalysts in biological reactions"),
    WordDefinition(word: "Entropy", definition: "A measure of disorder or randomness in a system", difficulty: 7, category: "Science", example: "The second law of thermodynamics involves entropy"),
    WordDefinition(word: "Paradigm", definition: "A typical example or model of something; a worldview underlying theories", difficulty: 7, category: "Science", pronunciation: "PAIR-uh-dime"),
    WordDefinition(word: "Osmosis", definition: "The movement of molecules through a membrane from less to more concentrated", difficulty: 6, category: "Science"),
    WordDefinition(word: "Nebula", definition: "A cloud of gas and dust in outer space, often where stars are born", difficulty: 6, category: "Science"),
    WordDefinition(word: "Quasar", definition: "An extremely luminous active galactic nucleus powered by a supermassive black hole", difficulty: 9, category: "Science"),

    // Emotions (Difficulty 5-10)
    WordDefinition(word: "Melancholy", definition: "A deep, persistent sadness or pensive mood", difficulty: 5, category: "Emotions", example: "The music evoked a sense of melancholy"),
    WordDefinition(word: "Euphoria", definition: "An intense feeling of happiness and excitement", difficulty: 5, category: "Emotions"),
    WordDefinition(word: "Ambivalent", definition: "Having mixed or contradictory feelings about something", difficulty: 6, category: "Emotions", example: "She felt ambivalent about the promotion"),
    WordDefinition(word: "Catharsis", definition: "The release of strong emotions through art or other experiences", difficulty: 7, category: "Emotions", pronunciation: "kuh-THAR-sis"),
    WordDefinition(word: "Ennui", definition: "A feeling of weariness and dissatisfaction arising from boredom", difficulty: 8, category: "Emotions", pronunciation: "on-WEE"),
    WordDefinition(word: "Schadenfreude", definition: "Pleasure derived from another person's misfortune", difficulty: 9, category: "Emotions", pronunciation: "SHAH-den-froy-duh"),
    WordDefinition(word: "Sanguine", definition: "Optimistic and cheerful, especially in difficult situations", difficulty: 7, category: "Emotions"),

    // Business (Difficulty 5-10)
    WordDefinition(word: "Leverage", definition: "The use of borrowed capital to increase potential returns", difficulty: 5, category: "Business", example: "The company used leverage to fund the acquisition"),
    WordDefinition(word: "Diversification", definition: "The strategy of spreading investments to reduce risk", difficulty: 6, category: "Business"),
    WordDefinition(word: "Arbitrage", definition: "Profiting from price differences in different markets", difficulty: 7, category: "Business"),
    WordDefinition(word: "Fiduciary", definition: "Involving trust, especially regarding financial assets of another", difficulty: 8, category: "Business", pronunciation: "fih-DOO-shee-air-ee"),
    WordDefinition(word: "Amortization", definition: "The gradual reduction of a debt through regular payments", difficulty: 7, category: "Business"),
    WordDefinition(word: "Liquidity", definition: "The ease with which an asset can be converted to cash", difficulty: 6, category: "Business"),

    // Culture (Difficulty 5-10)
    WordDefinition(word: "Zeitgeist", definition: "The defining spirit or mood of a particular period of history", difficulty: 8, category: "Culture", pronunciation: "ZITE-guyst"),
    WordDefinition(word: "Diaspora", definition: "The dispersion of people from their original homeland", difficulty: 7, category: "Culture"),
    WordDefinition(word: "Vernacular", definition: "The language or dialect spoken by ordinary people in a region", difficulty: 7, category: "Culture"),
    WordDefinition(word: "Etiquette", definition: "The customary code of polite behavior in society", difficulty: 5, category: "Culture"),
    WordDefinition(word: "Cuisine", definition: "A style or method of cooking characteristic of a particular region", difficulty: 5, category: "Culture", pronunciation: "kwih-ZEEN"),
    WordDefinition(word: "Patois", definition: "A regional dialect or language, especially one without written form", difficulty: 9, category: "Culture", pronunciation: "PAT-wah"),
    WordDefinition(word: "Cosmopolitan", definition: "Familiar with and at ease in many different countries and cultures", difficulty: 6, category: "Culture"),

    // Additional advanced words
    WordDefinition(word: "Ephemeral", definition: "Lasting for a very short time", difficulty: 7, category: "Arts", example: "The ephemeral beauty of cherry blossoms"),
    WordDefinition(word: "Ubiquitous", definition: "Present, appearing, or found everywhere", difficulty: 7, category: "Technology", example: "Smartphones have become ubiquitous"),
    WordDefinition(word: "Serendipity", definition: "The occurrence of events by chance in a happy way", difficulty: 6, category: "Emotions"),
    WordDefinition(word: "Pragmatic", definition: "Dealing with things sensibly and realistically", difficulty: 6, category: "Business"),
    WordDefinition(word: "Esoteric", definition: "Intended for or understood by only a small number of people", difficulty: 8, category: "Culture"),
    WordDefinition(word: "Paradox", definition: "A statement that contradicts itself but might contain truth", difficulty: 6, category: "Science"),
    WordDefinition(word: "Resilience", definition: "The capacity to recover quickly from difficulties", difficulty: 5, category: "Emotions"),
    WordDefinition(word: "Synergy", definition: "The interaction of elements that produces a combined effect greater than the sum", difficulty: 6, category: "Business"),
    WordDefinition(word: "Eloquent", definition: "Fluent and persuasive in speaking or writing", difficulty: 6, category: "Arts"),
    WordDefinition(word: "Nefarious", definition: "Wicked, villainous, or criminal", difficulty: 8, category: "History"),
    WordDefinition(word: "Perspicacious", definition: "Having a ready insight into and understanding of things", difficulty: 9, category: "Emotions"),
    WordDefinition(word: "Verisimilitude", definition: "The appearance of being true or real", difficulty: 10, category: "Arts"),
    WordDefinition(word: "Defenestration", definition: "The act of throwing someone out of a window", difficulty: 10, category: "History", example: "The Defenestration of Prague sparked the Thirty Years' War"),
    WordDefinition(word: "Sesquipedalian", definition: "Characterized by long words; long-winded", difficulty: 10, category: "Culture", pronunciation: "ses-kwi-puh-DALE-ee-un"),
  ]
}
