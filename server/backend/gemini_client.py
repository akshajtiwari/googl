import os
import requests

GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')

def _call_gemini(prompt: str, model: str = 'text-bison-001'):
    """
    Example minimal wrapper for calling the Generative Language REST API.
    This is a simple placeholder — depending on your Google setup you may
    prefer to use the official client library or authenticate with a
    service account. Keep your API key in the server-side .env.
    """
    if not GEMINI_API_KEY:
        raise RuntimeError('GEMINI_API_KEY not configured in environment')

    # NOTE: adjust endpoint and payload according to the Google API you use.
    url = f'https://generativelanguage.googleapis.com/v1beta2/models/{model}:generateText?key={GEMINI_API_KEY}'
    payload = {
        'prompt': {'text': prompt},
        'temperature': 0.2,
    }
    r = requests.post(url, json=payload, timeout=30)
    r.raise_for_status()
    return r.json()

def generate_form(requirements: str):
    prompt = (
        'Generate a JSON schema for a volunteer form with the following requirements:\n'
        f"{requirements}\n"
        'Return ONLY valid JSON with keys: title, description, questions (array of {label,type,required,options}).'
    )
    return _call_gemini(prompt)

def generate_chat_reply(message: str):
    prompt = f'User: {message}\nAssistant:'
    return _call_gemini(prompt)
