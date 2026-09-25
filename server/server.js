const express = require('express');
const cors = require('cors');
const path = require('path');
const crypto = require('crypto');
const dotenv = require('dotenv');
const { MongoClient, ServerApiVersion } = require('mongodb');

dotenv.config({ path: path.join(__dirname, '..', '.env') });

const app = express();
const port = Number(process.env.SERVER_PORT || process.env.PORT || 9000);
const mongoUri = process.env.MONGODB_URI || '';
const ADMIN_USERNAME = process.env.ADMIN_USERNAME || 'admin';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'admin123';
const ADMIN_PASSWORD_HASH = process.env.ADMIN_PASSWORD_HASH || hashPassword(ADMIN_PASSWORD);
const ADMIN_SESSION_TTL_MS = Number(process.env.ADMIN_SESSION_TTL_MINUTES || 480) * 60 * 1000;
const APK_DOWNLOAD_URL = process.env.APK_DOWNLOAD_URL || 'https://example.com/heroism_of_war/HeroismOfWar.apk';
const adminTokens = new Map();

app.use(cors());
app.use(express.json({ limit: '20mb' }));

function createDefaultContent() {
  return {
    version: '1.0.0',
    loading: {
      title: 'Heroism of War',
      status: 'Loading battle lobby...',
      background_color: '#0A0F1A',
      accent_color: '#5EC8FF',
      animation: 'pulse'
    },
    lobby: {
      title: 'Battle Lobby',
      mode: 'Squad',
      features: ['Solo', 'Duo', 'Squad']
    },
    maps: [],
    characters: [],
    events: []
  };
}

function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const hashed = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');
  return `${salt}:${hashed}`;
}

function verifyPassword(password, storedHash) {
  if (!storedHash) {
    return password === ADMIN_PASSWORD;
  }

  const [salt, expectedHash] = String(storedHash).split(':');
  if (!salt || !expectedHash) {
    return false;
  }

  const derivedHash = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');
  return crypto.timingSafeEqual(Buffer.from(expectedHash, 'hex'), Buffer.from(derivedHash, 'hex'));
}

function generateToken() {
  return crypto.randomBytes(32).toString('hex');
}

function getAdminToken(req) {
  const auth = req.headers.authorization || req.headers['x-admin-token'];
  if (!auth) return null;
  if (typeof auth === 'string' && auth.startsWith('Bearer ')) {
    return auth.slice(7);
  }
  return auth;
}

function purgeExpiredTokens() {
  const now = Date.now();
  for (const [token, expiresAt] of adminTokens.entries()) {
    if (Number(expiresAt) <= now) {
      adminTokens.delete(token);
    }
  }
}

function requireAdmin(req, res, next) {
  purgeExpiredTokens();
  const token = getAdminToken(req);
  if (!token || !adminTokens.has(token)) {
    return res.status(401).json({ ok: false, error: 'Unauthorized' });
  }
  next();
}

let client;
let db;
let fallbackContent = createDefaultContent();

async function connectMongo() {
  if (db) return db;

  if (!mongoUri) {
    console.warn('MONGODB_URI is not set. Running in local-content fallback mode.');
    return null;
  }

  try {
    client = new MongoClient(mongoUri, {
      serverApi: {
        version: ServerApiVersion.v1,
        strict: true,
        deprecationErrors: true
      }
    });

    await client.connect();
    db = client.db('heroism_of_war');
    await db.collection('content_manifest').createIndex({ updatedAt: -1 });
    return db;
  } catch (error) {
    console.warn('MongoDB unavailable, using in-memory fallback:', error.message);
    return null;
  }
}

app.get('/health', (_req, res) => {
  res.json({ ok: true, service: 'heroism-of-war-backend', timestamp: new Date().toISOString() });
});

app.post('/api/admin/login', (req, res) => {
  const username = req.body && req.body.username ? String(req.body.username) : '';
  const password = req.body && req.body.password ? String(req.body.password) : '';

  if (username !== ADMIN_USERNAME || password !== ADMIN_PASSWORD) {
    return res.status(401).json({ ok: false, error: 'Invalid admin credentials' });
  }

  if (!verifyPassword(password, ADMIN_PASSWORD_HASH)) {
    return res.status(401).json({ ok: false, error: 'Invalid admin credentials' });
  }

  const token = generateToken();
  adminTokens.set(token, Date.now() + ADMIN_SESSION_TTL_MS);

  return res.json({ ok: true, token, expiresAt: new Date(Date.now() + ADMIN_SESSION_TTL_MS).toISOString() });
});

app.post('/api/admin/logout', requireAdmin, (req, res) => {
  const token = getAdminToken(req);
  if (token) {
    adminTokens.delete(token);
  }
  return res.json({ ok: true, loggedOut: true });
});

app.get('/api/content/latest', async (_req, res) => {
  const defaultContent = createDefaultContent();

  try {
    const database = await connectMongo();
    if (!database) {
      return res.json(fallbackContent);
    }

    const latest = await database.collection('content_manifest').findOne({}, { sort: { updatedAt: -1 } });
    if (!latest || !latest.content) {
      return res.json(fallbackContent);
    }

    return res.json({
      ...defaultContent,
      ...latest.content,
      version: latest.version || defaultContent.version,
      updatedAt: latest.updatedAt || null
    });
  } catch (error) {
    console.error('Failed to fetch latest content:', error);
    return res.status(500).json({ ok: false, error: 'Failed to fetch latest content' });
  }
});

app.get('/api/update/latest', async (_req, res) => {
  const version = fallbackContent.version || '1.0.0';

  try {
    const database = await connectMongo();
    let latestVersion = version;
    let latestUrl = APK_DOWNLOAD_URL;

    if (database) {
      const latest = await database.collection('content_manifest').findOne({}, { sort: { updatedAt: -1 } });
      if (latest && latest.version) {
        latestVersion = latest.version;
      }
    }

    return res.json({
      version: latestVersion,
      apk_url: latestUrl,
      update_available: false,
      message: 'Live APK update manifest endpoint.'
    });
  } catch (error) {
    console.error('Failed to fetch update manifest:', error);
    return res.status(500).json({ ok: false, error: 'Failed to fetch update manifest' });
  }
});

app.post('/api/admin/content/publish', requireAdmin, async (req, res) => {
  const payload = req.body || {};
  const content = payload.content || payload;
  const version = payload.version || new Date().toISOString();
  const updatedAt = new Date().toISOString();
  const doc = {
    version,
    updatedAt,
    updated_by: payload.updated_by || 'admin_android',
    content
  };

  fallbackContent = {
    ...createDefaultContent(),
    ...content,
    version,
    updatedAt
  };

  try {
    const database = await connectMongo();
    if (!database) {
      return res.json({ ok: true, fallback: true, version, updatedAt, message: 'MongoDB unavailable; content saved in fallback mode.' });
    }

    await database.collection('content_manifest').insertOne(doc);
    return res.json({ ok: true, version, updatedAt, storedInMongo: true });
  } catch (error) {
    console.error('Failed to publish content:', error);
    return res.status(500).json({ ok: false, error: 'Failed to publish content to database' });
  }
});

if (require.main === module) {
  app.listen(port, () => {
    console.log(`Heroism of War backend listening on http://localhost:${port}`);
  });
}

module.exports = app;
