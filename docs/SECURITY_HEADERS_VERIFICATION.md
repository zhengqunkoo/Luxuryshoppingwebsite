# Security Headers Verification Guide

This document provides instructions for verifying that security headers are properly configured and deployed.

## Security Headers Implemented

The following security headers are implemented in `app.py` via the `add_security_headers()` middleware:

### 1. Content Security Policy (CSP)
**Header:** `Content-Security-Policy`  
**Value:** `default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com https://fonts.googleapis.com; font-src 'self' https://cdnjs.cloudflare.com https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self'; frame-ancestors 'self'`

**Purpose:** Prevents XSS attacks by controlling which resources can be loaded.

### 2. X-Frame-Options
**Header:** `X-Frame-Options`  
**Value:** `SAMEORIGIN`

**Purpose:** Prevents clickjacking attacks by controlling whether the page can be framed.

### 3. X-Content-Type-Options
**Header:** `X-Content-Type-Options`  
**Value:** `nosniff`

**Purpose:** Prevents MIME type sniffing attacks.

### 4. Strict-Transport-Security (HSTS)
**Header:** `Strict-Transport-Security`  
**Value:** `max-age=31536000; includeSubDomains`

**Purpose:** Enforces HTTPS connections for 1 year including all subdomains.

### 5. Permissions-Policy
**Header:** `Permissions-Policy`  
**Value:** `geolocation=(), microphone=(), camera=()`

**Purpose:** Restricts browser features to prevent unauthorized access.

### 6. Cross-Origin-Resource-Policy
**Header:** `Cross-Origin-Resource-Policy`  
**Value:** `same-origin`

**Purpose:** Protects against Spectre vulnerabilities.

### 7. Cross-Origin-Opener-Policy
**Header:** `Cross-Origin-Opener-Policy`  
**Value:** `same-origin`

**Purpose:** Protects against Spectre vulnerabilities.

### 8. Cache-Control (Context-Sensitive)
**Header:** `Cache-Control`  
**Values:** 
- Sensitive pages (login, register, cart, admin): `no-store, no-cache, must-revalidate, private, max-age=0`
- Static assets: `public, max-age=31536000, immutable`
- Public pages: `public, max-age=300`

**Purpose:** Controls caching behavior based on content sensitivity.

### 9. Server Header Removal
The `Server` header is removed to prevent version information disclosure.

## Cookie Security Configuration

In `app.py`, session cookies are configured with:

```python
app.config['SESSION_COOKIE_SECURE'] = not use_local_db  # True in production
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
```

- **Secure flag:** Ensures cookies are only sent over HTTPS (production only)
- **HttpOnly flag:** Prevents JavaScript access to cookies
- **SameSite:** Protects against CSRF attacks

## Subresource Integrity (SRI)

External CDN resources in `templates/base.html` use SRI hashes:

- **Bootstrap CSS:** `integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM"`
- **Bootstrap JS:** `integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz"`
- **Font Awesome CSS:** `integrity="sha512-9usAa10IRO0HhonpyAIVpjrylPvoDwiPUiKdWk5t3PyolY1cOd4DSE0Ga+ri4AuTroPR5aQvXU9xC6qOPnzFeg=="`

**Note:** Google Fonts do not support SRI as they dynamically generate CSS content.

## Verification Methods

### Method 1: Using curl (Command Line)

```bash
# Check homepage headers
curl -I https://luxuryshoppingwebsite.azurewebsites.net

# Check specific header
curl -I https://luxuryshoppingwebsite.azurewebsites.net | grep -i "content-security-policy"

# Check login page cache headers
curl -I https://luxuryshoppingwebsite.azurewebsites.net/login | grep -i "cache-control"
```

### Method 2: Using Browser Developer Tools

1. Open the website in your browser
2. Open Developer Tools (F12)
3. Go to the "Network" tab
4. Refresh the page
5. Click on the first request (usually the HTML document)
6. Go to the "Headers" section
7. Look for "Response Headers"
8. Verify the security headers are present

### Method 3: Using Online Security Header Checkers

- **Security Headers:** https://securityheaders.com/
- **Mozilla Observatory:** https://observatory.mozilla.org/

### Method 4: Using OWASP ZAP

Run an OWASP ZAP scan to verify:
1. Content Security Policy (CSP) Header is set ✓
2. Anti-clickjacking Header (X-Frame-Options) is set ✓
3. X-Content-Type-Options Header is set ✓
4. Strict-Transport-Security Header is set ✓
5. Permissions Policy Header is set ✓
6. Server header is not leaking version information ✓

## Expected Results After Deployment

