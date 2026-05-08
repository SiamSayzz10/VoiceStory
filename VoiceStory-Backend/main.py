import os
import sqlite3
import uuid
import json
import asyncio
import edge_tts  # Used for generating high-quality, neural text-to-speech audio
from datetime import datetime
from fastapi import FastAPI, UploadFile, File, HTTPException, Form
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydub import AudioSegment
from deep_translator import GoogleTranslator
from faster_whisper import WhisperModel

# ==========================================
# 1. SQLITE DATABASE CONFIGURATION
# ==========================================
# This section sets up the local database to store user accounts and translation history.
# SQLite is used because it is lightweight, serverless, and perfect for mobile app backends.

DB_FILE = "database.db"

def get_db_connection():
    """
    Establishes a connection to the SQLite database.
    - timeout=10: Prevents database lock errors if multiple requests hit simultaneously.
    - row_factory = sqlite3.Row: Ensures database queries return dictionary-like objects
      (e.g., user['username']) instead of numerical tuples (e.g., user[0]), improving readability.
    """
    conn = sqlite3.connect(DB_FILE, timeout=10)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    """
    Initializes the database schema when the server starts.
    It creates the necessary tables only if they do not already exist, ensuring data isn't wiped on restart.
    """
    try:
        conn = get_db_connection()
        # WAL (Write-Ahead Logging) improves concurrency, allowing faster reads and writes.
        conn.execute("PRAGMA journal_mode=WAL;")

        # 'users' table: Stores authentication and profile data.
        # Username is set to UNIQUE to prevent duplicate accounts.
        conn.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                password TEXT NOT NULL,
                name TEXT DEFAULT '',
                gender TEXT DEFAULT '',
                photo_path TEXT DEFAULT ''
            )
        """)

        # 'records' table: Stores the history of all app interactions.
        # 'type' is crucial for the Flutter UI to differentiate between Text-to-Speech ('tts')
        # and Speech-to-Text ('stt') records when displaying the history list.
        conn.execute("""
            CREATE TABLE IF NOT EXISTS records (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT,
                original_text TEXT,
                audio_path TEXT,
                created_at DATETIME,
                type TEXT DEFAULT 'stt' 
            )
        """)
        conn.commit()
        conn.close()
        print(f"✅ SQLite Database ready: {DB_FILE}")
    except Exception as db_err:
        print(f"❌ Database Init Error: {db_err}")

init_db()

# ==========================================
# 2. FASTAPI APP SETUP & INITIALIZATION
# ==========================================
# This section initializes the web server, configures security headers,
# prepares local directories for file storage, and loads the heavy AI models into memory.

app = FastAPI()

# CORS (Cross-Origin Resource Sharing) configuration.
# This middleware allows the Flutter app (which acts as a different "origin")
# to make API requests to this Python server without being blocked by browser security protocols.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allow requests from any device/IP
    allow_methods=["*"], # Allow GET, POST, PUT, DELETE
    allow_headers=["*"], # Allow all headers
)

# Ensure the physical folders exist on the server's hard drive to store media.
# exist_ok=True prevents crashes if the folders were already created during a previous run.
os.makedirs("uploads", exist_ok=True)   # Stores STT recordings and profile pictures
os.makedirs("temp_tts", exist_ok=True)  # Stores generated TTS mp3 files

# Mount static directories.
# This exposes these local folders to the web so the Flutter app can directly download
# or stream the audio files via URL (e.g., http://server-ip:8000/temp_tts/file.mp3).
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
app.mount("/temp_tts", StaticFiles(directory="temp_tts"), name="temp_tts")

# Load the OpenAI Faster-Whisper AI model into RAM on server startup.
# Loading it here ensures that transcription endpoints don't have to wait for the model
# to boot up every single time a user sends audio, dramatically reducing latency.
print("⏳ Loading Faster-Whisper 'medium'...")
try:
    stt_model = WhisperModel(
        "medium",           # The 'medium' model balances accuracy and speed.
        device="cpu",       # Forced to run on CPU. Change to "cuda" if you have an Nvidia GPU.
        compute_type="int8",# Quantization reduces the model's RAM footprint.
        cpu_threads=12,     # Maximizes processing speed on multi-core CPUs.
        num_workers=4,
        download_root="./models" # Caches the model locally so it doesn't redownload.
    )
    print("✅ Medium Model ready.")
except Exception as load_err:
    print(f"❌ Load Error: {load_err}")

@app.get("/")
async def health_check():
    """A simple ping endpoint to verify the server is running and accessible over the network."""
    return {"status": "online"}

# ==========================================
# 3. AUTHENTICATION & PROFILE MANAGEMENT
# ==========================================
# Endpoints to handle user registration, login, and profile updates.

@app.post("/signin")
async def signin(username: str, password: str = "password123"):
    """
    Authenticates a user. Checks if the username exists and if the password matches.
    If successful, the Flutter app will save the username to SharedPreferences.
    """
    conn = get_db_connection()
    try:
        user = conn.execute('SELECT * FROM users WHERE username = ?', (username,)).fetchone()
        if user and user['password'] == password:
            return {"status": "success", "username": username}
        raise HTTPException(status_code=401, detail="Invalid credentials")
    finally:
        conn.close()

@app.post("/signup")
async def signup(username: str, password: str = "password123"):
    """
    Registers a new user. It checks for uniqueness to prevent database conflicts.
    """
    conn = get_db_connection()
    try:
        if conn.execute('SELECT * FROM users WHERE username = ?', (username,)).fetchone():
            raise HTTPException(status_code=400, detail="Account exists.")
        conn.execute('INSERT INTO users (username, password) VALUES (?, ?)', (username, password))
        conn.commit()
        return {"status": "success"}
    finally:
        conn.close()

@app.get("/profile")
async def get_profile(username: str):
    """Fetches user details (name, gender, photo URL) to display on the Profile Screen."""
    conn = get_db_connection()
    try:
        user = conn.execute('SELECT username, password, name, gender, photo_path FROM users WHERE username = ?', (username,)).fetchone()
        return dict(user) if user else {}
    finally:
        conn.close()

@app.post("/update_profile")
async def update_profile(
        username: str = Form(...),
        name: str = Form(""),
        password: str = Form(""),
        gender: str = Form(""),
        file: UploadFile = File(None) # Optional profile picture upload
):
    """
    Updates the user's profile. Handles the complex logic of accepting both text form data
    and binary image data (Multipart form data) in a single request.
    """
    conn = get_db_connection()
    try:
        photo_path = ""
        if file:
            # Create a user-specific folder to prevent photo name collisions
            os.makedirs(f"uploads/{username}", exist_ok=True)
            photo_path = f"uploads/{username}/profile.jpg"
            # Stream the incoming image file directly to the hard drive
            with open(photo_path, "wb") as buffer:
                buffer.write(await file.read())

        # Update database conditionally based on whether a new photo was uploaded
        if photo_path:
            conn.execute(
                "UPDATE users SET name=?, password=?, gender=?, photo_path=? WHERE username=?",
                (name, password, gender, photo_path, username)
            )
        else:
            conn.execute(
                "UPDATE users SET name=?, password=?, gender=? WHERE username=?",
                (name, password, gender, username)
            )
        conn.commit()
        return {"status": "success"}
    finally:
        conn.close()

# ==========================================
# 4. SPEECH TO TEXT (STT) - WITH AUTO-TRANSLATE
# ==========================================
@app.post("/transcribe")
async def transcribe_audio(username: str, lang: str = "en", file: UploadFile = File(...)):
    """
    Receives voice recordings from the Flutter app, extracts the speech using AI,
    translates it to the requested language, and logs the event in the history table.
    """
    os.makedirs(f"uploads/{username}", exist_ok=True)
    ts = datetime.now().strftime('%Y%m%d_%H%M%S')
    temp_path = f"uploads/{username}/temp_{ts}.m4a"
    wav_path = f"uploads/{username}/{ts}.wav"

    # Map the human-readable language name from Flutter to the ISO code required by the Translator
    lang_map = {"bangla": "bn", "japanese": "ja", "english": "en", "arabic": "ar", "spanish": "es"}
    target_lang = lang_map.get(lang.lower(), "en")

    try:
        # Step 1: Save the incoming .m4a audio file locally
        content = await file.read()
        with open(temp_path, "wb") as buffer:
            buffer.write(content)

        # Step 2: Audio Pre-processing
        # Whisper requires 16kHz, single-channel (mono) audio for optimal accuracy.
        # Pydub normalizes the volume so quiet recordings are still understood.
        audio = AudioSegment.from_file(temp_path).set_frame_rate(16000).set_channels(1)
        audio = audio.apply_gain(-20.0 - audio.dBFS)
        audio.export(wav_path, format="wav")

        # Step 3: Transcription & Auto-Translation
        # Whisper natively transcribes the audio into English text (task="translate").
        # vad_filter=True removes background noise and silence before processing.
        segments, info = stt_model.transcribe(wav_path, beam_size=5, language=None, task="translate", vad_filter=True)
        english_text = " ".join([s.text for s in segments]).strip()

        # Handle empty recordings gracefully
        if not english_text:
            if os.path.exists(temp_path): os.remove(temp_path)
            return JSONResponse(content={"text": "No speech detected."})

        # Step 4: Final Language Translation
        # If the user requested a non-English result, pass Whisper's output through Google Translate
        if target_lang == "en":
            final_output = english_text
        else:
            final_output = GoogleTranslator(source='en', target=target_lang).translate(english_text)

        # Step 5: Save to History
        # Note: We save 'wav_path' so the user can play back their original recording later.
        conn = get_db_connection()
        conn.execute(
            "INSERT INTO records (username, original_text, audio_path, created_at, type) VALUES (?, ?, ?, ?, ?)",
            (username, final_output, wav_path, datetime.now().isoformat(), 'stt')
        )
        conn.commit()
        conn.close()

        # Cleanup the temporary .m4a file to save disk space
        if os.path.exists(temp_path): os.remove(temp_path)

        # Send the final translated text back to the Flutter UI
        return JSONResponse(content={"text": final_output})

    except Exception as e:
        if os.path.exists(temp_path): os.remove(temp_path)
        raise HTTPException(status_code=500, detail=str(e))

# ==========================================
# 5. HISTORY ENDPOINT
# ==========================================
@app.get("/history")
async def get_history(username: str):
    """
    Retrieves all past STT and TTS interactions for a specific user.
    The list is ordered by 'id DESC' so the most recent activities appear at the top of the app.
    """
    conn = get_db_connection()
    try:
        rows = conn.execute('SELECT * FROM records WHERE username = ? ORDER BY id DESC', (username,)).fetchall()
        return JSONResponse(content={"status": "success", "history": [dict(r) for r in rows]})
    finally:
        conn.close()

# ==========================================
# 6. TEXT TO SPEECH (TTS) - ROBUST ACCENT ENGINE
# ==========================================
@app.get("/tts")
async def text_to_speech(text: str, lang: str = "Male Standard", username: str = "muradsiam55@gmail.com", target_lang_name: str = "english"):
    """
    Converts text to natural-sounding human speech.
    Uses a 'Smart Mapping' routing system to ensure the Edge-TTS engine always uses
    a voice model that is compatible with the requested target language, preventing server crashes.
    """
    # Generate a unique ID to prevent users from overwriting each other's audio files
    request_id = str(uuid.uuid4())
    temp_mp3 = f"temp_tts/temp_{request_id}.mp3"

    # The Voice Dictionary: Maps 5 universal UI tones to specific Microsoft Neural Voice IDs for all supported languages.
    smart_voice_map = {
        "english": {
            "Male Standard": "en-US-ChristopherNeural",
            "Male Deep": "en-US-AndrewNeural",
            "Female Standard": "en-US-AriaNeural",
            "Female Soft": "en-US-AnaNeural",
            "Female Bright": "en-US-MichelleNeural",
        },
        "bangla": {
            "Male Standard": "bn-BD-PradeepNeural",
            "Male Deep": "bn-IN-BashkarNeural",
            "Female Standard": "bn-BD-NabanitaNeural",
            "Female Soft": "bn-IN-TanishaNeural",
            "Female Bright": "bn-BD-NabanitaNeural",
        },
        "japanese": {
            "Male Standard": "ja-JP-KeitaNeural",
            "Male Deep": "ja-JP-DaichiNeural",
            "Female Standard": "ja-JP-NanamiNeural",
            "Female Soft": "ja-JP-AoiNeural",
            "Female Bright": "ja-JP-MayuNeural",
        },
        "arabic": {
            "Male Standard": "ar-SA-HamedNeural",
            "Male Deep": "ar-AE-HamdanNeural",
            "Female Standard": "ar-SA-ZariyahNeural",
            "Female Soft": "ar-AE-FatimaNeural",
            "Female Bright": "ar-EG-SalmaNeural",
        },
        "spanish": {
            "Male Standard": "es-ES-AlvaroNeural",
            "Male Deep": "es-MX-JorgeNeural",
            "Female Standard": "es-ES-ElviraNeural",
            "Female Soft": "es-MX-DaliaNeural",
            "Female Bright": "es-ES-AbrilNeural",
        }
    }

    # Standardize inputs to prevent case-sensitive lookup errors
    target_key = target_lang_name.strip().lower()

    # Routing Logic Part 1: Find the relevant dictionary for the chosen language
    lang_group = smart_voice_map.get(target_key, smart_voice_map["english"])

    # Routing Logic Part 2: Select the specific voice model
    if lang in lang_group:
        # The user's chosen tone exists for this language
        selected_voice = lang_group[lang]
    elif lang in smart_voice_map["english"]:
        # Fallback: The tone doesn't exist natively, so use the English equivalent.
        # WARNING: This can cause errors if used to speak non-English text.
        selected_voice = smart_voice_map["english"][lang]
    else:
        # Ultimate fallback to ensure the server never crashes due to a missing key
        selected_voice = "en-US-ChristopherNeural"

    # Map the human language name to the ISO code required by Google Translate
    lang_code_map = {"bangla": "bn", "japanese": "ja", "english": "en", "arabic": "ar", "spanish": "es"}
    target_code = lang_code_map.get(target_key, "en")

    try:
        # Step 1: Translate the raw text into the requested target language
        translator = GoogleTranslator(source='auto', target=target_code)
        final_text_to_speak = translator.translate(text)

        # Step 2: Initialize the Edge-TTS engine with the translated text and mapped voice
        communicate = edge_tts.Communicate(final_text_to_speak, selected_voice)

        # Step 3: Await the asynchronous network call to Microsoft's servers to generate the audio
        await communicate.save(temp_mp3)

        # Step 4: Verification. Ensure the file actually downloaded before proceeding.
        if not os.path.exists(temp_mp3):
            print(f"❌ Error: File {temp_mp3} was not created.")
            raise HTTPException(status_code=500, detail="Audio file generation failed")

        # Step 5: Log the successful TTS generation in the user's history
        conn = get_db_connection()
        conn.execute(
            "INSERT INTO records (username, original_text, audio_path, created_at, type) VALUES (?, ?, ?, ?, ?)",
            (username, final_text_to_speak, temp_mp3, datetime.now().isoformat(), 'tts')
        )
        conn.commit()
        conn.close()

        # Return the actual MP3 file directly to the Flutter app's AudioPlayer
        return FileResponse(temp_mp3, media_type="audio/mpeg")

    except Exception as e:
        print(f"❌ Server Error: {str(e)}")
        # If the generation fails mid-way, delete the corrupted partial file
        if os.path.exists(temp_mp3):
            os.remove(temp_mp3)
        raise HTTPException(
            status_code=500,
            detail="Server error or internet connection issue with Edge-TTS"
        )

# Boilerplate to run the server locally when executing this script directly
if __name__ == "__main__":
    import uvicorn
    # host="0.0.0.0" ensures the server listens on all network interfaces,
    # making it accessible to phones/emulators on the same Wi-Fi network.
    uvicorn.run(app, host="0.0.0.0", port=8000)