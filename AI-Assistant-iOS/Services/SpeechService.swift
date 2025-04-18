import Foundation
import Speech
import AVFoundation

class SpeechService: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var transcribedText: String = ""
    @Published var isRecording: Bool = false
    
    override init() {
        super.init()
        speechRecognizer?.delegate = self
        requestAuthorization()
    }
    
    /// Requests speech recognition permission.
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("Speech recognition denied")
                case .restricted:
                    print("Speech recognition restricted")
                case .notDetermined:
                    print("Speech recognition not determined")
                @unknown default:
                    print("Unknown status")
                }
            }
        }
    }
    
    /// Starts capturing audio from the microphone.
    func startRecording() throws {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                DispatchQueue.main.async {
                    self.isRecording = false
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        DispatchQueue.main.async {
            self.transcribedText = ""
            self.isRecording = true
        }
    }
    
    /// Stops the ongoing speech recognition.
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
    
    /// Speaks the provided text using text-to-speech.
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
