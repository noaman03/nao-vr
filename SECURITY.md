# Security

Do not commit real Wi-Fi credentials, private IP-only setup files, device tokens, API keys, or account credentials.

Local-only files are ignored by Git:

- `controller/include/secrets.h`
- `head_tracking/include/secrets.h`
- `tracking_config.py`
- `.env`

If a secret is accidentally committed, rotate the password or token immediately, then remove it from Git history before pushing to GitHub.
