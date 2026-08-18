from fastapi import FastAPI, Depends, HTTPException, Header, UploadFile, File, Form, status
from fastapi.responses import JSONResponse, FileResponse
from fastapi.middleware.cors import CORSMiddleware

import os
import unicodedata
import json
import tempfile

import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression

from googletrans import Translator
import speech_recognition as sr
from pydub import AudioSegment
import joblib
from gtts import gTTS

# -------------------------------------------------
# CONFIGURATION
# -------------------------------------------------
DATA_FILE = "daily_routine_emojis_expanded.csv"
DICT_FILE = "speech_map.json"
UPLOAD_FOLDER = "uploads"
MODELS_DIR = "models"

VECTORIZER_FILE = os.path.join(MODELS_DIR, "vectorizer.joblib")
MODEL_FILE = os.path.join(MODELS_DIR, "model.joblib")

ALLOWED_EXTENSIONS = {"wav", "mp3", "webm"}

API_KEY = "supersecret123"
API_KEY_NAME = "api-key"

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(MODELS_DIR, exist_ok=True)

# -------------------------------------------------
# FASTAPI INIT
# -------------------------------------------------
app = FastAPI(title="Audio / Text / Emoji / TTS API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------------------------------------
# API KEY SECURITY
# -------------------------------------------------
def get_api_key(api_key: str = Header(..., alias=API_KEY_NAME)):
    if api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    return api_key

# -------------------------------------------------
# ML UTILITIES
# -------------------------------------------------
def normalize_text(text):
    return unicodedata.normalize("NFC", str(text).strip())

if not os.path.exists(DATA_FILE):
    raise FileNotFoundError(f"{DATA_FILE} not found")

df = pd.read_csv(DATA_FILE)
translator = Translator()

def train_and_persist():
    statements = (
        df["English"].astype(str).apply(normalize_text).tolist()
        + df["Hindi"].astype(str).apply(normalize_text).tolist()
        + df["Marathi"].astype(str).apply(normalize_text).tolist()
    )
    labels = df["Emoji"].astype(str).tolist() * 3

    vectorizer = TfidfVectorizer(analyzer="char", ngram_range=(2, 5))
    X = vectorizer.fit_transform(statements)

    model = LogisticRegression(max_iter=2000)
    model.fit(X, labels)

    joblib.dump(vectorizer, VECTORIZER_FILE)
    joblib.dump(model, MODEL_FILE)

    return vectorizer, model

if os.path.exists(VECTORIZER_FILE) and os.path.exists(MODEL_FILE):
    vectorizer = joblib.load(VECTORIZER_FILE)
    model = joblib.load(MODEL_FILE)
else:
    vectorizer, model = train_and_persist()

# -------------------------------------------------
# HISTORY STORAGE
# -------------------------------------------------
if os.path.exists(DICT_FILE):
    with open(DICT_FILE, "r", encoding="utf-8") as f:
        speech_dict = json.load(f)
else:
    speech_dict = {}

def save_dict():
    with open(DICT_FILE, "w", encoding="utf-8") as f:
        json.dump(speech_dict, f, ensure_ascii=False, indent=4)

# -------------------------------------------------
# EMOJI → TEXT DICTIONARY (INDIAN)
# -------------------------------------------------
emoji_dicts = {
    "en": {
        "👋": "Hello! How are you?",
        "☕": "I want coffee.",
        "🛌": "I'm going to sleep.",
        "🙏": "Thank you very much!"
    },
    "hi": {
        "👋": "नमस्ते! कैसे हो?",
        "☕": "मुझे कॉफी चाहिए।",
        "🛌": "मैं सोने जा रहा हूँ।",
        "🙏": "बहुत बहुत धन्यवाद!"
    },
    "mr": {
        "👋": "नमस्कार! कसा आहेस?",
        "☕": "मला कॉफी हवी आहे.",
        "🛌": "मी झोपायला जात आहे.",
        "🙏": "खूप खूप धन्यवाद!"
    }
}

def emoji_to_text(text: str, lang: str):
    mapping = emoji_dicts.get(lang, {})
    for emoji, sentence in mapping.items():
        text = text.replace(emoji, sentence + " ")
    return text.strip()

# -------------------------------------------------
# PREDICTION
# -------------------------------------------------
def predict_routine(statement: str):
    statement = normalize_text(statement)
    try:
        X = vectorizer.transform([statement])
        return model.predict(X)[0]
    except:
        translated = translator.translate(statement, src="auto", dest="en").text
        X = vectorizer.transform([translated])
        return model.predict(X)[0]

def allowed_file(filename):
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS

# -------------------------------------------------
# API ENDPOINTS
# -------------------------------------------------
@app.post("/predict_text")
def predict_text(text: str = Form(...), api_key: str = Depends(get_api_key)):
    if not text.strip():
        raise HTTPException(status_code=400, detail="Empty text")

    emoji = predict_routine(text)
    speech_dict[text] = emoji
    save_dict()

    return {"text": text, "emoji": emoji}

# -------------------------------------------------
@app.post("/upload_audio")
async def upload_audio(
    file: UploadFile = File(...),
    lang: str = Form("en-US"),
    api_key: str = Depends(get_api_key)
):
    if not allowed_file(file.filename):
        raise HTTPException(status_code=400, detail="Invalid file type")

    filepath = os.path.join(UPLOAD_FOLDER, file.filename)

    with open(filepath, "wb") as f:
        f.write(await file.read())

    if not filepath.endswith(".wav"):
        wav_path = filepath.rsplit(".", 1)[0] + ".wav"
        AudioSegment.from_file(filepath).export(wav_path, format="wav")
        os.remove(filepath)
        filepath = wav_path

    r = sr.Recognizer()
    try:
        with sr.AudioFile(filepath) as source:
            audio = r.record(source)

        text = r.recognize_google(audio, language=lang)
        text = normalize_text(text)

        emoji = predict_routine(text)
        speech_dict[text] = emoji
        save_dict()

        return {"text": text, "emoji": emoji}

    finally:
        try:
            os.remove(filepath)
        except:
            pass

# -------------------------------------------------
@app.post("/tts")
def tts_api(
    text: str = Form(...),
    lang: str = Form("en"),
    api_key: str = Depends(get_api_key)
):
    if not text.strip():
        raise HTTPException(status_code=400, detail="Empty text")

    final_text = emoji_to_text(text, lang)

    tts = gTTS(text=final_text, lang=lang, tld="co.in")
    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".mp3")
    tts.save(tmp.name)

    return FileResponse(tmp.name, media_type="audio/mpeg", filename="speech.mp3")

# -------------------------------------------------
@app.get("/history")
def history(api_key: str = Depends(get_api_key)):
    return [{"text": k, "emoji": v} for k, v in list(speech_dict.items())[-30:]]

# -------------------------------------------------
@app.get("/")
def root():
    return {"message": "Audio + Emoji + TTS API is running 🚀"}
