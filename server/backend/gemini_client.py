import os
import requests

GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')

def _call_gemini(prompt: str, model: str = 'gemini-1.5-flash'):
    if not GEMINI_API_KEY:
        raise RuntimeError('GEMINI_API_KEY not configured in environment')

    url = f'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={GEMINI_API_KEY}'
    payload = {
        'contents': [
            {'parts': [{'text': prompt}]}
        ],
        'generationConfig': {
            'temperature': 0.2,
        }
    }

    r = requests.post(url, json=payload, timeout=30)
    r.raise_for_status()

    data = r.json()
    # Extract the text from the response
    return data['candidates'][0]['content']['parts'][0]['text']


def generate_form(requirements: str):
    prompt = (
        'Generate a JSON schema for a volunteer form with the following requirements:\n'
        f"{requirements}\n"
        'Return ONLY valid JSON with keys: title, description, questions '
        '(array of {label, type, required, options}). No markdown, no backticks.'
    )
    return _call_gemini(prompt)


def generate_chat_reply(message: str):
    prompt = f'User: {message}\nAssistant:'
    return _call_gemini(prompt)