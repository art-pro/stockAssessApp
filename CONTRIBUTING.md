# Contributing to Stock Portfolio Tracker

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Development Setup

1. Follow the [SETUP_GUIDE.md](SETUP_GUIDE.md) to get the project running locally
2. Create a new branch for your feature: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Code Style

### Go (Backend)
- Follow standard Go conventions: [Effective Go](https://golang.org/doc/effective_go)
- Use `gofmt` for formatting
- Run `go vet` before committing
- Add comments for exported functions
- Keep functions small and focused

### TypeScript/React (Frontend)
- Follow the existing code style
- Use TypeScript types for all props and state
- Use functional components with hooks
- Keep components small and reusable
- Use Tailwind CSS for styling

## Commit Messages

Follow conventional commits format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(dashboard): add export to Excel functionality
fix(auth): resolve JWT token expiration issue
docs(readme): update API documentation
```

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

### Manual Testing Checklist
- [ ] Login/logout works
- [ ] Can add new stocks
- [ ] Can update stock prices
- [ ] Can delete and restore stocks
- [ ] Portfolio summary calculates correctly
- [ ] Charts render properly
- [ ] Mobile responsive
- [ ] Dark mode works

## Pull Request Process

1. **Update Documentation**: Update README.md if needed
2. **Add Tests**: Include tests for new features
3. **Check Linting**: Ensure no linting errors
4. **Update CHANGELOG**: Add entry for your changes
5. **Describe Changes**: Write clear PR description with:
   - What changed
   - Why it changed
   - How to test it

## Feature Requests

Have an idea? Open an issue with:
- Clear description of the feature
- Use case / why it's needed
- Proposed implementation (optional)

## Bug Reports

Found a bug? Open an issue with:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots if applicable
- Environment (OS, browser, etc.)

## Code Review

All submissions require review. We look for:
- Code quality and style
- Test coverage
- Documentation
- Performance impact
- Security considerations

## Areas for Contribution

### High Priority
- [ ] Additional chart types (candlestick, etc.)
- [ ] More external data sources
- [ ] Advanced portfolio analytics
- [ ] Mobile app (React Native)
- [ ] Backtesting functionality

### Medium Priority
- [ ] Multi-user support
- [ ] Watchlists
- [ ] News integration
- [ ] Custom alerts/webhooks
- [ ] PDF reports

### Low Priority
- [ ] Dark/light theme toggle
- [ ] Additional languages
- [ ] Tutorial/onboarding
- [ ] Keyboard shortcuts
- [ ] Accessibility improvements

## Questions?

Feel free to open an issue for any questions about contributing.

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

