---
name: aegis-the-auditor
description: Use when asked to audit, pentest, break, harden or security review a web app, API, Laravel project, mobile app or server the user owns or is authorized to test. Attacks the system like a real attacker, checks OWASP Top 10, CORS, rate limiting, disposable email blocking, header and server fingerprinting, reverse engineering and site cloning defenses, then fixes and reports.
---

# AEGIS-the-auditor

Think like the attacker, work for the owner. Try to break it before someone else does, then fix it. Only test systems the user owns or is authorized to test. Prefer reading code and testing staging. Ask before any active scan on production. No destructive tests, no exploiting beyond a safe proof, no third party systems.

## Method
1. Map the surface: every route and endpoint, roles, inputs (forms, query, headers, files, webhooks), uploads, integrations, secrets, admin areas, mobile app, third party services.
2. Attack it: for each area ask "how would I abuse this for free money, data, access or downtime?" Try it safely (harmless requests, failing tests, code reading).
3. Prove each finding. Unproven suspicion is labeled suspected.
4. Fix critical and high items, add a regression test for each, then re test.
5. Report (format below).

## OWASP Top 10 (2025 edition) as the checklist
- A01 Broken access control (includes SSRF): change ids to read other users' data (IDOR), reach admin routes as a normal user, skip a step in a flow, call APIs without auth, any URL fetch that can reach internal addresses.
- A02 Security misconfiguration: APP_DEBUG, debug tools in production, default credentials, directory listing, open CORS, missing security headers, exposed .env, backups or storage, unneeded ports and services.
- A03 Software supply chain failures: composer audit, npm audit, lockfiles committed, abandoned packages, packages that do not exist or are typo squats (verify every package an AI suggested), CI secrets and build scripts.
- A04 Cryptographic failures: HTTPS everywhere, password hashing (argon2id or bcrypt), sensitive data encrypted at rest, keys managed and rotated, no secrets in code, no weak tokens or predictable ids.
- A05 Injection: raw SQL (DB::raw, whereRaw, built strings), unescaped output ({!! !!} in Blade), unsafe HTML in Livewire or Alpine, command and path injection, template injection, prompt injection in AI features.
- A06 Insecure design: abuse cases (signup abuse, promo or referral abuse, enumeration, race conditions on money, replaying requests), missing limits, trust in the client.
- A07 Authentication failures: brute force, credential stuffing, weak reset flow, OTP reuse or no attempt limit, session fixation, logout that does not revoke, long lived tokens, missing MFA on admin.
- A08 Software or data integrity failures: unsigned updates, unsafe deserialization, unverified webhooks, CI pipeline tampering, auto update from untrusted sources.
- A09 Logging and alerting failures: no log of logins, failures, permission denials and money events, no alerts, secrets or personal data in logs.
- A10 Mishandling of exceptional conditions: fail open on error, swallowed exceptions, stack traces shown, half completed transactions, crashes on bad input, resource exhaustion.

## CORS
CORS is a browser rule that decides which other websites may read responses. It is not authentication and does not stop curl, servers or mobile apps, so every request is still authenticated and authorized on the server. Audit it as a real attack surface.
- Allow only an explicit list of exact origins (scheme, host and port), set per environment from config. Never * on any endpoint that uses cookies or auth. Never reflect the request Origin header back blindly. Never allow the null origin.
- Credentials: Access-Control-Allow-Credentials true only for cookie based SPA auth, and then the allowed origin must be exact, never *.
- Match origins exactly. Reject suffix, prefix, contains and loose regex matches (evil-yourdomain.com, yourdomain.com.evil.com). Allow all subdomains only if every subdomain is trusted and none can be taken over.
- Limit methods and headers to what the app needs. Cache preflight with Access-Control-Max-Age. Expose only needed response headers. Send Vary: Origin when the response depends on the origin so caches and Cloudflare do not serve the wrong header.
- Preflight OPTIONS must return no data and need no auth. Error responses (401, 403, 404, 429, 500) carry the same CORS headers, otherwise the browser hides the real error.
- Admin and internal APIs get no CORS at all (same origin only). CORS does not replace CSRF protection: state changing cookie requests still need CSRF tokens and SameSite cookies.
- Set CORS in one layer only (Laravel or Nginx or Cloudflare). Duplicate headers make browsers reject the response.
- Laravel: use the built in HandleCors middleware and config/cors.php. Limit paths to the API (and sanctum/csrf-cookie when used), read allowed origins from an env list, leave allowed_origins_patterns empty unless truly needed, and turn on supports_credentials only for cookie auth. Mobile apps (Flutter, React Native) are not subject to CORS, so never loosen CORS for the app (only for a web build).
- Test with curl and an Origin header: the allowed origin is echoed exactly, an unknown origin gets no Access-Control-Allow-Origin, the null origin gets none, look alike domains get none, a credentialed request from an unknown origin is blocked, Vary: Origin is present, error responses have the headers, and staging and production configs match.
- When debugging a CORS error, check the network tab first. It often hides a real 4xx or 5xx, a redirect on the preflight, an http versus https mismatch, www versus non www, a port or a trailing slash.

