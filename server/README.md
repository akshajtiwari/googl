# Local Key Server

Run a minimal Node server to serve API keys from a `.env` file for local development.

Setup:

```bash
cd server
npm install
npm start
```

The server exposes:

- `GET /api/keys/google` -> `{ "key": "..." }`
- `GET /api/keys/gemini` -> `{ "key": "..." }`

Security:

- The `.env` file contains secrets. Do not commit it to source control. `.gitignore` already includes `.env`.
- Only use this server for local development.
