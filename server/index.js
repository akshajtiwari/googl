/**
 * Simple key server for local development.
 * Exposes:
 *  GET /api/keys/google  -> { "key": "..." }
 *  GET /api/keys/gemini  -> { "key": "..." }
 *
 * NOTE: This server is for local development only. Do NOT expose real keys in public repos.
 */

const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => res.send('Key server running'));

app.get('/api/keys/google', (req, res) => {
    const key = process.env.GOOGLE_API_KEY || '';
    res.json({ key });
});

app.get('/api/keys/gemini', (req, res) => {
    const key = process.env.GEMINI_API_KEY || '';
    res.json({ key });
});

app.post('/api/generate/form', (req, res) => {
    const { prompt = '', model = '', temperature = 0.2, max_tokens = 200 } = req.body || {};

    // If a server-side GEMINI key exists, a real call to Gemini could be made here.
    // For local development and safety, we return a heuristic-generated list of fields
    // based on the prompt and parameters.

    function generateFieldsFromPrompt(promptText, maxTokens, temperatureVal) {
        const p = (promptText || '').toLowerCase();
        const fields = [];

        if (p.includes('signup') || p.includes('volunteer')) {
            fields.push('Full name', 'Email', 'Phone number', 'Preferred role', 'Availability');
        } else if (p.includes('availability')) {
            fields.push('Full name', 'Available dates', 'Available hours per day', 'Preferred zones');
        } else if (p.includes('incident')) {
            fields.push('Reporter name', 'Location', 'Incident type', 'Description', 'Photos (optional)');
        } else {
            const lines = (promptText || '').split(/\r?\n/).map(s => s.trim()).filter(Boolean);
            if (lines.length > 1) {
                const limit = Math.min(10, Math.max(3, Math.round(maxTokens / 100)));
                lines.slice(0, limit).forEach(l => fields.push(l));
            } else {
                const count = Math.min(10, Math.max(3, Math.round(maxTokens / 100)));
                for (let i = 1; i <= count; i++) fields.push(`Field ${i}`);
            }
        }

        if (temperatureVal > 0.6) fields.push('Notes (optional)');
        return fields;
    }

    try {
        const fields = generateFieldsFromPrompt(prompt, max_tokens || 200, temperature || 0.2);
        return res.json({ fields });
    } catch (err) {
        return res.status(500).json({ error: 'Generation failed', details: String(err) });
    }
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Key server listening on http://localhost:${port}`);
});
