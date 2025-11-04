# Quick Setup Guide

Get the Stock Portfolio Tracker running in minutes!

## Prerequisites Check

Before starting, ensure you have:
- [ ] Go 1.21+ installed (`go version`)
- [ ] Node.js 18+ installed (`node --version`)
- [ ] Git installed (`git --version`)
- [ ] A code editor (VS Code, GoLand, etc.)

## 5-Minute Local Setup

### Step 1: Get the Code
```bash
# Clone the repository
git clone <repository-url>
cd assessApp
```

### Step 2: Backend Setup
```bash
# Copy environment template
cp .env.example .env

# Edit .env and set at minimum:
# ADMIN_PASSWORD=YourSecurePassword123
# JWT_SECRET=your-random-secret-key-here

# Install Go dependencies
go mod download

# Start the backend
go run main.go
```

The backend will start on `http://localhost:8080`. Leave this terminal open.

### Step 3: Frontend Setup (New Terminal)
```bash
# Navigate to frontend
cd frontend

# Install dependencies
npm install

# Create frontend environment file
echo "NEXT_PUBLIC_API_URL=http://localhost:8080/api" > .env.local

# Start the frontend
npm run dev
```

The frontend will open at `http://localhost:3000`

### Step 4: Login and Test
1. Open browser to `http://localhost:3000`
2. Login with:
   - Username: `artpro`
   - Password: (what you set in `.env`)
3. Change your password in Settings
4. Add your first stock!

## Using Make (Alternative)

If you have `make` installed:

```bash
# One-time setup
make dev

# Then run (in separate terminals):
make run-backend
make run-frontend
```

## Common Issues & Fixes

### "Port already in use"
```bash
# Backend (port 8080)
lsof -ti:8080 | xargs kill -9

# Frontend (port 3000)
lsof -ti:3000 | xargs kill -9
```

### "Database locked"
```bash
# Stop the backend and delete the database
rm data/stocks.db

# Restart backend - it will recreate the database
go run main.go
```

### "Module not found" errors (Go)
```bash
go mod tidy
go mod download
```

### "Package not found" errors (npm)
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

## Development Workflow

### Making Changes

**Backend (Go)**:
1. Edit files in `internal/`
2. Restart: `Ctrl+C` and `go run main.go`
3. Or use air for auto-reload: `go install github.com/cosmtrek/air@latest && air`

**Frontend (React/Next.js)**:
- Changes auto-reload (Hot Module Replacement)
- No restart needed

### Adding a New Stock

1. Click "Add Stock" button
2. Fill in required fields:
   - Ticker (e.g., AAPL)
   - Company Name (e.g., Apple Inc.)
   - Sector (e.g., Technology)
3. Optional fields:
   - Shares owned
   - Average entry price
   - Update frequency
4. Click "Add Stock"
5. System automatically fetches prices and calculates metrics

### Understanding the Calculations

**Expected Value (EV)**:
- Shows if the stock is attractive
- EV > 7%: Consider buying
- 0% < EV < 7%: Hold
- EV < 0%: Consider selling

**Kelly Fraction**:
- Optimal position size based on math
- ½-Kelly: More conservative (capped at 15%)
- Use this to size positions

**Assessment**:
- System recommendation based on EV
- Green (Add), Gray (Hold), Orange (Trim), Red (Sell)

## API Keys (Optional but Recommended)

### Alpha Vantage (Free Stock Prices)
1. Sign up: [alphavantage.co/support/#api-key](https://www.alphavantage.co/support/#api-key)
2. Get free API key
3. Add to `.env`: `ALPHA_VANTAGE_API_KEY=your_key`
4. Restart backend

Without this, mock prices will be used.

### Exchange Rates (Free Currency Conversion)
1. Sign up: [exchangeratesapi.io](https://exchangeratesapi.io)
2. Get free API key
3. Add to `.env`: `EXCHANGE_RATES_API_KEY=your_key`

### Grok/xAI (Advanced Calculations)
1. Sign up: [x.ai](https://x.ai) (when available)
2. Get API key
3. Add to `.env`: `XAI_API_KEY=your_key`

Without this, the system uses built-in calculations (still works well).

### SendGrid (Email Alerts)
1. Sign up: [sendgrid.com](https://sendgrid.com)
2. Create API key
3. Verify sender email
4. Add to `.env`:
   ```
   SENDGRID_API_KEY=your_key
   ALERT_EMAIL_FROM=alerts@yourdomain.com
   ALERT_EMAIL_TO=your@email.com
   ```

## Project Structure Overview

```
assessApp/
├── main.go              # Start here - main entry point
├── internal/
│   ├── api/            # REST API endpoints
│   ├── models/         # Database models (Stock, User, etc.)
│   ├── services/       # Business logic & calculations
│   └── scheduler/      # Auto-update jobs
├── frontend/
│   ├── app/           # Next.js pages
│   ├── components/    # React components
│   └── lib/           # API client & utilities
└── data/              # SQLite database (auto-created)
```

## Next Steps

1. **Add Stocks**: Start by adding 3-5 stocks you're interested in
2. **Review Metrics**: Understand the EV and Kelly calculations
3. **Set Update Frequency**: Configure daily/weekly updates in Settings
4. **Enable Alerts**: Set up email notifications for EV changes
5. **Export Data**: Try exporting to CSV for backup

## Learning Resources

### Investment Strategy
- Kelly Criterion: [Wikipedia](https://en.wikipedia.org/wiki/Kelly_criterion)
- Expected Value: Understanding probabilistic returns
- Portfolio Theory: Diversification and risk management

### Technologies
- **Go**: [tour.golang.org](https://tour.golang.org)
- **React**: [react.dev](https://react.dev)
- **Next.js**: [nextjs.org/learn](https://nextjs.org/learn)
- **Tailwind CSS**: [tailwindcss.com/docs](https://tailwindcss.com/docs)

## Getting Help

### Check Logs

**Backend errors**:
- Check terminal where `go run main.go` is running
- Logs show API calls, errors, and database operations

**Frontend errors**:
- Open browser DevTools (F12)
- Check Console tab for errors
- Network tab shows API requests

### Debug Mode

Enable detailed logging:
```bash
# In .env
APP_ENV=development
```

### Reset Everything

If things get messy:
```bash
# Stop both servers (Ctrl+C)

# Delete database
rm data/stocks.db

# Clear frontend cache
cd frontend
rm -rf .next

# Restart
go run main.go  # Terminal 1
npm run dev     # Terminal 2 (in frontend/)
```

## Pro Tips

1. **Use Test Data First**: Add a few test stocks before real portfolio
2. **Backup Regularly**: Export to CSV frequently
3. **Update Often**: Click "Update All Prices" daily for fresh data
4. **Monitor Sectors**: Keep diversified (use pie chart)
5. **Set Alerts**: Get notified of major EV changes
6. **Review History**: Check stock detail pages for trends

## What's Next?

After local setup works:
1. Review the full [README.md](README.md) for detailed docs
2. Check [DEPLOYMENT.md](DEPLOYMENT.md) for cloud hosting
3. Customize for your investment strategy
4. Consider adding more sectors/stocks
5. Share feedback and contribute!

---

**Happy tracking! 📈**

Need help? Check logs, review docs, or consult the troubleshooting section in README.md.

