# Deploying to Vercel (Backend + Frontend)

This guide covers deploying **both** the Go backend and Next.js frontend to Vercel.

## Important Changes Made

The backend has been restructured to work with **Vercel's serverless functions**:
- ✅ Created `api/handler.go` - Serverless handler
- ✅ Updated `vercel.json` - Serverless routing with correct builds configuration
- ✅ Added `.vercelignore` - Exclude frontend from backend build
- ✅ Disabled built-in scheduler (use Vercel Cron instead)

## ⚠️ Serverless Limitations

1. **Database**: SQLite will reset on each deployment. Use **Vercel Postgres** for production.
2. **Scheduler**: Built-in Go scheduler disabled. Use Vercel Cron Jobs (configured in `vercel.json`).
3. **Stateless**: Each request may use a different function instance.

---

## Step 1: Deploy Backend

### 1.1 Push Code to GitHub

```bash
cd /Users/jetbrains/GolandProjects/assessApp
git add .
git commit -m "Add Vercel serverless support"
git push origin main
```

### 1.2 Create Backend Project on Vercel

1. Go to https://vercel.com/new
2. Import your GitHub repository: `art-pro/stockAssessApp`
3. Configure as follows:

**Project Name:** `stock-assess-backend` (or your choice)

**Framework Preset:** `Other`

**Root Directory:** `./` (leave as root)

**Build Settings:**
- Build Command: (leave empty/override off)
- Output Directory: (leave empty/override off)
- Install Command: (leave empty/override off)

### 1.3 Add Environment Variables

Click "Environment Variables" and add:

```
ADMIN_USERNAME = artpro
ADMIN_PASSWORD = your-secure-password-123
JWT_SECRET = your-generated-32-char-secret
DATABASE_PATH = /tmp/stocks.db
PORT = 8080
APP_ENV = production
FRONTEND_URL = https://your-frontend.vercel.app

# Optional but recommended:
ALPHA_VANTAGE_API_KEY = your-key
XAI_API_KEY = your-key
EXCHANGE_RATES_API_KEY = your-key
SENDGRID_API_KEY = your-key
ALERT_EMAIL_FROM = alerts@yourdomain.com
ALERT_EMAIL_TO = your@email.com
ENABLE_SCHEDULER = false
```

**Generate JWT_SECRET:**
```bash
openssl rand -base64 32
```

### 1.4 Deploy

Click **"Deploy"**

Wait for deployment to complete (2-3 minutes).

**Copy the deployment URL** (e.g., `https://stock-assess-backend.vercel.app`)

---

## Step 2: Deploy Frontend

### 2.1 Create Frontend Project on Vercel

1. Go to https://vercel.com/new (again)
2. Import **the same repository**: `art-pro/stockAssessApp`
3. Configure as follows:

**Project Name:** `stock-assess-frontend` (or your choice)

**Framework Preset:** `Next.js` (should auto-detect)

**Root Directory:** `./frontend` ⚠️ **IMPORTANT: Set this to frontend**

**Build Settings:**
- Build Command: `npm run build` (auto)
- Output Directory: `.next` (auto)
- Install Command: `npm install` (auto)

### 2.2 Add Environment Variable

Click "Environment Variables" and add:

```
NEXT_PUBLIC_API_URL = https://your-backend-url.vercel.app/api
```

**Replace** `your-backend-url` with the actual backend URL from Step 1.4.

### 2.3 Deploy

Click **"Deploy"**

Wait for deployment to complete (2-3 minutes).

---

## Step 3: Test the Application

1. Open your frontend URL (e.g., `https://stock-assess-frontend.vercel.app`)
2. Login with:
   - Username: `artpro`
   - Password: (what you set in backend env vars)
3. Add a test stock
4. Click "Update All Prices"
5. Verify everything works

---

## Step 4: Set Up Postgres (Recommended)

SQLite data will be **lost on every deployment**. Migrate to Postgres:

### 4.1 Create Vercel Postgres Database

1. Go to https://vercel.com/dashboard
2. Select your **backend project**
3. Go to "Storage" tab
4. Click "Create Database"
5. Choose "Postgres"
6. Click "Create"

### 4.2 Update Backend Environment Variables

Vercel automatically adds these variables to your backend project:
- `POSTGRES_URL`
- `POSTGRES_PRISMA_URL`
- `POSTGRES_URL_NON_POOLING`

**Update these variables:**
```
DATABASE_URL = (use the POSTGRES_URL value)
DATABASE_PATH = (remove this - not needed for Postgres)
```

### 4.3 Update Code to Support Postgres

In `internal/database/database.go`, add Postgres support:

