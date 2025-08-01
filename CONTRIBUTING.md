# Contributing to DoraKit

Thank you for your interest in contributing to DoraKit! This document provides guidelines for contributing to this project.

## 🤝 How to Contribute

### 1. Fork the Repository
1. Go to [DoraKit GitHub repository](https://github.com/KSK9820/DoraKit)
2. Click the "Fork" button in the top right corner
3. Clone your forked repository locally

### 2. Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 3. Make Your Changes
- Follow the existing code style and conventions
- Add tests for new functionality
- Update documentation as needed
- Ensure all tests pass

### 4. Commit Your Changes
```bash
git add .
git commit -m "feat: add new macro for custom JSON encoding"
```

### 5. Push and Create a Pull Request
```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## 📋 Development Setup

### Prerequisites
- Swift 6.0+
- Xcode 15.0+ (for development)
- macOS 10.15+

### Building the Project
```bash
# Clone the repository
git clone https://github.com/KSK9820/DoraKit.git
cd DoraKit

# Build the project
swift build

# Run tests
swift test
```

### Running Tests
```bash
swift test
```

## 📝 Code Style Guidelines

### Swift Code Style
- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comprehensive documentation comments
- Keep functions focused and concise

### Macro Implementation
- Use descriptive error messages
- Add proper validation for macro arguments
- Include comprehensive test cases
- Document all constraints and limitations

### Documentation
- Update README.md for new features
- Add examples in both Korean and English
- Update CHANGELOG.md for significant changes

## 🧪 Testing Guidelines

### Test Coverage
- Write tests for all new functionality
- Include positive and negative test cases
- Test edge cases and error conditions
- Ensure tests are descriptive and readable

### Test Structure
```swift
func test_featureName_expectedBehavior_shouldSucceed() {
    // Test implementation
}
```

## 🐛 Bug Reports

When reporting bugs, please include:
- Swift version
- Platform (macOS, iOS, etc.)
- Steps to reproduce
- Expected vs actual behavior
- Code example if applicable

## 💡 Feature Requests

When suggesting features, please include:
- Use case description
- Expected API design
- Benefits and impact
- Implementation considerations

## 📄 Pull Request Guidelines

### Before Submitting
- [ ] All tests pass
- [ ] Code follows style guidelines
- [ ] Documentation is updated
- [ ] CHANGELOG.md is updated
- [ ] No breaking changes (or clearly documented)

### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Breaking change

## Testing
- [ ] Tests added/updated
- [ ] All tests pass

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
```

## 📞 Questions?

If you have questions about contributing, please:
1. Check existing issues and discussions
2. Create a new issue with the "question" label
3. Reach out to maintainers

Thank you for contributing to DoraKit! 🚀 