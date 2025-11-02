# Contributing to Jarvis Core Blueprint

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## 🤝 How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](https://github.com/zeitlospaco/jarvis-core-blueprint/issues)
2. If not, create a new issue with:
   - Clear description of the bug
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Docker version, etc.)
   - Relevant logs or screenshots

### Suggesting Enhancements

1. Open an issue with the `enhancement` label
2. Describe the feature and its benefits
3. Provide examples or mockups if applicable

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test thoroughly
5. Commit with clear messages: `git commit -m "Add: feature description"`
6. Push to your fork: `git push origin feature/your-feature-name`
7. Open a Pull Request

## 📝 Code Style Guidelines

### YAML Files
- Use 2 spaces for indentation
- Add comments for complex configurations
- Keep lines under 100 characters when possible

### Shell Scripts
- Use `#!/bin/bash` shebang
- Add error handling with `set -e`
- Include comments for non-obvious logic
- Make scripts executable: `chmod +x script.sh`

### Documentation
- Use clear, concise language
- Include examples where helpful
- Update README.md for significant changes
- Keep formatting consistent

## 🧪 Testing

Before submitting a PR:

1. **Validate YAML syntax:**
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('your-file.yml'))"
   ```

2. **Test Docker Compose:**
   ```bash
   docker compose config
   docker compose up -d
   docker compose ps
   docker compose down
   ```

3. **Test scripts:**
   ```bash
   shellcheck scripts/*.sh  # Install shellcheck first
   ./scripts/backup-db.sh --dry-run  # If dry-run supported
   ```

4. **Check documentation:**
   - All links work
   - Code examples are correct
   - Instructions are clear

## 🔒 Security

- Never commit secrets or API keys
- Use `.env.example` for documentation
- Report security issues privately to maintainers
- Follow security best practices

## 📋 Commit Message Format

Use clear, descriptive commit messages:

```
Type: Brief description

Detailed explanation if needed
```

**Types:**
- `Add:` New feature or file
- `Fix:` Bug fix
- `Update:` Changes to existing functionality
- `Docs:` Documentation changes
- `Refactor:` Code restructuring
- `Test:` Adding or updating tests
- `Chore:` Maintenance tasks

**Examples:**
- `Add: Redis support for n8n queue mode`
- `Fix: PostgreSQL connection timeout issue`
- `Docs: Update Render deployment instructions`
- `Update: Upgrade n8n to latest version`

## 🌟 Areas for Contribution

### High Priority
- Additional deployment platforms (AWS, GCP, Azure)
- More integration examples
- Enhanced monitoring and alerting
- Performance optimizations
- Multi-language documentation

### Welcome Additions
- Custom n8n nodes
- Python AI agent examples
- Workflow templates
- Testing automation
- CI/CD pipelines

## 📚 Resources

- [n8n Documentation](https://docs.n8n.io)
- [Docker Documentation](https://docs.docker.com)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [LangChain Documentation](https://python.langchain.com)
- [CrewAI Documentation](https://docs.crewai.com)

## 💬 Communication

- GitHub Issues: For bugs and features
- Discussions: For questions and ideas
- Pull Requests: For code contributions

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be recognized in the project README and release notes.

---

Thank you for making Jarvis Core Blueprint better! 🚀
