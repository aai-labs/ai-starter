# Security Checklist

Use this checklist when a change touches authentication, authorization, user data, payments, secrets, uploads, external requests, database queries, or infrastructure.

## Authentication

Check whether:

- The code correctly identifies the user.
- Session or token validation cannot be bypassed.
- Expired or revoked credentials are rejected.
- Anonymous users cannot access authenticated behavior.

## Authorization

Check whether:

- The user is allowed to perform the action.
- Authorization is based on trusted server-side identity, not request body fields.
- Tenant, workspace, organization, or account boundaries are enforced.
- Admin-only actions require admin permissions.
- Read and write permissions are checked separately when needed.

## Input validation

Check whether:

- User input is validated before use.
- IDs, emails, URLs, filenames, and enum values are checked.
- Invalid input fails safely.
- Validation happens on the server, not only in the client.

## Injection risks

Check for:

- SQL injection
- Command injection
- Template injection
- Path traversal
- Unsafe dynamic regular expressions
- Unsafe deserialization
- Unsafe eval-like behavior

Look for string concatenation in database queries, shell commands, file paths, and templates.

## Secrets

Check whether:

- Secrets are not committed.
- Secrets are not logged.
- API keys and tokens are read from secure configuration.
- Error messages do not leak credentials.
- Client-side code does not expose server-only secrets.

## Data exposure

Check whether:

- API responses expose only intended fields.
- Logs do not contain sensitive data.
- Error messages do not reveal private information.
- One user cannot read another user's data.
- Pagination, search, and export endpoints enforce access control.

## File uploads and downloads

Check whether:

- File type and size are validated.
- User-controlled filenames are sanitized.
- Uploaded files cannot overwrite arbitrary paths.
- Downloads enforce authorization.
- Public URLs are intentional.
- Generated files do not contain sensitive data.

## External requests

Check whether:

- User-provided URLs can cause SSRF.
- Internal network addresses are blocked when necessary.
- Redirects are handled safely.
- Timeouts are configured.
- Failures do not expose sensitive details.

## Payments and billing

Check whether:

- Prices and quantities are trusted from the server, not the client.
- Webhooks verify signatures.
- Webhook handling is idempotent.
- Subscription or entitlement changes are validated.
- Refund, cancellation, and downgrade flows are safe.

## High-risk finding rule

If a plausible security issue could allow unauthorized access, data exposure, privilege escalation, or secret leakage, mark it as `P0` when clearly exploitable or `P1` when likely but needing confirmation.