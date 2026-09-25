# Heroism of War backend

This backend supports the live content API, admin login, and protected content publishing flow for the Godot client.

## Local development

```bash
cd server
npm install
cp ../.env.example ../.env
npm start
```

## Production hosting

A Render deployment is already scaffolded in the repository root via `render.yaml`.

1. Create a new Render web service from the repository.
2. Choose the root project as the source.
3. Add these environment variables from your secure secret vault:
   - `ADMIN_USERNAME`
   - `ADMIN_PASSWORD_HASH`
   - `MONGODB_URI`
4. Deploy.

### Generate a password hash

```bash
node - <<'NODE'
const crypto = require('crypto');
const password = process.argv[2] || 'change-me';
const salt = crypto.randomBytes(16).toString('hex');
const hash = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');
console.log(`${salt}:${hash}`);
NODE "your-secure-password"
```

Then set `ADMIN_PASSWORD_HASH` to the generated value.
