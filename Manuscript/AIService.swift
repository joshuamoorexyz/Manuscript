import Foundation
import Combine
import Observation

#if canImport(FoundationModels)
import FoundationModels
#endif

enum AIServiceError: LocalizedError {
    case notAvailable
    case generationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Apple Intelligence is not available on this device"
        case .generationFailed(let message):
            return "Generation failed: \(message)"
        }
    }
}

class AIService: ObservableObject {
    @Published var isAvailable = false
    @Published var isGenerating = false
    @Published var generatedText = ""
    @Published var errorMessage: String?
    
    init() {
        checkAvailability()
    }
    
    private func checkAvailability() {
        if #available(macOS 26.0, *) {
            Task {
                await checkModelAvailability()
            }
        }
    }
    
    @available(macOS 26.0, *)
    private func checkModelAvailability() async {
        #if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        await MainActor.run {
            isAvailable = model.isAvailable
        }
        #endif
    }
    
    func proofread(text: String) async throws -> String {
        guard isAvailable else { throw AIServiceError.notAvailable }
        
        await MainActor.run { isGenerating = true }
        
        let prompt = """
        Proofread the following text for grammar, spelling, and clarity. 
        Return only the corrected text without explanations:
        
        \(text)
        """
        
        do {
            let result = try await generateText(prompt: prompt)
            await MainActor.run {
                isGenerating = false
                generatedText = result
            }
            return result
        } catch {
            await MainActor.run {
                isGenerating = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func rewrite(text: String, style: String = "concise") async throws -> String {
        guard isAvailable else { throw AIServiceError.notAvailable }
        
        await MainActor.run { isGenerating = true }
        
        let prompt = """
        Rewrite the following text in a \(style) style. 
        Return only the rewritten text without explanations:
        
        \(text)
        """
        
        do {
            let result = try await generateText(prompt: prompt)
            await MainActor.run {
                isGenerating = false
                generatedText = result
            }
            return result
        } catch {
            await MainActor.run {
                isGenerating = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func summarize(text: String) async throws -> String {
        guard isAvailable else { throw AIServiceError.notAvailable }
        
        await MainActor.run { isGenerating = true }
        
        let prompt = """
        Summarize the following text in 2-3 sentences:
        
        \(text)
        """
        
        do {
            let result = try await generateText(prompt: prompt)
            await MainActor.run {
                isGenerating = false
                generatedText = result
            }
            return result
        } catch {
            await MainActor.run {
                isGenerating = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func generateChapter(prompt: String, existingContent: String = "") async throws -> String {
        guard isAvailable else { throw AIServiceError.notAvailable }
        
        await MainActor.run { isGenerating = true }
        
        let fullPrompt = """
        Write a chapter based on this prompt: \(prompt)
        \(existingContent.isEmpty ? "" : "Existing content for context: \(existingContent)")
        Return only the chapter text.
        """
        
        do {
            let result = try await generateText(prompt: fullPrompt)
            await MainActor.run {
                isGenerating = false
                generatedText = result
            }
            return result
        } catch {
            await MainActor.run {
                isGenerating = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func analyzeText(_ text: String) async throws -> TextAnalysis {
        guard isAvailable else { throw AIServiceError.notAvailable }
        
        await MainActor.run { isGenerating = true }
        
        let prompt = """
        Analyze the following text for:
        1. Tension level (1-10)
        2. Pacing (slow/moderate/fast)
        3. Strongest hook
        
        Text: \(text)
        
        Return JSON: {"tension": 0, "pacing": "", "hook": ""}
        """
        
        do {
            let result = try await generateText(prompt: prompt)
            await MainActor.run { isGenerating = false }
            return TextAnalysis(tension: 5, pacing: "moderate", hook: "Analysis pending")
        } catch {
            await MainActor.run {
                isGenerating = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    @available(macOS 15.0, *)
    func generateText(prompt: String) async throws -> String {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, *) {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            return response.content
        }
        #endif
        throw AIServiceError.notAvailable
    }
    
    func continueWriting(text: String) async throws -> String {
        guard isAvailable else { throw AIServiceError.notAvailable }
        
        await MainActor.run { isGenerating = true }
        
        let prompt = """
        Continue the following text in the same style and tone. 
        Return only the continuation without explanations:
        
        \(text)
        """
        
        do {
            let result = try await generateText(prompt: prompt)
            await MainActor.run {
                isGenerating = false
                generatedText = result
            }
            return result
        } catch {
            await MainActor.run {
                isGenerating = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func expandText(text: String) async throws -> String {
        guard isAvailable else { throw AIServiceError.notAvailable }
        
        await MainActor.run { isGenerating = true }
        
        let prompt = """
        Expand the following text with more detail and description. 
        Return only the expanded text without explanations:
        
        \(text)
        """
        
        do {
            let result = try await generateText(prompt: prompt)
            await MainActor.run {
                isGenerating = false
                generatedText = result
            }
            return result
        } catch {
            await MainActor.run {
                isGenerating = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func changeTone(text: String, tone: String) async throws -> String {
        guard isAvailable else { throw AIServiceError.notAvailable }
        
        await MainActor.run { isGenerating = true }
        
        let prompt = """
        Rewrite the following text in a \(tone) tone. 
        Return only the rewritten text without explanations:
        
        \(text)
        """
        
        do {
            let result = try await generateText(prompt: prompt)
            await MainActor.run {
                isGenerating = false
                generatedText = result
            }
            return result
        } catch {
            await MainActor.run {
                isGenerating = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func generateOutline(content: String) async throws -> String {
        guard isAvailable else { throw AIServiceError.notAvailable }
        
        await MainActor.run { isGenerating = true }
        
        let prompt = """
        Create a detailed outline for the following content. 
        Use markdown headings (## for main sections, ### for subsections).
        Return only the outline:
        
        \(content.prefix(2000))
        """
        
        do {
            let result = try await generateText(prompt: prompt)
            await MainActor.run {
                isGenerating = false
                generatedText = result
            }
            return result
        } catch {
            await MainActor.run {
                isGenerating = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func developCharacter(name: String, context: String) async throws -> String {
        guard isAvailable else { throw AIServiceError.notAvailable }
        
        await MainActor.run { isGenerating = true }
        
        let prompt = """
        Develop a character profile for \(name).
        Include: appearance, personality, background, motivations, and arc.
        Context: \(context)
        
        Return a detailed character profile:
        """
        
        do {
            let result = try await generateText(prompt: prompt)
            await MainActor.run {
                isGenerating = false
                generatedText = result
            }
            return result
        } catch {
            await MainActor.run {
                isGenerating = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func analyzePlot(content: String) async throws -> String {
        guard isAvailable else { throw AIServiceError.notAvailable }
        
        await MainActor.run { isGenerating = true }
        
        let prompt = """
        Analyze the plot structure of the following content.
        Identify: exposition, inciting incident, rising action, climax, falling action, resolution.
        
        Content: \(content.prefix(2000))
        
        Return a plot analysis:
        """
        
        do {
            let result = try await generateText(prompt: prompt)
            await MainActor.run {
                isGenerating = false
                generatedText = result
            }
            return result
        } catch {
            await MainActor.run {
                isGenerating = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func smartPaste(text: String, context: String) async throws -> String {
        guard isAvailable else { throw AIServiceError.notAvailable }
        
        await MainActor.run { isGenerating = true }
        
        let prompt = """
        Improve the following pasted text to better fit with the existing context.
        Make it flow naturally with the surrounding content.
        
        Existing context: \(context.prefix(500))
        
        Pasted text to improve: \(text)
        
        Return only the improved text:
        """
        
        do {
            let result = try await generateText(prompt: prompt)
            await MainActor.run {
                isGenerating = false
                generatedText = result
            }
            return result
        } catch {
            await MainActor.run {
                isGenerating = false
                errorMessage = error.localizedDescription
            }
            throw error
        }
    }
}

struct TextAnalysis {
    let tension: Int
    let pacing: String
    let hook: String
}
