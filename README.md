# Stock Portfolio Tracker

A comprehensive web application for tracking and analyzing stocks using Kelly Criterion and Expected Value (EV) calculations. Built with Go backend and Next.js frontend, designed for deployment on Vercel.

## Features

### Core Functionality
- **User Authentication**: Secure JWT-based authentication with bcrypt password hashing
- **Stock Management**: Add, edit, delete, and restore stocks with comprehensive tracking
- **Advanced Calculations**: Automatic EV, Kelly Criterion, and risk-adjusted return calculations
- **Portfolio Analytics**: Real-time portfolio summary with sector allocation, Sharpe ratio, and volatility tracking
- **External API Integration**: 
  - Grok/xAI for advanced stock calculations
  - Alpha Vantage for real-time price data
  - Exchange rates API for multi-currency support
- **Automated Updates**: Configurable cron jobs for daily/weekly/monthly updates
- **Email Alerts**: Notifications for significant EV changes and buy zone entries
- **Data Export/Import**: CSV export and import functionality
- **Historical Tracking**: Store and visualize historical performance data

### Investment Strategy Alignment
The application implements a sophisticated investment strategy based on:
- **Probabilistic EV Calculations**: `EV = (p × Upside) + ((1-p) × Downside)`
- **Kelly Criterion Sizing**: `f* = ((b×p) - (1-p)) / b` with conservative ½-Kelly implementation
- **Sector Balancing**: Track and maintain diversification across sectors
- **Risk Management**: Portfolio volatility targeting and maximum drawdown monitoring

## Tech Stack

### Backend
- **Go 1.21+** with Gin framework
- **GORM** for database ORM
- **SQLite** (lightweight, file-based; easily upgradable to Postgres)
- **JWT** for authentication
- **gocron** for scheduled tasks
- **zerolog** for structured logging

### Frontend
- **Next.js 14** with React 18
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **Chart.js** for data visualization
- **Axios** for API calls

### Deployment
- **Vercel** for serverless hosting
- Auto-scaling and HTTPS included
- Environment variable management

## Setup Instructions

### Prerequisites
- Go 1.21 or higher
- Node.js 18+ and npm
- Git

### Backend Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd assessApp
```

2. Install Go dependencies:
```bash
go mod download
```

3. Create environment file:
```bash
cp .env.example .env
```

4. Configure `.env` file with your API keys:
```env
# Required
ADMIN_USERNAME=artpro
ADMIN_PASSWORD=your-secure-password
JWT_SECRET=your-jwt-secret-key

# Optional (use mock data if not provided)
ALPHA_VANTAGE_API_KEY=your-key
XAI_API_KEY=your-key
EXCHANGE_RATES_API_KEY=your-key
SENDGRID_API_KEY=your-key (for email alerts)
```

5. Run the backend:
```bash
go run main.go
```

The API server will start on `http://localhost:8080`

### Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Create environment file:
```bash
echo "NEXT_PUBLIC_API_URL=http://localhost:8080/api" > .env.local
```

4. Run the development server:
```bash
npm run dev
```

The frontend will be available at `http://localhost:3000`

### Default Login Credentials
- **Username**: `artpro`
- **Password**: (as configured in `.env`)

⚠️ **Important**: Change the default password immediately after first login via Settings → Change Password

## Project Structure

```
assessApp/
├── main.go                 # Application entry point
├── go.mod                  # Go dependencies
├── pkg/
│   ├── api/               # API routes and handlers
│   │   ├── router.go
│   │   └── handlers/
│   ├── auth/              # Authentication logic
│   ├── config/            # Configuration management
│   ├── database/          # Database initialization
│   ├── middleware/        # HTTP middleware
│   ├── models/            # Database models
│   ├── scheduler/         # Cron job scheduler
│   └── services/          # Business logic
│       ├── calculations.go   # Investment calculations
│       ├── external_api.go   # External API integrations
│       └── alerts.go         # Alert service
├── frontend/
│   ├── app/               # Next.js app directory
│   │   ├── dashboard/     # Main dashboard
│   │   ├── stocks/[id]/   # Stock detail pages
│   │   ├── log/           # Deleted stocks log
│   │   ├── settings/      # Settings page
│   │   └── login/         # Login page
│   ├── components/        # React components
│   ├── lib/              # Utilities and API client
│   └── package.json
└── data/                 # SQLite database (auto-created)
```

## API Documentation

### Authentication
- `POST /api/login` - User login
- `POST /api/logout` - User logout
- `POST /api/change-password` - Change password
- `GET /api/me` - Get current user