```go
import (
    "gorm.io/driver/postgres"
    "gorm.io/driver/sqlite"
)

func InitDB(dbPath string) (*gorm.DB, error) {
    var db *gorm.DB
    var err error
    
    // Check if DATABASE_URL exists (Postgres)
    if dbURL := os.Getenv("DATABASE_URL"); dbURL != "" {
        db, err = gorm.Open(postgres.Open(dbURL), &gorm.Config{
            Logger: logger.Default.LogMode(logger.Info),
        })
    } else {
        // Fallback to SQLite
        dir := filepath.Dir(dbPath)
        if err := os.MkdirAll(dir, 0755); err != nil {
            return nil, fmt.Errorf("failed to create database directory: %w", err)
        }
        db, err = gorm.Open(sqlite.Open(dbPath), &gorm.Config{
            Logger: logger.Default.LogMode(logger.Info),
        })
    }
    
    if err != nil {
        return nil, fmt.Errorf("failed to connect to database: %w", err)
    }
    
    // ... rest of function
}
```

Add to `go.mod`:
```bash
go get gorm.io/driver/postgres
```

Commit and push - Vercel will auto-redeploy.

---

## Step 5: Set Up Automated Updates (Optional)

The `vercel.json` includes a cron job that runs daily at midnight UTC:

```json
"crons": [
  {
    "path": "/api/stocks/update-all",
    "schedule": "0 0 * * *"
  }
]
```

**Note:** Vercel Cron is only available on **Pro plans** ($20/month).

### Free Alternative: Manual Updates
- Click "Update All Prices" button in the dashboard daily
- Or use a free external cron service like https://cron-job.org to ping your update endpoint

---

## Deployment Configuration Summary

### Backend Project:
```
Repository: art-pro/stockAssessApp
Root: ./
Framework: Other
Build: api/index.go (serverless)
Environment: 10+ variables (see above)
```

### Frontend Project:
```
Repository: art-pro/stockAssessApp (same repo)
Root: ./frontend
Framework: Next.js
Environment: NEXT_PUBLIC_API_URL
```

---

## Common Issues & Fixes

### Backend: "Could not find exported function"
✅ **Fixed!** We created `api/index.go` with proper `Handler` function.

### Frontend: API Connection Failed
- Verify `NEXT_PUBLIC_API_URL` is set correctly
- Check backend is deployed and accessible
- Must include `/api` at the end of the URL

### Database Resets on Deploy
- Expected with SQLite
- Migrate to Vercel Postgres (see Step 4)

### 500 Internal Server Error
- Check Vercel logs: Project → Deployments → Click deployment → View Function Logs
- Verify all environment variables are set
- Check database connection

### CORS Errors
- Backend is configured for CORS
- Ensure `FRONTEND_URL` environment variable matches your frontend URL
- May need to redeploy backend after frontend is deployed

---

## Monitoring & Logs

### View Backend Logs:
1. Go to https://vercel.com/dashboard
2. Select backend project
3. Deployments → Click latest → View Function Logs

### View Frontend Logs:
1. Select frontend project
2. Deployments → Click latest → Build Logs / Runtime Logs

---

## Updating the Application

### Code Changes:
```bash
git add .
git commit -m "Your changes"
git push origin main
```

Both backend and frontend will **auto-deploy** on push to main branch.

### Environment Variable Changes:
1. Go to Project Settings → Environment Variables
2. Update values
3. Redeploy (Deployments → ⋯ → Redeploy)

---

## Custom Domains (Optional)

### Add Custom Domain:
1. Project Settings → Domains
2. Add your domain (e.g., `api.yourdomain.com` for backend)
3. Add your domain (e.g., `app.yourdomain.com` for frontend)
4. Follow DNS configuration instructions
5. SSL automatically provisioned

---

## Cost Considerations

### Vercel Free Tier Includes:
- ✅ Unlimited deployments
- ✅ 100 GB bandwidth/month
- ✅ Serverless function executions
- ✅ SSL certificates
- ✅ Preview deployments

### Vercel Pro ($20/month) Adds:
- ✅ Vercel Postgres (free tier: 60 hours compute/month)
- ✅ Cron Jobs
- ✅ More bandwidth
- ✅ Priority support

### Recommended:
- **Start with Free tier** + manual updates
- **Upgrade to Pro** when you need automated updates and persistent database

---

## Next Steps

1. ✅ Deploy backend
2. ✅ Deploy frontend
3. ✅ Test the application
4. ⚠️ Set up Postgres (when ready for production)
5. 🎉 Use your app!

---

## Getting Help

- **Vercel Docs:** https://vercel.com/docs
- **Go on Vercel:** https://vercel.com/docs/functions/serverless-functions/runtimes/go
- **Vercel Support:** https://vercel.com/support

---

**You're now ready to deploy! 🚀**

Both backend and frontend will be on Vercel, fully managed and auto-scaling.

