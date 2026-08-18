# 🎙️ Audio to Emoji – Assistive Communication App

An **AI-powered assistive communication application** designed for **Deaf and speech-impaired users**. The application converts **speech into text and meaningful emojis**, and also provides **Text-to-Speech** functionality to support easier two-way communication.

The system combines a **Flutter mobile application**, **FastAPI backend**, **Speech Recognition**, and **Machine Learning-based text classification**.

---

## 📌 Project Overview

Communication can be challenging for people with hearing or speech disabilities. This project provides a simple mobile-based communication interface where users can:

* 🎤 Convert live speech into text
* 🎧 Upload an audio file and convert it into text
* 😊 Convert text into meaningful emojis
* 🔊 Convert text/emojis into speech
* 🌐 Support English, Hindi, and Marathi
* 📜 View previous predictions through history

The application uses a Flutter frontend to interact with a Python FastAPI backend through REST APIs.

---

## 🎯 Objectives

* Provide an easy-to-use communication tool for Deaf and speech-impaired users.
* Convert spoken language into readable text.
* Convert text into meaningful emojis using Machine Learning.
* Provide voice output from text or emojis.
* Support multiple Indian languages.
* Build a complete mobile + AI + backend application.

---

## ✨ Key Features

### 1. 🎤 Live Speech-to-Text

Users can record their voice directly through the mobile microphone.

**Workflow:**

`Microphone → Audio Recording → FastAPI → Speech Recognition → Text → Emoji Prediction`

The application supports:

* English
* Hindi
* Marathi

The live recording uses WAV audio optimized for speech recognition.

---

### 2. 📁 Audio File Upload

Users can select an audio file from their device and upload it to the backend.

Supported formats include:

* WAV
* MP3
* WebM

The backend converts non-WAV audio into WAV before processing.

**Workflow:**

`Audio File → Upload → Audio Conversion → Speech Recognition → Text → Emoji`

---

### 3. 😊 Text-to-Emoji

Users can enter a sentence and receive a corresponding emoji prediction.

Example:

```text
Input:
I am going to sleep.

Output:
🛌
```

The ML pipeline performs:

```text
Text
 ↓
Text Normalization
 ↓
TF-IDF Feature Extraction
 ↓
SVM Classification
 ↓
Emoji Prediction
```

> If the project is still using Logistic Regression, replace **SVM** with **Logistic Regression** in this README.

---

### 4. 🔊 Text-to-Speech

The application converts text or emojis into spoken audio using **gTTS (Google Text-to-Speech)**.

Example:

```text
Input:
☕

Converted Text:
I want coffee.

Output:
Audio Speech
```

The application supports:

* English
* Hindi
* Marathi

---

### 5. 🌐 Multilingual Support

The application supports three languages:

| Language | Speech Recognition | Text-to-Speech |
| -------- | ------------------ | -------------- |
| English  | ✅                  | ✅              |
| Hindi    | ✅                  | ✅              |
| Marathi  | ✅                  | ✅              |

---

### 6. 📜 Prediction History

The backend stores previous text and emoji predictions.

The Flutter application provides a History screen where users can view previous predictions.

---

### 7. 🔐 API Security

The FastAPI backend uses **API-key authentication**.

Protected endpoints require an API key through the:

```text
api-key
```

HTTP header.

---

# 📱 Application Screenshots

## 📝 Text-to-Emoji

Users can enter text and get the corresponding emoji prediction.

