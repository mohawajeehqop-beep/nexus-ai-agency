# Security Checklist

## Secrets
- Store secrets in a vault (AWS Secrets Manager, HashiCorp Vault, Railway secrets, etc.)
- Never commit `.env` with production secrets

## Network
- Use TLS for all external endpoints
- Restrict access to DB and Redis to trusted networks

## Application
- Validate and sanitize user input via Pydantic
- Rate-limit public endpoints
- Use strong JWT secrets & rotate keys periodically

## Monitoring
- Configure Sentry / error monitoring
- Track suspicious activity (multiple failed logins)

## Dependencies
- Keep dependencies up-to-date and monitor CVEs
