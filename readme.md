# Enhanced ZSH Configuration

A powerful and modular ZSH configuration setup focused on productivity and user experience. Works seamlessly across both desktop and server environments.

## ✨ Features

- Fast and responsive shell experience with Powerlevel10k instant prompt
- Comprehensive plugin management using Znap
- Intelligent command completion system
- History management with duplicate prevention
- Package management utilities for Arch Linux systems
- Command suggestion and syntax highlighting
- Directory bookmarking and quick navigation
- Rust development environment support

## 🚀 Installation

### Prerequisites

```bash
# Install required packages
# For Arch Linux
pacman -S zsh git curl

# For Debian/Ubuntu
apt install zsh git curl

# For RHEL/CentOS
dnf install zsh git curl
```

### Setup Steps

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/zsh-config.git ~/.zsh_config
```

2. Create symbolic links:
```bash
ln -sf ~/.zsh_config/.zshrc ~/.zshrc
ln -sf ~/.zsh_config/.zshrc.local ~/.zshrc.local
ln -sf ~/.zsh_config/.paru_fzf.zsh ~/.paru_fzf.zsh
```

3. Install Znap (plugin manager):
```bash
git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git ~/.zsh_config/znap
```

4. Set ZSH as default shell:
```bash
chsh -s $(which zsh)
```

## 🔧 Configuration Structure

```
~/.zsh_config/
├── .zshrc           # Main configuration file
├── .zshrc.local     # Local/machine-specific settings
└── .paru_fzf.zsh    # Package management utilities
```

### Main Components

- **Base Configuration** (.zshrc)
  - Shell options and history settings
  - Key bindings
  - Completion system configuration
  - Plugin management
  - Common aliases and functions

- **Local Configuration** (.zshrc.local)
  - Powerlevel10k theme settings
  - Rust development environment
  - Machine-specific configurations

- **Package Management** (.paru_fzf.zsh)
  - Interactive package management interface
  - Fuzzy search capabilities
  - System maintenance utilities

## 🔌 Included Plugins

- `fast-syntax-highlighting`: Real-time command syntax highlighting
- `zsh-autosuggestions`: Fish-like command suggestions
- `zsh-completions`: Additional completion definitions
- `powerlevel10k`: Modern, informative prompt theme
- `z`: Quick directory jumping
- `wd`: Directory bookmarking
- `git`: Enhanced Git integration
- `colored-man-pages`: Colorized man pages
- `virtualenvwrapper`: Python virtual environment management

## 📦 Package Management Features

Access package management utilities by running `pf` command:

- Search and install packages
- Remove packages
- Clean orphaned packages
- List explicit packages
- List foreign (AUR) packages

## ⚡ Performance Optimizations

- Lazy loading of completions
- Instant prompt configuration
- Efficient plugin management with Znap
- Optimized completion system

## 🛠 Customization

1. Local machine configurations can be added to `.zshrc.local`
2. Additional aliases can be defined in `.zshrc`
3. Powerlevel10k prompt can be reconfigured using:
```bash
p10k configure
```

## 🔍 Useful Commands

- `mkcd`: Create and enter directory
- `cheat`: Access cheat.sh
- `AReboot`: Restart audio system
- `reflectmirrors`: Update pacman mirrors
- `repack_arch`: Reinstall all native packages

## 💻 Server-Specific Considerations

For server environments:
- Powerlevel10k theme automatically adjusts for non-GUI environments
- Package management features work with basic package managers
- Performance optimizations help with remote connections
- No GUI-dependent features are required

## 📝 License

MIT License - feel free to use and modify as needed.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
