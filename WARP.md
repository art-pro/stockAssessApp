# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Commands

### Development

```bash
# Start backend (Terminal 1)
go run main.go

# Start frontend (Terminal 2)
cd frontend && npm run dev

# Or use Make commands
make install        # Install all dependencies
make run-backend    # Run Go backend on :8080
make run-frontend   # Run Next.js frontend on :3000
make dev            # Setup development environment
```

### Testing

```bash
# Backend tests
go test ./...

# Frontend tests
cd frontend && npm test

# Or use Make
make test
```

### Build & Deployment

```bash
# Build for production
make build          # Builds both backend and frontend
go build -o bin/assessapp main.go

# Frontend build
cd frontend && npm run build

# Frontend linting
cd frontend && npm run lint
```

### Database Management

```bash
# Reset database (deletes data/stocks.db, auto-recreates on startup)
rm data/stocks.db && go run main.go

# Database auto-migrates on startup via GORM
```

## Architecture

### Tech Stack

**Backend (Go 1.21+)**
- Gin framework for REST API
- GORM ORM with SQLite (data/stocks.db)
- JWT authentication with bcrypt
- gocron for scheduled tasks
- zerolog for structured logging

**Frontend (Next.js 14)**
- React 18 with TypeScript
- Tailwind CSS styling
- Chart.js for data visualization
- Axios for API communication

### Code Organization

```
internal/
├── api/
│   ├── router.go              # Route definitions, CORS config
│   └── handlers/              # HTTP handlers (auth, stock, portfolio)
├── auth/                      # JWT + bcrypt authentication
├── config/                    # Environment variable loading
├── database/                  # DB initialization, admin user setup
├── middleware/                # Auth middleware
├── models/                    # GORM models (Stock, User, etc.)
├── scheduler/                 # Cron jobs for automated updates
└── services/
    ├── calculations.go        # Kelly Criterion, EV formulas
    ├── external_api.go        # Alpha Vantage, xAI/Grok, FX rates
    └── alerts.go              # Email alerting (SendGrid)

frontend/
├── app/                       # Next.js App Router
│   ├── dashboard/             # Main portfolio view
│   ├── stocks/[id]/           # Stock detail pages
│   ├── login/                 # Auth page
│   └── settings/              # User settings
├── components/                # React components
└── lib/                       # API client, utilities
```

### Key Architectural Patterns

**Investment Logic Flow:**
1. External APIs fetch price/fundamentals → `services/external_api.go`
2. Core calculations applied → `services/calculations.go`
   - EV = (p × Upside%) + ((1-p) × Downside%)
   - Kelly f* = ((b×p) - (1-p)) / b
   - Half-Kelly capped at 15%
3. Assessments generated: Add (EV>7%), Hold, Trim, Sell (EV<-5%)
4. Portfolio metrics aggregated → `calculations.CalculatePortfolioMetrics()`

**API Design:**
- All routes under `/api/*`
- JWT auth via `middleware.AuthMiddleware`
- Public routes: `/api/login`, `/api/health`
- Protected routes require `Authorization: Bearer <token>` header

**Database Models:**
- `Stock` - Core entity with 30+ fields (ticker, prices, metrics)
- `StockHistory` - Time-series data for charts
- `DeletedStock` - Soft delete log with restore capability
- `PortfolioSettings` - Global config (alerts, frequencies)
- All use GORM hooks and auto-migration

**External API Integration:**
- Alpha Vantage: Real-time stock prices
- xAI/Grok: Advanced calculations (fair value, beta, etc.)
- Exchange Rates API: Multi-currency support
- SendGrid: Email alerts
- All fallback to mock data if API keys missing

**Scheduler (gocron):**
- Automated price/calculation updates
- Configurable frequencies: daily, weekly, monthly
- Triggered if `ENABLE_SCHEDULER=true` in `.env`

### Important Constants & Formulas

**Kelly Criterion Implementation** (`services/calculations.go`):
- Maximum position size: 15% (hard cap)
- Uses conservative Half-Kelly: `f* / 2`
- b ratio = Upside% / |Downside%|

**Assessment Thresholds**:
- Add: EV > 7%
- Hold: 0% < EV < 7%
- Trim: -5% < EV < 0%
- Sell: EV < -5%

**Portfolio Targets** (referenced in UI):
- Target volatility: 11-13%
- Min positions for diversification: 10-15
- Typical position size: 3-6%

### Environment Variables

**Required** (`.env` in root):
```
ADMIN_USERNAME=artpro
ADMIN_PASSWORD=<secure-password>
JWT_SECRET=<32-char-min>
```

**Optional** (for full functionality):
```
ALPHA_VANTAGE_API_KEY=<key>
XAI_API_KEY=<key>
EXCHANGE_RATES_API_KEY=<key>
SENDGRID_API_KEY=<key>
ENABLE_SCHEDULER=true
APP_ENV=development|production
PORT=8080
```

**Frontend** (`frontend/.env.local`):
```
NEXT_PUBLIC_API_URL=http://localhost:8080/api
```

### Authentication Flow

1. User POSTs credentials to `/api/login`
2. Backend validates against User model (bcrypt)
3. JWT token issued with 24h expiry
4. Frontend stores token (js-cookie)
5. Token sent in `Authorization` header for protected routes
6. Middleware validates JWT and extracts user

### Common Pitfalls

- **Database path**: SQLite at `data/stocks.db` - create `data/` dir if missing
- **CORS**: Frontend URL must be in `corsConfig.AllowOrigins` (router.go)
- **Port conflicts**: Backend :8080, Frontend :3000 must be available
- **API fallbacks**: Mock data used when external API keys not configured
- **JWT secret**: Must be set before first run (no default)
- **Auto-migration**: GORM migrates on every startup (safe, idempotent)

### Testing Approach

- No test framework specified - check README or Makefile before running tests
- Backend: Standard Go testing with `go test ./...`
- Frontend: Package.json defines `npm test` script
- Database: Can reset by deleting `data/stocks.db`

### Deployment (Vercel)

- `vercel.json` configured for Go serverless functions
- Backend routes to `/api/*`
- Frontend deploys separately
- Set environment variables in Vercel dashboard
- Use `make deploy` or `vercel --prod`
