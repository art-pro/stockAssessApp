# Vercel Deployment Protection - Quick Guide

## What You're Seeing

When you curl your Vercel deployment and see "Authentication Required", this is **Vercel's Deployment Protection** feature, not an error with your application.

```
✅ Good: Your deployment succeeded!
🔒 Expected: Preview deployments are protected by default
```

---

## Understanding Your Deployment URLs

Vercel creates different URLs for different deployment types:

### 1. **Production Deployment** (Recommended for API Access)
```
https://stock-assess-app-backend.vercel.app/api/stocks
```
- ✅ Public by default
- ✅ Stable URL
- ✅ Used by your frontend in production
- 📍 Set in: `NEXT_PUBLIC_API_URL` environment variable

### 2. **Git Branch Preview Deployments**
```
https://stock-assess-app-backend-git-main-artpros-projects.vercel.app/api/stocks
                               ^^^^^^^^
                         Branch name included
```
- 🔒 Protected by default
- 🔄 Updates with each commit
- 🧪 For testing before promoting to production

### 3. **Unique Deployment URLs**
```
https://stock-assess-app-backend-abc123xyz.vercel.app/api/stocks
                               ^^^^^^^^^
                        Unique deployment ID
```
- 🔒 Protected by default
- 📸 Immutable snapshot of specific deployment
- 🔍 Found in deployment details

---

## How to Access Your API

### **Method 1: Use Production URL** ✅ RECOMMENDED

```bash
# Find your production URL in Vercel Dashboard
curl https://stock-assess-app-backend.vercel.app/api/stocks

# Expected response (API is working!):
# {"error":"Unauthorized"}  ← This means the Go API is responding!
```

**To find your production URL:**
1. Go to https://vercel.com/dashboard
2. Click your backend project name
3. Look for **Domains** section at top
4. Copy the domain that doesn't have `git-` or random characters

---

### **Method 2: Disable Preview Protection** (For Development)

**When to use this:**
- You're actively testing preview deployments
- You need to share preview URLs with team members
- You want quick access without authentication

**Steps:**
1. Go to Vercel Dashboard → Your Backend Project
2. **Settings** → **Deployment Protection**
3. Choose your protection level:

#### **Option A: Standard Protection** (Recommended)
```
☑ Only preview deployments with vercel.app

✅ Protects: *.vercel.app preview URLs
✅ Public: Your production domain
```

#### **Option B: Disabled** (Not Recommended for Production)
```
☑ Disabled (Not Recommended)

⚠️ All deployments are public
⚠️ Anyone can access any deployment
```

#### **Option C: All Deployments** (Most Secure)
```
☑ All Deployments (Standard Protection)

🔒 Protects: All deployment URLs including production
🔑 Requires: Vercel authentication to access anything
```

---

### **Method 3: Use Bypass Token** (For CI/CD)

If you need programmatic access to protected deployments:

1. **Generate bypass token:**
   - Vercel Dashboard → Project Settings → Deployment Protection
   - Click "Create bypass token"
   - Copy the token

2. **Use with curl:**
```bash
curl "https://your-deployment.vercel.app/api/stocks?x-vercel-protection-bypass=YOUR_TOKEN"
```

3. **Use in GitHub Actions/CI:**
```yaml
env:
  VERCEL_BYPASS_TOKEN: ${{ secrets.VERCEL_BYPASS_TOKEN }}
```

---

## Recommended Setup for Your Stock Portfolio App

### **Backend (Go API)**

**Deployment Protection:** Disabled or "Only preview deployments"
- Your API needs to be publicly accessible
- Authentication is handled by JWT tokens in your Go code
- Backend already has security via `auth` middleware

**Configuration:**
```
Settings → Deployment Protection → Disabled (Not Recommended)
```
Or keep protected and use production URL only.

**Production URL for Frontend:**
```
NEXT_PUBLIC_API_URL=https://stock-assess-app-backend.vercel.app/api
```

---

### **Frontend (Next.js)**

**Deployment Protection:** Standard (Optional)
- Can keep protected during development
- Disable when ready to share publicly
- Your backend authentication protects data access

