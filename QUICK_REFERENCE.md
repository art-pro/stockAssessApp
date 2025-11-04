# Stock Portfolio Tracker - Quick Reference

## 🚀 Quick Commands

### Start Application (Development)
```bash
# Terminal 1 - Backend
cd /Users/jetbrains/GolandProjects/assessApp
go run main.go

# Terminal 2 - Frontend
cd /Users/jetbrains/GolandProjects/assessApp/frontend
npm run dev
```

### Access Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080/api
- **Login**: Username `artpro` + password from `.env`

### Common Make Commands
```bash
make dev        # Setup development environment
make install    # Install all dependencies
make build      # Build for production
make test       # Run tests
make clean      # Clean build artifacts
```

## 📊 Key Formulas

### Expected Value (EV)
```
EV = (p × Upside%) + ((1-p) × Downside%)
```
- **p**: Probability of positive outcome (0.5-0.7 typical)
- **Upside%**: ((Fair Value - Current Price) / Current Price) × 100
- **Downside%**: Estimated loss (negative %)

### Kelly Criterion
```
f* = ((b × p) - (1 - p)) / b
```
- **b**: Upside% / |Downside%| (reward/risk ratio)
- **f***: Optimal position size
- **½-Kelly**: f* / 2 (more conservative, capped at 15%)

### Decision Rules
| EV Range | Action | Description |
|----------|--------|-------------|
| > 7% | **Add** | Strong buy signal |
| 0-7% | **Hold** | Maintain position |
| -5 to 0% | **Trim** | Consider reducing |
| < -5% | **Sell** | Strong sell signal |

## 🎯 Typical Workflow

### Daily Use
1. **Morning**: Click "Update All Prices" button
2. **Review**: Check portfolio summary metrics
3. **Assess**: Look for red/green highlighted stocks
4. **Act**: Follow Assessment column guidance
5. **Monitor**: Check alerts (if enabled)

### Adding New Stock
1. Click "Add Stock" button
2. Enter required fields:
   - Ticker (e.g., AAPL)
   - Company Name
   - Sector
3. Optional: Shares owned, entry price
4. System auto-calculates everything else

### Analyzing a Stock
1. Click company name in table
2. View detailed metrics
3. Check historical chart
4. Review EV trend
5. Compare current price to buy zone

## 📈 Portfolio Targets

### Risk Metrics
- **Target Volatility**: 11-13%
- **Max Position Size**: 15%
- **Typical Position**: 3-6%
- **Min Positions**: 10-15 for diversification

### Sector Allocation Example
- **Technology**: 30-35%
- **Healthcare**: 20-25%
- **Financials**: 15-20%
- **Consumer**: 10-15%
- **Others**: 10-20%

## 🔧 Environment Variables

### Required (.env)
```env
ADMIN_USERNAME=artpro
ADMIN_PASSWORD=your-secure-password
JWT_SECRET=random-secret-key-32-chars-min
```

### Optional (for full features)
```env
ALPHA_VANTAGE_API_KEY=your-key
XAI_API_KEY=your-key
EXCHANGE_RATES_API_KEY=your-key
SENDGRID_API_KEY=your-key
ALERT_EMAIL_FROM=alerts@yourdomain.com
ALERT_EMAIL_TO=your@email.com
```

### Frontend (.env.local)
```env
NEXT_PUBLIC_API_URL=http://localhost:8080/api
```

## 🚨 Troubleshooting

### Backend Won't Start
```bash
# Check port 8080 is free
lsof -ti:8080 | xargs kill -9

# Verify .env exists
ls -la .env

# Check Go version
go version  # Need 1.21+
```

### Frontend Won't Start
```bash
# Check port 3000 is free
lsof -ti:3000 | xargs kill -9

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Verify Node version
node --version  # Need 18+
```

### Database Issues
```bash
# Reset database
rm data/stocks.db

# Restart backend (recreates DB)
go run main.go
```

### API Connection Failed
1. Verify backend is running
2. Check `NEXT_PUBLIC_API_URL` in `frontend/.env.local`
3. Look for errors in backend terminal
4. Check browser DevTools Network tab

## 📋 API Endpoints Reference

### Authentication
- `POST /api/login` - Login
- `POST /api/logout` - Logout
- `POST /api/change-password` - Change password
- `GET /api/me` - Current user info

### Stocks
- `GET /api/stocks` - List all stocks
- `GET /api/stocks/:id` - Get stock details
- `POST /api/stocks` - Create stock
- `PUT /api/stocks/:id` - Update stock
- `DELETE /api/stocks/:id` - Delete stock
- `POST /api/stocks/update-all` - Update all prices
- `GET /api/stocks/:id/history` - Historical data

### Portfolio
- `GET /api/portfolio/summary` - Summary metrics
- `GET /api/portfolio/settings` - Get settings
- `PUT /api/portfolio/settings` - Update settings

### Export/Import
- `GET /api/export/csv` - Export to CSV
- `POST /api/import/csv` - Import from CSV

### Deleted Stocks
- `GET /api/deleted-stocks` - List deleted
- `POST /api/deleted-stocks/:id/restore` - Restore

