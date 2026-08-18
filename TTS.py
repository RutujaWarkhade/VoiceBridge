from gtts import gTTS
import os
import sys
import tempfile
import re
import platform
import subprocess

try:
    from playsound import playsound
    PLAYSOUND_AVAILABLE = True
except ImportError:
    PLAYSOUND_AVAILABLE = False

# --- Emoji Dictionaries ---
emoji_dicts = {
    "English (Indian)": {
        "👋": "Hello! How are you?",
        "🤗": "Nice to meet you.",
        "🙂": "I'm fine, how are you?",
        "🙋": "Yes, I'm here.",
        "🙌": "Great! Let's start.",
        "❓": "Could you please tell me?",
        "✔️": "Yes, I agree.",
        "❌": "No, that's not possible.",
        "🤔": "I'm still thinking.",
        "👌": "Okay, I accept.",
        "☕": "I want coffee.",
        "🍽️": "Let's go for a meal.",
        "🚶": "I'm going for a walk.",
        "🚌": "I'm traveling by bus.",
        "🚗": "I'm going by car.",
        "🏠": "I'm back home.",
        "🍔": "I'm hungry.",
        "💧": "I'm thirsty.",
        "🛁": "I'm going to take a bath.",
        "🛌": "I'm going to sleep.",
        "😀": "I'm very happy.",
        "😢": "I'm a bit sad.",
        "😡": "I'm angry.",
        "😴": "I'm tired and sleepy.",
        "😍": "I really liked it.",
        "😂": "I'm laughing a lot.",
        "📞": "Can you call me?",
        "💬": "Let's talk.",
        "📧": "I have sent you an email.",
        "📅": "When can we meet?",
        "💻": "I'm working right now.",
        "📚": "I'm busy studying.",
        "🙏": "Thank you very much!",
        "🎉": "Best wishes to you!",
        "👏": "Well done!",
        "🌸": "Have a nice day.",
        "🌙": "Good night, sleep well.",
        "☀️": "Good morning! Have a nice day."
    },
    "Hindi (Indian)": {
        "👋": "नमस्ते! कैसे हो?",
        "🤗": "आपसे मिलकर खुशी हुई।",
        "🙂": "मैं ठीक हूँ, आप कैसे हैं।",
        "🙋": "हाँ, मैं यहाँ हूँ।",
        "🙌": "बहुत अच्छा! चलिए शुरू करें।",
        "❓": "क्या आप मुझे बता सकते हैं?",
        "✔️": "हाँ, मैं सहमत हूँ।",
        "❌": "नहीं, यह संभव नहीं है।",
        "🤔": "मैं अभी सोच रहा हूँ।",
        "👌": "ठीक है, मुझे मंजूर है।",
        "☕": "मुझे कॉफी चाहिए।",
        "🍽️": "चलिए खाना खाते हैं।",
        "🚶": "मैं टहलने जा रहा हूँ।",
        "🚌": "मैं बस से यात्रा कर रहा हूँ।",
        "🚗": "मैं कार से जा रहा हूँ।",
        "🏠": "मैं घर वापस आ गया हूँ।",
        "🍔": "मुझे भूख लगी है।",
        "💧": "मुझे प्यास लगी है।",
        "🛁": "मैं नहाने जा रहा हूँ।",
        "🛌": "मैं सोने जा रहा हूँ।",
        "😀": "मैं बहुत खुश हूँ।",
        "😢": "मैं थोड़ा दुखी हूँ।",
        "😡": "मुझे गुस्सा आ रहा है।",
        "😴": "मैं थक गया हूँ और सो रहा हूँ।",
        "😍": "मुझे यह बहुत पसंद आया।",
        "😂": "मैं बहुत हँस रहा हूँ।",
        "📞": "क्या आप मुझे कॉल कर सकते हैं?",
        "💬": "चलिए बात करते हैं।",
        "📧": "मैंने आपको ईमेल भेजा है।",
        "📅": "हम कब मिल सकते हैं?",
        "💻": "मैं अभी काम कर रहा हूँ।",
        "📚": "मैं पढ़ाई में व्यस्त हूँ।",
        "🙏": "बहुत बहुत धन्यवाद!",
        "🎉": "आपको ढेर सारी शुभकामनाएँ!",
        "👏": "बहुत अच्छा किया!",
        "🌸": "आपका दिन शुभ हो।",
        "🌙": "शुभ रात्रि, अच्छी नींद लें।",
        "☀️": "सुप्रभात! आपका दिन शुभ हो।"
    },
    "Marathi (Indian)": {
        "👋": "नमस्कार! कसा आहेस?",
        "🤗": "तुला भेटून मला आनंद झाला.",
        "🙂": "मी ठीक आहे, तू कसा आहेस?",
        "🙋": "हो, मी इथे आहे.",
        "🙌": "छान! चला सुरुवात करूया.",
        "❓": "कृपया मला सांगशील का?",
        "✔️": "होय, मी सहमत आहे.",
        "❌": "नाही, हे शक्य नाही.",
        "🤔": "मी अजून विचार करत आहे.",
        "👌": "ठीक आहे, मला मान्य आहे.",
        "☕": "मला कॉफी हवी आहे.",
        "🍽️": "चला, आपण जेवायला जाऊया.",
        "🚶": "मी चालायला जात आहे.",
        "🚌": "मी बसने प्रवास करत आहे.",
        "🚗": "मी गाडीने जात आहे.",
        "🏠": "मी घरी परतलो आहे.",
        "🍔": "मला भूक लागली आहे.",
        "💧": "मला तहान लागली आहे.",
        "🛁": "मी आंघोळ करणार आहे.",
        "🛌": "मी झोपायला जात आहे.",
        "😀": "मला खूप आनंद झाला आहे.",
        "😢": "मी थोडा दुःखी आहे.",
        "😡": "मला राग आला आहे.",
        "😴": "मी थकून झोपलो आहे.",
        "😍": "मला हे खूप आवडलं आहे.",
        "😂": "मी खूप हसत आहे.",
        "📞": "तू मला फोन करू शकतोस का?",
        "💬": "चला आपण बोलूया.",
        "📧": "मी तुला मेल पाठवला आहे.",
        "📅": "आपण कधी भेटू शकतो?",
        "💻": "मी सध्या काम करत आहे.",
        "📚": "मी अभ्यासात व्यस्त आहे.",
        "🙏": "खूप खूप धन्यवाद!",
        "🎉": "तुला हार्दिक शुभेच्छा!",
        "👏": "खूप छान केलेस!",
        "🌸": "तुझा दिवस आनंदी जावो.",
        "🌙": "शुभ रात्री, छान झोप घे.",
        "☀️": "शुभ सकाळ! छान दिवस जावो."
    }
}

