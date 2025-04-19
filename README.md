# AI Assistant App

A SwiftUI‑based chat application that processes text and voice commands (“send email”, “set alarm for 10pm”, “remind me to…”, “play music”, “tell me a joke”, etc.) using an MVVM architecture. It integrates:

- **SpeechService** for voice‑to‑text and text‑to‑speech  
- **CommandExecutor** for interpreting natural‑language commands via keyword matching  
- **AlarmManager** for scheduling “alarms” as local notifications  
- **EventKit** for creating Reminders and Calendar events  
- **SwiftUI** for a modern, responsive UI  

---

## Features

- Send and receive chat messages in a conversational UI  
- Text‑to‑speech synthesis of assistant replies  
- Voice command input via Apple’s Speech framework  
- Set reminders in the user’s Reminders app  
- Schedule calendar events as tasks  
- Schedule local notification “alarms” with flexible time formats (e.g. “10pm”, “07:30 AM”)  
- Open mail drafts (`mailto:`), SMS drafts (`sms:`), and music playlists based on mood  
- Return simple weather updates etc.

---