**Environment Variable:**
```
NEXT_PUBLIC_API_URL=https://stock-assess-app-backend.vercel.app/api
```
⚠️ Make sure this points to **production URL**, not git-branch URL!

---

## Testing Your Deployment

### 1. **Test Backend API (Production URL)**
```bash
# Should return 401 (needs JWT) - This is GOOD!
curl https://stock-assess-app-backend.vercel.app/api/stocks

# Expected response:
{"error":"Unauthorized"}
```

✅ This means your Go API is working and authentication is enabled!

### 2. **Test Login Endpoint**
```bash
curl -X POST https://stock-assess-app-backend.vercel.app/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"artpro","password":"your-password"}'

# Expected: JWT token response
```

### 3. **Test Authenticated Request**
```bash
# First login and save token
TOKEN=$(curl -X POST https://stock-assess-app-backend.vercel.app/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"artpro","password":"your-password"}' | jq -r .token)

# Then use token
curl https://stock-assess-app-backend.vercel.app/api/stocks \
  -H "Authorization: Bearer $TOKEN"

# Expected: List of stocks (empty array if no stocks added yet)
```

### 4. **Test Frontend**
```bash
# Open in browser
open https://your-frontend.vercel.app

# Should see:
- Login page
- Ability to login with credentials
- Dashboard after login
```

---

## Common Issues After Fixing Deployment Config

### Issue: "Authentication Required" page when curling
**Cause:** You're using a preview/branch deployment URL  
**Solution:** Use production URL or disable deployment protection

### Issue: Frontend can't connect to backend
**Cause:** `NEXT_PUBLIC_API_URL` points to protected preview URL  
**Solution:** Update environment variable to production URL:
```
NEXT_PUBLIC_API_URL=https://stock-assess-app-backend.vercel.app/api
```

### Issue: Backend returns 401 for all requests
**Cause:** This is expected! Your API requires JWT authentication  
**Solution:** Login first to get token, then use token in Authorization header

### Issue: 500 Internal Server Error
**Cause:** Missing environment variables or database issues  
**Solution:** 
1. Check Vercel Dashboard → Settings → Environment Variables
2. Verify all required variables are set:
   - `ADMIN_USERNAME`
   - `ADMIN_PASSWORD`
   - `JWT_SECRET`
   - `DATABASE_PATH=/tmp/stocks.db`
3. Check function logs for specific error

---

## URL Comparison

| URL Type | Example | Protected? | Use Case |
|----------|---------|------------|----------|
| Production | `backend.vercel.app` | No (by default) | Frontend API calls |
| Git Branch | `backend-git-main.vercel.app` | Yes | Testing commits |
| Unique | `backend-abc123.vercel.app` | Yes | Specific deployment |
| Custom Domain | `api.yourdomain.com` | Configurable | Professional setup |

---

## Next Steps

1. ✅ **Find your production URL** in Vercel Dashboard
2. ✅ **Test the production endpoint** with curl
3. ✅ **Update frontend environment variable** if needed
4. ✅ **Test frontend login** in browser
5. ✅ **(Optional) Configure deployment protection** based on your needs

---

## Quick Commands

```bash
# Find which URL you should use
echo "Check your Vercel Dashboard for production URL"

# Test backend health (should return 401 if working)
curl https://stock-assess-app-backend.vercel.app/api/stocks

# Login and get token
curl -X POST https://stock-assess-app-backend.vercel.app/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"artpro","password":"YOUR_PASSWORD"}'

# View Vercel logs for errors
echo "Go to: https://vercel.com/dashboard → Project → Deployments → Click latest → Function Logs"
```

---

## Understanding the Response

When you see the "Authentication Required" HTML page, it means:
- ✅ **Good**: Deployment succeeded (no DEPLOYMENT_NOT_FOUND)
- ✅ **Good**: Vercel is serving your application
- 🔒 **Expected**: Preview deployment is protected
- 📍 **Action**: Use production URL or adjust protection settings

When you see `{"error":"Unauthorized"}`, it means:
- ✅ **Perfect**: Your Go API is running
- ✅ **Perfect**: JWT authentication is working
- ✅ **Perfect**: You just need to login to get a token

---

**Status**: 🎉 Your deployment is working! Just use the right URL or adjust protection settings.

