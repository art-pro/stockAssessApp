# Deployment Guide

This guide covers deploying the Stock Portfolio Tracker to Vercel.

## Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
2. **Vercel CLI**: Install globally
   ```bash
   npm install -g vercel
   ```
3. **Git Repository**: Code should be in a Git repository (GitHub, GitLab, or Bitbucket)

## Option 1: Deploy via Vercel CLI (Recommended)

### Backend Deployment

1. **Login to Vercel**:
   ```bash
   vercel login
   ```

2. **Configure Backend**:
   Create `vercel.json` in project root (already included):
   ```json
   {
     "version": 2,
     "builds": [
       {
         "src": "main.go",
         "use": "@vercel/go"
       }
     ],
     "routes": [
       {
         "src": "/api/(.*)",
         "dest": "main.go"
       }
     ]
   }
   ```

3. **Deploy Backend**:
   ```bash
   vercel
   ```
   
   Follow prompts:
   - Link to existing project or create new
   - Set project name (e.g., `assessapp-backend`)
   - Choose defaults for other options

4. **Set Environment Variables**:
   Go to Vercel Dashboard → Your Project → Settings → Environment Variables
   
   Add all variables from `.env.example`:
   ```
   ADMIN_USERNAME=artpro
   ADMIN_PASSWORD=your-secure-password
   JWT_SECRET=your-jwt-secret
   DATABASE_PATH=/tmp/stocks.db
   ALPHA_VANTAGE_API_KEY=your-key
   XAI_API_KEY=your-key
   EXCHANGE_RATES_API_KEY=your-key
   SENDGRID_API_KEY=your-key
   ALERT_EMAIL_FROM=alerts@yourdomain.com
   ALERT_EMAIL_TO=admin@yourdomain.com
   ENABLE_SCHEDULER=true
   ```

5. **Deploy to Production**:
   ```bash
   vercel --prod
   ```
   
   Note your backend URL (e.g., `https://assessapp-backend.vercel.app`)

### Frontend Deployment

1. **Navigate to Frontend**:
   ```bash
   cd frontend
   ```

2. **Configure Frontend**:
   Update `frontend/.env.local`:
   ```env
   NEXT_PUBLIC_API_URL=https://your-backend-url.vercel.app/api
   ```

3. **Deploy Frontend**:
   ```bash
   vercel
   ```
   
   Follow prompts similar to backend deployment

4. **Set Environment Variable in Vercel**:
   - Dashboard → Frontend Project → Settings → Environment Variables
   - Add: `NEXT_PUBLIC_API_URL` with your backend URL

5. **Deploy to Production**:
   ```bash
   vercel --prod
   ```

## Option 2: Deploy via Vercel Dashboard (Git Integration)

### Setup