## 💾 Data Backup

### Manual Backup
```bash
# Database
cp data/stocks.db data/stocks.db.backup

# Or export to CSV via UI
# Dashboard → Export CSV button
```

### Restore Backup
```bash
# From database backup
cp data/stocks.db.backup data/stocks.db

# From CSV
# Dashboard → Import CSV button
```

## 🎨 UI Color Codes

### Assessment Colors
- 🟢 **Green Background**: Add (EV > 7%)
- ⚪ **No Color**: Hold (0% < EV < 7%)
- 🟠 **Orange Background**: Trim (-5% < EV < 0%)
- 🔴 **Red Background**: Sell (EV < -5%)

### Metric Colors
- 🟢 **Green Text**: Positive values
- 🔴 **Red Text**: Negative values
- 🟡 **Yellow Text**: Warning threshold

## 🔑 Keyboard Shortcuts

Currently implemented in browser:
- `Ctrl+F` / `Cmd+F`: Search/filter stocks
- `Tab`: Navigate form fields
- `Enter`: Submit forms
- `Esc`: Close modals

## 📊 Understanding Your Dashboard

### Portfolio Summary Cards
1. **Total Value**: Sum of all positions in USD
2. **Overall EV**: Weighted average expected value
3. **Sharpe Ratio**: Return per unit of risk (higher is better)
4. **Volatility**: Portfolio risk (target: 11-13%)
5. **Kelly Utilization**: Sum of positions vs. suggested

### Stock Table Columns (Left to Right)
1. Ticker symbol
2. Company name (clickable)
3. Sector
4. Current price (local currency)
5. Fair value (analyst target)
6. Upside potential %
7. Expected Value %
8. Kelly f* %
9. ½-Kelly suggested %
10. Shares owned
11. Portfolio weight %
12. Unrealized P&L
13. Assessment
14. Actions (update, delete)

## 🎓 Learning Path

### Beginner
1. Add 2-3 test stocks
2. Click "Update All Prices"
3. Understand EV column
4. Follow Assessment recommendations

### Intermediate
1. View stock detail pages
2. Analyze historical charts
3. Set update frequencies
4. Configure alerts

### Advanced
1. Optimize sector allocation
2. Balance Kelly utilization
3. Fine-tune probability estimates
4. Use CSV export for analysis

## 🚀 Deployment Quick Commands

### Vercel CLI
```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy backend
vercel

# Deploy frontend
cd frontend && vercel

# Deploy to production
vercel --prod
```

### Check Deployment
```bash
# View logs
vercel logs

# List deployments
vercel ls

# Open project in browser
vercel open
```

## 🔒 Security Checklist

- [ ] Change default admin password
- [ ] Use strong JWT secret (32+ chars)
- [ ] Never commit .env files
- [ ] Use HTTPS in production
- [ ] Set secure API keys
- [ ] Enable alerts for anomalies
- [ ] Regular backups
- [ ] Review logs weekly

## 📞 Getting Help

### Check These First
1. This quick reference
2. `README.md` for detailed docs
3. `SETUP_GUIDE.md` for installation
4. `DEPLOYMENT.md` for hosting
5. Error messages in terminal/browser

### Debug Steps
1. Check both terminals for errors
2. Open browser DevTools (F12)
3. Verify environment variables
4. Test API with curl/Postman
5. Check logs in `logs/` (if enabled)

## 🎯 Pro Tips

1. ⚡ **Speed**: Use keyboard to navigate
2. 📊 **Accuracy**: Update prices daily
3. 🎨 **Colors**: Trust the color coding
4. 📈 **Charts**: Use stock detail pages
5. 💾 **Backup**: Export CSV weekly
6. 🔔 **Alerts**: Enable for important stocks
7. 📱 **Mobile**: Works on all devices
8. 🌙 **Dark**: Optimized for low light
9. 🔍 **Search**: Filter large portfolios
10. 📉 **Trends**: Check history before buying

## 📱 Mobile Access

The app is fully responsive:
- All features work on mobile
- Touch-optimized buttons
- Swipeable tables
- Readable charts
- Easy navigation

## ⚙️ Configuration Files

| File | Purpose |
|------|---------|
| `.env` | Backend config |
| `frontend/.env.local` | Frontend config |
| `vercel.json` | Deployment config |
| `go.mod` | Go dependencies |
| `package.json` | Frontend dependencies |

## 🎉 Success Indicators

You're using it well if:
- ✅ Portfolio EV is positive
- ✅ Volatility is 11-13%
- ✅ No position > 15%
- ✅ 10+ positions for diversification
- ✅ Sectors are balanced
- ✅ Mostly "Hold" or "Add" assessments
- ✅ Sharpe ratio > 0.5

## 🔄 Update Frequencies

| Frequency | Use Case |
|-----------|----------|
| **Daily** | Active positions, volatile stocks |
| **Weekly** | Core holdings, stable stocks |
| **Monthly** | Long-term holds, low volatility |

---

**Keep this reference handy!** Bookmark or print for quick access.

For full documentation, see `README.md` or `PROJECT_SUMMARY.md`.

