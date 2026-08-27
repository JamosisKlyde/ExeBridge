# Security Policy

## Reporting a security issue

Please do not publish credentials, authentication tokens, private keys, personal data, or exploit details that could put users at immediate risk in a public issue.

For ordinary bugs that do not expose sensitive information, use the GitHub issue tracker.

## Logs

ExeBridge debug logs may contain local file paths, executable names, runtime details, and environment information. Review logs before sharing them publicly.

Never include:

- Passwords
- API keys
- Authentication tokens
- Private keys
- Session cookies
- Personal documents or unrelated file contents

## Privilege model

Normal ExeBridge application launches are intended to run as the current user and should not require `sudo` or `pkexec`.

Any installer step that requires elevated privileges should be limited to system package installation or other clearly identified system-level setup.