1. **Push to Git**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **Import to Vercel**:
   - Go to [vercel.com/dashboard](https://vercel.com/dashboard)
   - Click "Add New..." → "Project"
   - Import your Git repository

### Backend Configuration

1. **Project Settings**:
   - Framework Preset: Other
   - Root Directory: `./`
   - Build Command: (leave empty for Go)
   - Output Directory: (leave empty)

2. **Add Environment Variables** (as listed above)

3. **Deploy**: Click "Deploy"

### Frontend Configuration

1. **Create New Project** for frontend:
   - Import same repository
   - Framework Preset: Next.js
   - Root Directory: `./frontend`
   - Build Command: `npm run build`
   - Output Directory: `.next`

2. **Add Environment Variable**:
   - `NEXT_PUBLIC_API_URL`: Your backend URL

3. **Deploy**: Click "Deploy"

## Database Considerations

### Development (SQLite)
- SQLite works for development and small deployments
- Files are ephemeral on Vercel (reset on each deployment)
- Not recommended for production

### Production (Recommended: Vercel Postgres)

1. **Create Postgres Database**:
   - Vercel Dashboard → Storage → Create Database
   - Choose Postgres
   - Note connection string

2. **Update Backend**:
   - Install Postgres driver: `go get gorm.io/driver/postgres`
   - Update `internal/database/database.go` to support Postgres:
   
   ```go
   import "gorm.io/driver/postgres"
   
   // In InitDB function, check DATABASE_URL
   if dbURL := os.Getenv("DATABASE_URL"); dbURL != "" {
       db, err = gorm.Open(postgres.Open(dbURL), &gorm.Config{...})
   } else {
       // Use SQLite for local dev
       db, err = gorm.Open(sqlite.Open(dbPath), &gorm.Config{...})
   }
   ```

3. **Set Environment Variable**:
   - Add `DATABASE_URL` in Vercel with Postgres connection string

## Post-Deployment Steps

### 1. Test the Application

Visit your frontend URL and:
- Login with admin credentials
- Add a test stock
- Verify calculations work
- Test update functionality

### 2. Configure Custom Domain (Optional)

1. **Add Domain**:
   - Vercel Dashboard → Project → Settings → Domains
   - Add your custom domain
   - Follow DNS configuration instructions

2. **SSL Certificate**: Automatically provisioned by Vercel

### 3. Monitor Logs

- **Backend Logs**: Dashboard → Your Backend Project → Deployments → View Function Logs
- **Frontend Logs**: Dashboard → Your Frontend Project → Deployments → View Build Logs

### 4. Set Up Alerts

Configure SendGrid for email alerts:
1. Create SendGrid account at [sendgrid.com](https://sendgrid.com)
2. Create API key
3. Add to Vercel environment variables
4. Verify sender email in SendGrid

## Continuous Deployment

Once connected to Git:
1. **Push to main branch** → Auto-deploys to production
2. **Push to other branches** → Creates preview deployments
3. **Pull requests** → Automatic preview URLs

## Scaling Considerations

### Performance
- **Serverless Functions**: Auto-scale based on traffic
- **Edge Network**: Global CDN for frontend
- **API Rate Limiting**: Implement in middleware for external APIs

### Database
- **Migrate to Postgres** for production workloads
- **Connection Pooling**: Configure in GORM
- **Backups**: Use Vercel Postgres automatic backups

### Monitoring
- **Vercel Analytics**: Enable in dashboard
- **Custom Logging**: Use structured logging (zerolog)
- **Error Tracking**: Consider Sentry integration

## Troubleshooting

### Backend Issues

**Function Timeout**:
```json
// Add to vercel.json
{
  "functions": {
    "api/**/*.go": {
      "maxDuration": 60
    }
  }
}
```

**Environment Variables Not Loading**:
- Verify variables are set in Vercel dashboard
- Redeploy after adding variables
- Check variable scope (Production/Preview/Development)

### Frontend Issues

**API Connection Failed**:
- Verify `NEXT_PUBLIC_API_URL` is correct
- Check CORS configuration in backend
- Ensure backend is deployed and accessible

**Build Failures**:
- Check build logs in Vercel dashboard
- Verify all dependencies are in `package.json`
- Test build locally: `npm run build`

### Database Issues

**SQLite Resets on Deploy**:
- Expected behavior with ephemeral filesystem
- Migrate to Postgres for persistence

**Connection Errors**:
- Verify `DATABASE_URL` format
- Check Postgres database is running
- Review connection pool settings

## Security Checklist

- [ ] Change default admin password
- [ ] Use strong JWT secret (32+ characters)
- [ ] Enable HTTPS (automatic on Vercel)
- [ ] Secure API keys in environment variables
- [ ] Enable CORS only for your frontend domain
- [ ] Set up rate limiting
- [ ] Configure SendGrid sender authentication
- [ ] Review and limit function permissions

## Maintenance

### Regular Tasks
1. **Update Dependencies**:
   ```bash
   go get -u ./...
   cd frontend && npm update
   ```

2. **Review Logs**: Check for errors weekly

3. **Database Backups**: Set up automated backups (if using Postgres)

4. **Monitor API Usage**: Track external API quotas

### Cost Optimization
- **Vercel Free Tier**: Suitable for personal use
- **Monitor Usage**: Check dashboard for bandwidth/function invocations
- **Optimize API Calls**: Cache responses where possible
- **Consider Pro Tier**: If exceeding free tier limits

## Support Resources

- **Vercel Documentation**: [vercel.com/docs](https://vercel.com/docs)
- **Go on Vercel**: [vercel.com/docs/runtimes#official-runtimes/go](https://vercel.com/docs/runtimes#official-runtimes/go)
- **Next.js on Vercel**: [vercel.com/docs/frameworks/nextjs](https://vercel.com/docs/frameworks/nextjs)
- **Vercel Community**: [github.com/vercel/vercel/discussions](https://github.com/vercel/vercel/discussions)

---

**Deployment Checklist**:
- [ ] Backend deployed and accessible
- [ ] Frontend deployed with correct API URL
- [ ] Environment variables configured
- [ ] Database set up (Postgres for production)
- [ ] Admin user created and password changed
- [ ] Email alerts configured (optional)
- [ ] Custom domain configured (optional)
- [ ] SSL certificate active
- [ ] Test all major features
- [ ] Monitor logs for errors

