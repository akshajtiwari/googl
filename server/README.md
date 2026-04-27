FastAPI backend for the NGO Admin portal

Setup
1. Create a Python virtual environment and install dependencies:

   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt

2. Copy `.env.example` to `.env` and add your Gemini API key and a JWT secret:

   GEMINI_API_KEY=your_gemini_api_key_here
   JWT_SECRET=some_long_random_secret

3. Run the server:

   uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000

Endpoints
- POST /auth/register  -> register a user (username, password)
- POST /auth/login     -> login and receive a JWT token
- POST /forms/generate -> protected; generate form from requirements
- POST /chat           -> protected; send chat messages to Gemini

Security
- Keep `GEMINI_API_KEY` only in the server `.env` file. Do not place it in your Flutter app.