### Stocks
- `GET /api/stocks` - Get all stocks
- `GET /api/stocks/:id` - Get stock by ID
- `POST /api/stocks` - Create new stock
- `PUT /api/stocks/:id` - Update stock
- `DELETE /api/stocks/:id` - Delete stock (soft delete)
- `POST /api/stocks/update-all` - Update all stock prices and calculations
- `POST /api/stocks/:id/update` - Update single stock
- `GET /api/stocks/:id/history` - Get stock historical data

### Portfolio
- `GET /api/portfolio/summary` - Get portfolio summary and metrics
- `GET /api/portfolio/settings` - Get portfolio settings
- `PUT /api/portfolio/settings` - Update portfolio settings

### Export/Import
- `GET /api/export/csv` - Export stocks to CSV
- `POST /api/import/csv` - Import stocks from CSV

### Deleted Stocks Log
- `GET /api/deleted-stocks` - Get all deleted stocks
- `POST /api/deleted-stocks/:id/restore` - Restore deleted stock

## Investment Strategy Formulas

### Expected Value (EV)
```
EV = (p × Upside %) + ((1 - p) × Downside %)
```
Where:
- `p` = Probability of positive outcome (0-1)
- `Upside %` = ((Fair Value - Current Price) / Current Price) × 100
- `Downside %` = Estimated loss percentage (negative)

### Kelly Criterion
```
f* = ((b × p) - (1 - p)) / b
```
Where:
- `b` = Upside % / |Downside %| (reward/risk ratio)
- `f*` = Optimal position size

### Half-Kelly (Conservative)
```
½-Kelly = f* / 2 (capped at 15%)
```

### Decision Rules
- **EV > 7%**: Add/Buy
- **0% < EV < 7%**: Hold
- **-5% < EV < 0%**: Trim
- **EV < -5%**: Sell

## Deployment to Vercel

### Backend Deployment

1. The `vercel.json` is already configured in the root:
```json
{
  "version": 2,
  "builds": [
    {
      "src": "api/handler.go",
      "use": "@vercel/go"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/api/handler.go"
    }
  ]
}
```

2. Install Vercel CLI:
```bash
npm install -g vercel
```

3. Deploy:
```bash
vercel
```

4. Set environment variables in Vercel dashboard

### Frontend Deployment

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Update `NEXT_PUBLIC_API_URL` to your Vercel backend URL

3. Deploy:
```bash
vercel
```

## Configuration

### Environment Variables

#### Backend (`/.env`)
- `APP_ENV`: Application environment (development/production)
- `PORT`: Server port (default: 8080)
- `ADMIN_USERNAME`: Admin username
- `ADMIN_PASSWORD`: Admin password (change in production!)
- `JWT_SECRET`: Secret key for JWT tokens
- `DATABASE_PATH`: SQLite database path
- `ALPHA_VANTAGE_API_KEY`: For stock price data
- `XAI_API_KEY`: For Grok calculations
- `EXCHANGE_RATES_API_KEY`: For currency conversion
- `SENDGRID_API_KEY`: For email alerts
- `ENABLE_SCHEDULER`: Enable/disable cron jobs

#### Frontend (`/frontend/.env.local`)
- `NEXT_PUBLIC_API_URL`: Backend API URL

## Security Features

- ✅ JWT-based authentication with secure token management
- ✅ Password hashing with bcrypt
- ✅ HTTPS enforced (via Vercel)
- ✅ Input sanitization and validation
- ✅ Rate limiting middleware
- ✅ CORS protection
- ✅ SQL injection prevention (GORM)
- ✅ XSS protection (React)

## Performance Optimizations

- Server-side rendering with Next.js
- API response caching
- Efficient database queries with indexing
- Lazy loading for large datasets
- Exponential backoff for external API retries

## Testing

### Backend Tests
```bash
go test ./...
```

### Frontend Tests
```bash
cd frontend
npm test
```

## Troubleshooting

### Database Issues
- Delete `data/stocks.db` to reset database
- Run migrations: `go run main.go` (auto-migrates on startup)

### API Connection Issues
- Verify backend is running on correct port
- Check `NEXT_PUBLIC_API_URL` in frontend `.env.local`
- Ensure CORS is properly configured

### External API Failures
- App falls back to mock data if APIs are unavailable
- Check API key configuration in `.env`
- Monitor rate limits for external services

## Contributing

This is a private portfolio management tool. For issues or feature requests, contact the repository owner.

## License

Private/Proprietary - All rights reserved

## Support

For questions or issues:
- Check logs: Backend console and browser DevTools
- Review API responses for error details
- Verify environment variables are set correctly

---

**Note**: This application handles financial data. Always:
- Use strong passwords
- Keep API keys secure
- Regularly backup your database
- Update dependencies for security patches
- Review calculations before making investment decisions

**Disclaimer**: This tool is for informational purposes only. Always conduct your own research and consult with financial advisors before making investment decisions.