![Text to Emoji](https://github.com/RutujaWarkhade/VoiceBridge/blob/main/Images/Text_To_Emoji.png?raw=true)

---

## 🎤 Live Speech-to-Text

Users can record speech using the microphone and convert it into text.

![Live Speech to Text](https://github.com/RutujaWarkhade/VoiceBridge/blob/main/Images/Live_Speech_to_Text.png?raw=true)

---

## 📁 Audio File Upload

Users can upload an audio file for speech recognition and emoji prediction.

![Audio File Upload](https://github.com/RutujaWarkhade/VoiceBridge/blob/main/Images/Audio_File_Upload.png?raw=true)

---

## 😊 Audio-to-Emoji

The recognized speech from an uploaded audio file is converted into a meaningful emoji.

![Audio to Emojis](https://github.com/RutujaWarkhade/VoiceBridge/blob/main/Images/Audio_to_Emojis.png?raw=true)

---

## 🔊 Text-to-Speech

Users can convert text or emojis into spoken audio.

![Text to Speech](https://github.com/RutujaWarkhade/VoiceBridge/blob/main/Images/Text_to_Speech.png?raw=true)

---

## 📜 Prediction History

Users can view their previous text and emoji predictions.

![Prediction History](https://github.com/RutujaWarkhade/VoiceBridge/blob/main/Images/Prediction_History.png?raw=true)

# 🏗️ System Architecture

```text
                    ┌──────────────────────┐
                    │   Flutter Mobile App │
                    │      Frontend        │
                    └──────────┬───────────┘
                               │
                         REST API / HTTP
                               │
                               ▼
                    ┌──────────────────────┐
                    │    FastAPI Backend   │
                    └──────────┬───────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
              ▼                ▼                ▼
       Speech Recognition   ML Model          gTTS
              │                │                │
              ▼                ▼                ▼
          Speech → Text     Text → Emoji    Text → Speech
              │                │                │
              └────────────────┼────────────────┘
                               ▼
                        Response to Flutter
```

---

# 🔄 Application Workflow

## Speech-to-Emoji

```text
User speaks
     ↓
Flutter records audio
     ↓
Audio sent to FastAPI
     ↓
Speech Recognition
     ↓
Recognized Text
     ↓
Text Normalization
     ↓
TF-IDF Vectorization
     ↓
SVM Classification
     ↓
Predicted Emoji
     ↓
Flutter displays Text + Emoji
```

## Text-to-Emoji

```text
User enters text
       ↓
FastAPI receives text
       ↓
Text Normalization
       ↓
TF-IDF Vectorization
       ↓
SVM Classification
       ↓
Emoji Prediction
       ↓
Result returned to Flutter
```

## Text-to-Speech

```text
User enters Text / Emoji
          ↓
Emoji converted to corresponding text
          ↓
gTTS
          ↓
MP3 Audio
          ↓
Flutter Audio Player
          ↓
Voice Output
```

---

# 🧠 Machine Learning

## Text Classification

The application uses Machine Learning to classify user statements into predefined emoji categories.

### 1. Text Normalization

Input text is normalized using Unicode normalization to handle multilingual text consistently.

```python
unicodedata.normalize("NFC", text)
```

### 2. TF-IDF

**TF-IDF (Term Frequency–Inverse Document Frequency)** converts text into numerical features that can be used by the ML classifier.

The project uses character-level n-grams:

```python
TfidfVectorizer(
    analyzer="char",
    ngram_range=(2, 5)
)
```

Character-level features are useful for handling variations in words and multilingual text.

### 3. SVM Classification

The extracted TF-IDF features are passed to an **SVM classifier** to predict the appropriate emoji category.

```text
Input Text
    ↓
TF-IDF
    ↓
SVM
    ↓
Emoji
```

---

# 🛠️ Tech Stack

## Frontend

* **Flutter** – Mobile application development
* **Dart** – Flutter programming language
* **HTTP package** – REST API communication
* **AudioPlayers** – Audio playback
* **Record** – Live microphone recording
* **File Picker** – Audio file selection
* **Permission Handler** – Microphone permissions

## Backend

* **Python** – Backend and ML development
* **FastAPI** – REST API development
* **Uvicorn** – FastAPI server
* **Pandas** – Dataset handling
* **Joblib** – ML model persistence
* **CORS Middleware** – Frontend-backend communication

## Machine Learning

* **Scikit-learn**
* **TF-IDF Vectorizer** – Text feature extraction
* **SVM** – Text classification

## Speech & Audio

* **SpeechRecognition** – Speech-to-text
* **pydub** – Audio format conversion
* **gTTS** – Text-to-speech

## Data & Storage

* **CSV** – Training dataset
* **JSON** – Speech/emoji history storage
* **Joblib** – Saved ML model and vectorizer

---

# 📂 Project Structure

```text
Audio-to-Emoji/
│
├── backend/
│   ├── main.py
│   ├── daily_routine_emojis_expanded.csv
│   ├── speech_map.json
│   │
│   ├── models/
│   │   ├── vectorizer.joblib
│   │   └── model.joblib
│   │
│   └── uploads/
│
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── api_service.dart
│   │   │
│   │   └── screens/
│   │       ├── home_screen.dart
│   │       ├── text_prediction_screen.dart
│   │       ├── audio_upload_screen.dart
│   │       ├── live_audio_screen.dart
│   │       ├── text_to_speech_screen.dart
│   │       └── history_screen.dart
│   │
│   └── pubspec.yaml
│
└── README.md
```

---

# 🔌 REST API Endpoints

## 1. Text Prediction

### Endpoint

```http
POST /predict_text
```

### Purpose

Converts text into an emoji.

### Input

```text
text = "I am going to sleep"
```

### Response

```json
{
    "text": "I am going to sleep",
    "emoji": "🛌"
}
```

---

## 2. Audio Upload

### Endpoint

```http
POST /upload_audio
```

### Purpose

Converts uploaded speech/audio into text and predicts an emoji.

### Input

```text
file = audio file
lang = en-US / hi-IN / mr-IN
```

### Response

```json
{
    "text": "I want coffee",
    "emoji": "☕"
}
```

---

## 3. Text-to-Speech

### Endpoint

```http
POST /tts
```

### Purpose

Converts text or emojis into spoken audio.

### Input

```text
text = "Hello! 👋"
lang = "en"
```

### Output

```text
MP3 audio file
```

---

## 4. History

### Endpoint

```http
GET /history
```

### Purpose

Returns recent prediction history.

### Example Response

```json
[
    {
        "text": "I want coffee",
        "emoji": "☕"
    },
    {
        "text": "I am going to sleep",
        "emoji": "🛌"
    }
]
```

---

# ⚙️ Installation

## 1. Clone the Repository

```bash
git clone https://github.com/your-username/Audio-to-Emoji.git
cd Audio-to-Emoji
```

---

## 2. Backend Setup

Create a Python virtual environment:

```bash
python -m venv venv
```

Activate it on Windows:

```bash
venv\Scripts\activate
```

Install dependencies:

```bash
pip install fastapi uvicorn pandas scikit-learn joblib googletrans==4.0.0-rc1 SpeechRecognition pydub gTTS python-multipart
```

---

## 3. Start FastAPI Backend

Run:

```bash
uvicorn main:app --reload
```

The backend will run at:

```text
http://localhost:8000
```

FastAPI documentation:

```text
http://localhost:8000/docs
```

---

# 📱 Flutter Setup

Navigate to the Flutter project:

```bash
cd flutter_app
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# 🔗 Connecting Flutter with FastAPI

The Flutter application communicates with the backend through:

```dart
static const String baseUrl = 'http://localhost:8000';
```

For a physical Android device, replace `localhost` with the IP address of the computer running FastAPI.

Example:

```dart
static const String baseUrl = 'http://192.168.1.100:8000';
```

Make sure the mobile device and computer are connected to the same network.

---

# 🔑 API Key Configuration

The FastAPI backend uses an API key for protected endpoints.

Backend:

```python
API_KEY = "your_api_key"
```

Flutter:

```dart
static const String apiKey = "your_api_key";
```

For production, API keys should be stored securely using environment variables or a secure configuration system rather than hard-coded in source code.

---

# 🧪 Example

### Speech Input

```text
"I'm going to sleep"
```

### Speech-to-Text

```text
I'm going to sleep
```

### ML Prediction

```text
🛌
```

### Final Result

```text
I'm going to sleep → 🛌
```

---

# 🎯 Use Cases

* Assistive communication for Deaf and speech-impaired users
* Quick communication using emojis
* Multilingual speech recognition
* Voice-based accessibility applications
* Educational accessibility tools
* Human-computer interaction applications

---

# 🚀 Future Improvements

* Add more Indian and international languages.
* Replace the traditional ML classifier with a **Transformer/BERT-based model** for improved semantic understanding.
* Add a larger and more diverse training dataset.
* Add emotion and intent detection.
* Improve offline speech recognition.
* Add cloud deployment for the FastAPI backend.
* Implement secure user authentication.
* Store user history in a database such as PostgreSQL or MongoDB.
* Add personalized emoji recommendations.

---

# 📊 Key Highlights

* ✅ Speech-to-Text
* ✅ Text-to-Emoji
* ✅ Audio-to-Emoji
* ✅ Text-to-Speech
* ✅ Live Microphone Recording
* ✅ Audio File Upload
* ✅ English, Hindi & Marathi Support
* ✅ Machine Learning Classification
* ✅ REST API Backend
* ✅ Flutter Mobile Application
* ✅ API-Key Authentication
* ✅ Prediction History

---

# 👩‍💻 Technologies Used

```text
Python
FastAPI
Scikit-learn
TF-IDF
SVM
Pandas
SpeechRecognition
pydub
gTTS
Joblib
Flutter
Dart
REST API
JSON
CSV
```

---

# 📌 Conclusion

**Audio to Emoji** is an end-to-end AI-based accessibility application that combines **Speech Recognition, Machine Learning, Text-to-Speech, FastAPI, and Flutter** to provide an easier communication interface for Deaf and speech-impaired users.

The project demonstrates the integration of **Machine Learning with a real-world mobile application**, from speech input and text processing to emoji prediction and voice output.
