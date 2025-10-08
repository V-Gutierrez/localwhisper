# Contributing to LocalWhisper

First off, thank you for considering contributing to LocalWhisper! It's people like you that make LocalWhisper such a great tool.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** (code snippets, screenshots, etc.)
- **Describe the behavior you observed** and what you expected
- **Include your environment details** (OS, Python version, etc.)

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) when creating issues.

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful** to most users
- **List any similar features** in other tools if applicable

Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) when suggesting features.

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the code style** of the project
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Write clear commit messages**
6. **Submit a pull request** with a clear description

#### Pull Request Guidelines:

- Keep pull requests focused on a single feature or fix
- Update the README.md if you add functionality
- Add tests if applicable
- Ensure all tests pass
- Follow the existing code style

## Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/localwhisper.git
   cd localwhisper
   ```

2. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

3. **Make your changes** in a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Test your changes:**
   ```bash
   ./run.sh
   ```

5. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Add your feature description"
   ```

6. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request** on GitHub

## Code Style

- Follow PEP 8 for Python code
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Write descriptive commit messages

## Project Structure

```
localwhisper/
├── app.py                      # Flask backend
├── static/
│   ├── css/style.css          # Styles
│   └── js/app.js              # Frontend logic
├── templates/
│   └── index.html             # UI
├── setup.sh                   # Installation script
├── run.sh                     # Quick run script
├── uninstall.sh               # Uninstall script
└── install_certificates.sh    # SSL certificates installer
```

## Testing

Before submitting a pull request:

1. Test the installation process: `./setup.sh`
2. Test the application: `./run.sh`
3. Test with different audio formats (MP3, WAV, etc.)
4. Test with different Whisper models (tiny, base, small)
5. Test recording functionality
6. Test on both macOS and Linux (if possible)

## Questions?

Feel free to open an issue for any questions about contributing!

## License

By contributing, you agree that your contributions will be licensed under the same [CC BY-NC-SA 4.0 License](LICENSE) that covers the project.

---

Thank you for contributing! 🎉
