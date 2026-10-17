# Security Policy

Security and operational reliability are top priorities for **Bash Automation Toolbox**. This policy outlines our vulnerability disclosure process, reporting channels, and security standards.

---

## 🛡️ Supported Versions

Only active release versions receive security patches and updates:

| Version | Supported          | Security Contact |
| ------- | ------------------ | ---------------- |
| 1.x     | :white_check_mark: | `artemrivnyi@outlook.com` |
| < 1.0   | :x:                | N/A |

---

## 🔒 Reporting a Vulnerability

**Please DO NOT report security vulnerabilities through public GitHub issues or discussions.**

If you discover a security vulnerability, please report it privately:

1. **GitHub Private Vulnerability Reporting**: Open a confidential security advisory on GitHub under the repository's **Security** tab.
2. **Email**: Send details directly to `artemrivnyi@outlook.com` with the subject `[SECURITY] Bash Automation Toolbox - Vulnerability Report`.

### What to Include in Your Report
* Detailed description of the vulnerability and its potential impact
* Step-by-step reproduction instructions or a minimal proof-of-concept
* Affected files, configurations, or endpoints
* Any suggested remediation or mitigation steps

### Our Commitment
* **Acknowledgment**: Within 48 hours of initial receipt.
* **Triage & Assessment**: Prompt investigation and severity assessment.
* **Responsible Disclosure**: We coordinate disclosure timelines with reporters once a patch has been validated and released.

---

## 🏛️ Security Guidelines & Best Practices

* **Root Execution Warning**: Exercise extreme caution when executing shell scripts with `sudo`. Audit scripts before execution.
* **Input Sanitization**: Always sanitize and quote user inputs in shell functions to prevent command injection.
* **Secret Management**: Never commit API keys, cloud credentials, tokens, or private certificates to source control.
* **Dependency Scanning**: Dependencies should be regularly audited for known CVEs.
* **Least Privilege**: Run containers and processes with minimal required permissions.
