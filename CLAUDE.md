# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Simple Python 3.13 project managed with `uv`.

## Development Setup

This project uses `uv` as the Python package manager and version manager.

### Installation

```bash
# Install dependencies
uv sync

# Create/activate virtual environment
uv venv
source .venv/bin/activate  # On Unix/macOS
```

### Running the Application

```bash
# Run the main script
uv run main.py

# Or with activated venv
python main.py
```

## Project Configuration

- **Python Version**: 3.13 (specified in `.python-version`)
- **Package Manager**: uv
- **Dependencies**: Managed in `pyproject.toml`

## Adding Dependencies

```bash
# Add a new dependency
uv add <package-name>

# Add a development dependency
uv add --dev <package-name>
```
