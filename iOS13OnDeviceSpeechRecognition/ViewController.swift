 
 //alex ..
import UIKit
import Speech

class ViewController: UIViewController {

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionTask: SFSpeechRecognitionTask?
    
    
     let transcribedText:UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.textColor = .white
        view.font = UIFont.systemFont(ofSize: 15)
        view.backgroundColor = .gray
        return view
    }()
    
    let button:UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "mic.slash.fill")
        
        return view
    }()
    
    var micOn : Bool = false{
        didSet{
            if micOn{
                button.image = UIImage(systemName: "mic.fill")
                        do{
                            self.transcribedText.text = ""
                            try self.startRecording()
                        }catch(let error){
                            print("error is \(error.localizedDescription)")
                        }
            }
            else{
                if audioEngine.isRunning {
                    recognitionRequest?.endAudio()
                    audioEngine.stop()
                }
                button.image = UIImage(systemName: "mic.slash.fill")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        buildUI()
        getPermissions()
        guard SFSpeechRecognizer.authorizationStatus() == .authorized
        else {
            print("guard failed...")
            return
        }
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        tappedImage.image = UIImage(systemName: "mic.fill")
        micOn = !micOn
    }
    
    func buildUI()
    {
        self.view.addSubview(button)
        self.view.addSubview(transcribedText)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        button.isUserInteractionEnabled = true
        button.addGestureRecognizer(tapGestureRecognizer)
        
        
        NSLayoutConstraint.activate(
            [
             button.heightAnchor.constraint(equalToConstant: 150),
             button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                button.widthAnchor.constraint(equalToConstant: 150)
            ]
        )
        

        NSLayoutConstraint.activate(
            [transcribedText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
             transcribedText.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             transcribedText.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             transcribedText.heightAnchor.constraint(equalToConstant: 200),
             transcribedText.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
    }
    
    func startRecording() throws {

        recognitionTask?.cancel()
        self.recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        
                recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
                recognitionRequest.shouldReportPartialResults = true
      //  recognitionRequest.interactionIdentifier=""
                 recognitionRequest.contextualStrings = [
                          "hello Zap"
                          ,"hello zap"
                         ,"play video"
                         ,"stop video"
                         ,"next video"
                         ,"like video"
                         ,"open video"
                         ,"search contact"
                    ,"send new message"
                    ,"new voice message"
                    ,"back to chat list"
        ];
        
//         play video | stop video | next video | like video | open chats | search contact | send new message | new voice message | open videos | back to chat list
//        //        if #available(iOS 13, *) {
        //            if speechRecognizer?.supportsOnDeviceRecognition ?? false{
        //                recognitionRequest.requiresOnDeviceRecognition = true
        //            }
        //        }

        
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
 

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            print(result?.bestTranscription.formattedString)
              var isFinal = false
            
            if let result = result {
                DispatchQueue.main.async {
                        let transcribedString = result.bestTranscription.formattedString
                        self.transcribedText.text = (transcribedString)
                }
                
                isFinal = (result.isFinal)
                 
            }
            
            if error != nil || isFinal{
                       //  print("Error: \(error)")
                        // print("ifFinal: \(isFinal)")

                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                      try! self.startRecording()
//                      self.recordButton.isEnabled = true
//                      self.recordButton.setTitle("Start Recording", for: [])
                
                
            }
        }
        
                audioEngine.prepare()
               try audioEngine.start()
    }
    
    func getPermissions(){
        SFSpeechRecognizer.requestAuthorization{authStatus in
            OperationQueue.main.addOperation {
               switch authStatus {
                    case .authorized:
                        print("authorised..")
                    default:
                        print("none")
               }
            }
        }
    }
}

