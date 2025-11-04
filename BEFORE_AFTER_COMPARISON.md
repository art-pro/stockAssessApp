# Before & After: Vercel Configuration Fix

## Visual Comparison

### ❌ BEFORE (What Was Wrong)

```
vercel.json Configuration:
┌──────────────────────────────────────────────────────────┐
│ {                                                        │
│   "version": 2,                                          │
│   "rewrites": [                                          │  ← Wrong: Not for Go builds
│     {                                                    │
│       "source": "/api/:path*",                           │
│       "destination": "/api/handler"  ← Missing .go       │
│     }                                                    │
│   ],                                                     │
│   "routes": [                                            │
│     {                                                    │
│       "src": "/",                                        │
│       "dest": "/public/index.html"  ← Wrong for backend │
│     }                                                    │
│   ]                                                      │
│ }                                                        │
└──────────────────────────────────────────────────────────┘

What Vercel Tried to Do:
┌─────────────────────────────────────────────────────┐
│ Incoming Request                                    │
│      ↓                                              │
│ Look for build instructions... ❌ NOT FOUND         │
│      ↓                                              │
│ Look for deployment... ❌ DEPLOYMENT_NOT_FOUND      │
│      ↓                                              │
│ ERROR! 🔴                                           │
└─────────────────────────────────────────────────────┘
```

---

### ✅ AFTER (What's Correct)

```
vercel.json Configuration:
┌──────────────────────────────────────────────────────────┐
│ {                                                        │
│   "version": 2,                                          │
│   "builds": [                                            │  ← Correct: Tells Vercel HOW to build
│     {                                                    │
│       "src": "api/handler.go",  ← Points to real file   │
│       "use": "@vercel/go"       ← Use Go builder        │
│     }                                                    │
│   ],                                                     │
│   "routes": [                                            │  ← Correct: Tells Vercel WHERE to route
│     {                                                    │
│       "src": "/api/(.*)",                                │
│       "dest": "/api/handler.go"  ← Correct destination  │
│     }                                                    │
│   ]                                                      │
│ }                                                        │
└──────────────────────────────────────────────────────────┘

What Vercel Does Now:
┌─────────────────────────────────────────────────────┐
│ Step 1: Build Phase                                 │
│   api/handler.go → @vercel/go → Compiled Function   │
│                                                     │
│ Step 2: Deploy Phase                                │
│   Serverless function deployed ✅                    │
│                                                     │
│ Step 3: Request Handling                            │
│   GET /api/stocks                                   │
│      ↓                                              │
│   Route matches: /api/(.*)                          │
│      ↓                                              │
│   Execute: Handler(w, r)                            │
│      ↓                                              │
│   Response: JSON data ✅                             │
└─────────────────────────────────────────────────────┘
```

---

## File Structure Clarity

### Your Project Structure:
```
assessApp/
├── api/
│   └── handler.go          ← BACKEND: This gets deployed to Vercel Project 1
├── frontend/
│   ├── app/
│   ├── components/
│   └── package.json        ← FRONTEND: This directory gets deployed to Vercel Project 2
├── pkg/
│   └── ...                 ← Backend code (shared)
├── main.go                 ← NOT USED in serverless (only for local dev)
├── vercel.json             ← Backend deployment config
└── .vercelignore           ← Excludes frontend from backend build
```

---

## Deployment Model Visualization

### Two Separate Vercel Projects:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Your GitHub Repository                          │
│                  art-pro/stockAssessApp                             │
└─────────────┬───────────────────────────────┬───────────────────────┘
              │                               │
              ↓                               ↓
