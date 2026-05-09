VoiceStory AI

 A full-stack,AI-powered mobile application built with Flutter and Python . This app allows users to record their voice, transcribe it using AI, automatically translate it into   multiple languages, and generate high-quality neural Text-to-Speech (TTS) audio.

Features:
 Speech-to-Text (STT): Uses OpenAI's `faster-whisper` for offline, highly accurate transcription.
 Auto-Translation: Integrates `deep-translator` to translate English, Bangla, Japanese, Arabic, and Spanish.
 Neural Text-to-Speech (TTS): Uses Microsoft `edge-tts` to generate realistic human voices with 5 universal tones.
 Offline Database: Uses SQLite to securely store user profiles and translation history.

Tech Stack:
 Frontend: Flutter, Dart, AudioPlayers package.
 Backend: Python, FastAPI, Uvicorn.
 AI Models: Faster-Whisper, Edge-TTS, Pydub.