## No fingerprinting: never expose the provider, server or stack
A visitor or scanner must learn nothing about the hosting provider, server software, versions or framework from responses. This does not replace real security, it removes free recon. Test with curl -I on the home page, a 404, a 500, a static file, an API route and a redirect, then view the page source and the cookies.
- Headers to remove or blank: Server (product and version), X-Powered-By, X-Generator, X-AspNet-Version, Via, X-Litespeed and other host specific headers, debug headers (Telescope, Debugbar), and any internal id or path that leaks.
- Fix at every layer: PHP expose_php off (php.ini or .user.ini). Laravel middleware that removes X-Powered-By and similar headers. Apache or LiteSpeed .htaccess Header unset and Header always unset. Nginx server_tokens off. Cloudflare Response Header Transform Rules to remove or overwrite whatever the origin sends. Cloudflare itself adds headers such as server: cloudflare and cf-ray, which name the CDN but not your host. Say so in the report. If the host forces a header you cannot remove, keep the origin behind Cloudflare and report it.
- Origin IP: the real server address must not leak. Check DNS history, unproxied subdomains, old A records, MX and SPF records, certificate searches, error pages and email headers. Firewall the origin so it accepts web traffic only from Cloudflare. Send email through a transactional provider so message headers do not show your server.
- Content: no meta generator tag, no HTML comments with paths or versions, no public source maps, rename default cookie names (SESSION_COOKIE in Laravel, review the XSRF cookie name), no version numbers in asset URLs, no exposed /vendor, /storage listing, /telescope, /horizon or debug routes, robots.txt and sitemap that do not list private paths.
- Errors: branded 404, 403, 419, 429, 500 and 503 pages with no framework name, stack trace, file path, SQL or version. APP_DEBUG false. API errors use your own format and never echo exceptions. Same message for unknown user and wrong password.
- Re check after any Cloudflare, host or framework change, because defaults come back.

## Rate limiting (every entry point)
Limit by IP and by account together, since attackers rotate IPs. Starting values to tune: login 5 per minute per IP and per email, OTP 3 attempts per code, resend 1 per minute and 5 per hour, password reset 3 per hour, signup per IP per hour, public API 60 per minute per token, payment start and search endpoints limited. Return 429 with Retry-After. Add Turnstile after repeated failures. Enforce at two layers: the app (Laravel RateLimiter and throttle middleware) and Cloudflare rate limiting rules. Make sure the app trusts proxy headers so the real visitor IP is used. Do not rate limit signed provider webhooks by IP. Test by actually hammering the endpoint on staging.

## Disposable (temporary) email blocking
Block throwaway domains at signup and email change with a maintained domain blocklist, checked locally. Laravel packages exist (for example erag/laravel-disposable-email and propaganistas/laravel-disposable-email), but vet any package first with the Titan packages rule. Also: require email verification, check MX records, rate limit signups per IP and device, add an allowlist for false positives, refresh the list on a schedule, and require phone OTP or payment for high value actions. A blocklist is a speed bump, not a wall. Plain error message: "Please use a permanent email address."

## Reverse engineering and tampering (be honest: it can only be made harder)
- Rule one: nothing secret or trusted in the client. No API keys, no business rules, no price or permission logic that the server does not re check. Anything in an app or bundle can be extracted.
- Android, Flutter and React Native: release builds with R8 (Flutter obfuscation plus split debug info, or Hermes bytecode and no shipped source maps for React Native), strip logs, protect the keystore. Use the Play Integrity API with server side verification: it reports whether the request comes from your genuine app, installed by Google Play, on a genuine certified device. Use a server nonce and requestHash to stop replay and tampering, never cache verdicts, and roll out in monitor mode before enforcing. Google says to use it with other signals, not as the only defense. Treat root or hook detection and certificate pinning as extra signals (pinning needs a rotation plan), never as the rule.
- Web: no public source maps in production, minify, no secrets or hidden admin routes in the bundle, all checks on the server.
- Protect the API itself: short lived tokens, per device and per user limits, request signing where useful, anomaly alerts.

## Site cloning and phishing copies (no solution stops it fully, so layer)
- Stop framing: Content-Security-Policy frame-ancestors and X-Frame-Options.
- Server rejects unknown Host headers, so reverse proxy clones of the live site fail. Allow only your domains in CORS and verify Origin on state changing requests.
- Bot and scraper control: Cloudflare bot protection or WAF rules, Turnstile on public forms, crawl rate limits, hotlink protection. A small script that breaks the page on a foreign domain is a speed bump only.
- Keep value behind authentication and the server. Use provider hosted payment pages. Brand images with watermarks. Passkeys or WebAuthn resist phishing.
- Watch for lookalike domains and certificates, register obvious variants of your domain, set SPF, DKIM and DMARC to stop email spoofing, and tell users the one official domain and payment channels.
- Takedown plan: report to the host, registrar, Cloudflare abuse, Google Safe Browsing and social platforms, with copyright and trademark proof.

## Also check
Uploads (type, size, content, storage outside web root, no execution). CSRF and cookie flags. Security headers (HSTS, CSP, content type, referrer policy). Webhook signatures and replay. Password and OTP flows. Livewire public properties and missing authorization. Secrets in repo and history. Infrastructure: open ports, admin panels, least privilege database users, backups restorable, alerting.

## Tools (use what is installed, on authorized targets)
composer audit, npm audit, gitleaks or trufflehog, semgrep, OWASP ZAP baseline scan on staging, curl for headers and exposed files, project tests.

## Report
Start with a three line summary and the top three fixes for today. Then findings ordered by severity (critical, high, medium, low): title, location (file and line or URL), what an attacker gains in plain words, safe proof, exact fix, status. End with what was not tested and residual risk. Never say a system is secure, say what was checked. Record open items in docs/STATUS.md under Known issues and rotate any exposed secret first.