┌─────────────────────────────┐   ┌──────────────────────────────┐
│   Vercel Project 1          │   │   Vercel Project 2           │
│   (Backend - Go)            │   │   (Frontend - Next.js)       │
│                             │   │                              │
│   Root: ./                  │   │   Root: ./frontend           │
│   Builds: api/handler.go    │   │   Framework: Next.js         │
│   Runtime: @vercel/go       │   │   Auto-detected              │
│                             │   │                              │
│   URL:                      │   │   URL:                       │
│   your-backend.vercel.app   │   │   your-app.vercel.app        │
│                             │   │                              │
│   Serves: /api/*            │   │   Serves: HTML/JS/CSS        │
└─────────────────────────────┘   └──────────────────────────────┘
              │                               │
              │                               │
              │      API calls via            │
              │      NEXT_PUBLIC_API_URL      │
              └───────────────────────────────┘
```

---

## What Each Part Does

### `builds` Section:
```json
"builds": [
  {
    "src": "api/handler.go",    // File to build
    "use": "@vercel/go"          // Builder to use
  }
]
```

**Purpose**: Tells Vercel:
1. Find the file at `api/handler.go`
2. Compile it using the Go runtime
3. Create a serverless function from it

**Without this**: Vercel doesn't know what to build → DEPLOYMENT_NOT_FOUND

---

### `routes` Section:
```json
"routes": [
  {
    "src": "/api/(.*)",         // Match any URL starting with /api/
    "dest": "/api/handler.go"   // Send it to this function
  }
]
```

**Purpose**: Tells Vercel:
1. When a request comes to `/api/anything`
2. Route it to the compiled `handler.go` function
3. Let the Gin router handle sub-paths

**Without this**: Requests wouldn't reach your handler

---

## The Fix in Plain English

### Before:
> "Vercel, please deploy... something? I'm not telling you what to build or how to build it. Just make it work!"

**Result**: ❌ DEPLOYMENT_NOT_FOUND

### After:
> "Vercel, please build my Go file at `api/handler.go` using the `@vercel/go` builder. Then, route all `/api/*` requests to that compiled function."

**Result**: ✅ Successful deployment

---

## Critical Concepts

### 1. **Vercel Doesn't Auto-Detect Go Projects**
Unlike Next.js, Go projects need explicit configuration:
- Where is the entry point? (`builds.src`)
- What builder to use? (`builds.use`)
- How to route requests? (`routes`)

### 2. **File Paths Must Be Exact**
```
❌ "api/handler"       (missing .go)
❌ "api/index.go"      (wrong filename)
✅ "api/handler.go"    (correct!)
```

### 3. **Builds vs Routes vs Rewrites**

| Feature   | Purpose                          | Use Case                    |
|-----------|----------------------------------|-----------------------------|
| `builds`  | Compile source → serverless func | Go, Rust, Python functions  |
| `routes`  | Map URLs → functions/files       | API routing                 |
| `rewrites`| Proxy requests to other URLs     | External APIs, monorepos    |

**Your case**: Needed `builds` + `routes`, not `rewrites`

### 4. **Package Name Doesn't Matter (Much)**
```go
package handler  // ✅ Works
package main     // ✅ Also works
package api      // ✅ Also works
```

What matters: The function signature
```go
func Handler(w http.ResponseWriter, r *http.Request)
```

---

## Testing Your Fix

### 1. Commit and Push
```bash
git status
# Should show: vercel.json, .vercelignore, updated docs

git add vercel.json .vercelignore *.md
git commit -m "fix: Update Vercel configuration for Go backend deployment"
git push origin main
```

### 2. Watch Deployment
Go to Vercel dashboard → Should see:
- ✅ Building: Compiling Go code
- ✅ Function logs appear
- ✅ Deployment succeeds

### 3. Test API
```bash
# Should return 401 (needs auth) - but that means API is working!
curl https://your-backend.vercel.app/api/stocks

# Expected response:
{"error": "Unauthorized"}  ← This is GOOD! API is working.
```

### 4. Test Frontend
1. Visit frontend URL
2. Login with credentials
3. Try adding a stock
4. Check if backend API calls work

---

## Future Reference Checklist

When deploying Go to Vercel, always ensure:

- [ ] `vercel.json` has `builds` section
- [ ] `builds.src` points to your Go handler file
- [ ] `builds.use` is `@vercel/go`
- [ ] `routes` map your URLs to the handler
- [ ] File paths are exact (include `.go`)
- [ ] Handler function is exported: `func Handler(w, r)`
- [ ] `.vercelignore` excludes unnecessary files
- [ ] Environment variables are set in Vercel dashboard

---

## Troubleshooting Quick Reference

| Error | Likely Cause | Fix |
|-------|--------------|-----|
| DEPLOYMENT_NOT_FOUND | No builds config | Add `builds` section |
| Could not find function | Wrong file path | Check `builds.src` path |
| 404 for /api/* | Missing routes | Add `routes` section |
| 500 Server Error | Missing env vars | Check Vercel dashboard |
| Build failed | Go syntax error | Check function logs |

---

**Status**: 🎉 Your configuration is now correct and ready to deploy!