# --- Helper Functions ---
def text_to_speech(text, lang='en', slow=False, outfile=None, tld='com'):
    tts = gTTS(text=text, lang=lang, slow=slow, tld=tld)
    if not outfile:
        fd, outfile = tempfile.mkstemp(suffix='.mp3')
        os.close(fd)
    tts.save(outfile)
    return outfile

def play_audio(mp3_file):
    """Cross-platform audio playback."""
    try:
        if PLAYSOUND_AVAILABLE:
            playsound(mp3_file)
        else:
            system = platform.system()
            if system == "Windows":
                subprocess.run(['start', '', mp3_file], shell=True)
            elif system == "Darwin":
                subprocess.run(['afplay', mp3_file])
            else:  # Linux
                try:
                    subprocess.run(['mpg123', mp3_file])
                except FileNotFoundError:
                    try:
                        subprocess.run(['aplay', mp3_file])
                    except FileNotFoundError:
                        print(f"Cannot play audio automatically. Open manually: {mp3_file}")
                        return
    except Exception as e:
        print(f"[Error] Could not play audio: {e}")

def convert_and_play(text, lang, tld):
    if not text.strip():
        print("Please enter some text.")
        return
    print("Generating speech...")
    mp3_file = text_to_speech(text, lang=lang, tld=tld)
    print(f"Audio saved at: {mp3_file}")
    print("Playing audio...")
    play_audio(mp3_file)
    # Remove temp file after playback
    try:
        os.remove(mp3_file)
    except:
        pass
    print("Done!")

# --- Main CLI ---
def main():
    print("=== Text-to-Speech (Indian Accent) ===\n")
    print("Select language:")
    print("1. English (Indian)")
    print("2. Hindi (Indian)")
    print("3. Marathi (Indian)")
    lang_choice = input("Enter choice (1-3): ").strip()
    
    lang_map = {
        "1": ('en', 'co.in', "English (Indian)"),
        "2": ('hi', 'co.in', "Hindi (Indian)"),
        "3": ('mr', 'co.in', "Marathi (Indian)")
    }
    lang, tld, lang_name = lang_map.get(lang_choice, ('en', 'co.in', "English (Indian)"))
    
    print("\nYou can use the following emojis for quick insert:")
    print(", ".join(emoji_dicts[lang_name].keys()))
    
    user_text = input("\nEnter your text (or emoji): ").strip()
    # Replace emojis with mapped text
    for emoji, mapped_text in emoji_dicts[lang_name].items():
        user_text = user_text.replace(emoji, mapped_text + " ")
    
    convert_and_play(user_text, lang, tld)

if __name__ == "__main__":
    main()