Once this PR is merged to `main` and deployed, the following should be true:

### ✅ Resolved Issues
- Content Security Policy (CSP) Header Not Set → **FIXED**
- Missing Anti-clickjacking Header → **FIXED**
- X-Content-Type-Options Header Missing → **FIXED**
- Strict-Transport-Security Header Not Set → **FIXED**
- Permissions Policy Header Not Set → **FIXED**
- Server Leaks Version Information → **FIXED**
- Sub Resource Integrity Attribute Missing → **FIXED** (for Bootstrap and Font Awesome)
- Re-examine Cache-control Directives → **FIXED** (optimized per endpoint)
- Cookie Without Secure Flag → **FIXED** (in production with HTTPS)
- Cookie without SameSite Attribute → **FIXED**

### ⚠️ Known Limitations

#### ARRAffinity Cookies (Azure-Controlled)
The Azure App Service load balancer sets `ARRAffinity` and `ARRAffinitySameSite` cookies that we cannot control from the application level. These are:
- **ARRAffinity:** Set without SameSite attribute
- **ARRAffinitySameSite:** Set with SameSite=None

**Resolution:** These are Azure infrastructure cookies and are acceptable. They do not contain sensitive application data.

#### Google Fonts
Google Fonts CSS is dynamically generated and cannot use SRI hashes. This is by design and accepted as a calculated risk given Google's reliability.

#### Base64 in Session Cookies
Flask session cookies contain Base64-encoded data. This is the standard Flask session mechanism and is secure as:
1. Data is signed with SECRET_KEY
2. Cookies have HttpOnly flag
3. Cookies have Secure flag in production
4. Cookies have SameSite protection

### ℹ️ Informational Alerts (Expected)
The following will remain as informational-only:
- **Sec-Fetch headers** - Browser-sent, not server-controlled
- **Authentication Request Identified** - Informational only
- **Session Management Response Identified** - Informational only
- **Timestamp Disclosure** - Low risk, timestamps in CDN resources
- **User Controllable HTML Element Attribute** - Standard form behavior with CSRF protection
- **Storable and Cacheable Content** - Appropriate caching strategy implemented

## Troubleshooting

### Headers Not Appearing in Production

If headers are missing after deployment:

1. **Verify deployment:** Check that the latest code is deployed
   ```bash
   # Check which Docker image is running
   az webapp config container show --resource-group LuxuryShoppingStudent --name luxuryshoppingwebsite
   ```

2. **Check logs:** Review application logs
   ```bash
   az webapp log tail --resource-group LuxuryShoppingStudent --name luxuryshoppingwebsite
   ```

3. **Verify middleware is registered:**
   - Ensure `add_security_headers()` function exists in `app.py`
   - Ensure it's decorated with `@app.after_request`
   - Ensure it returns the response object

4. **Check for proxy/load balancer interference:**
   - Some proxies strip or modify headers
   - May need to configure Azure App Service settings

### Testing Locally

To test security headers locally before deployment:

```python
# Create test_headers.py
import os
os.environ['USE_LOCAL_DB'] = 'true'
os.environ['OPENAI_API_KEY'] = 'test'
os.environ['GEMINI_API_KEY'] = 'test'

from app import app

with app.test_client() as client:
    response = client.get('/')
    for header in ['Content-Security-Policy', 'X-Frame-Options', 
                   'X-Content-Type-Options', 'Strict-Transport-Security',
                   'Permissions-Policy', 'Server']:
        print(f"{header}: {response.headers.get(header, 'NOT SET')}")
```

Run with: `python3 test_headers.py`

## Maintenance

### Updating SRI Hashes

When updating CDN libraries (Bootstrap, Font Awesome), update SRI hashes in `templates/base.html`:

1. Go to the CDN page (e.g., https://www.jsdelivr.com/)
2. Find the specific version
3. Copy the SRI hash provided
4. Update the `integrity` attribute in `base.html`

Example:
```html
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" 
      rel="stylesheet" 
      integrity="sha384-NEW_HASH_HERE" 
      crossorigin="anonymous">
```

### Updating CSP Directives

If adding new CDN sources or features:

1. Open `app.py`
2. Find the `add_security_headers()` function
3. Update the `csp_directives` list
4. Test locally
5. Deploy and verify

## References

- [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/)
- [MDN Web Security](https://developer.mozilla.org/en-US/docs/Web/Security)
- [Content Security Policy Reference](https://content-security-policy.com/)
- [Subresource Integrity](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity)
- [Flask Security Best Practices](https://flask.palletsprojects.com/en/latest/security/)
