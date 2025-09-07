# Enhanced ZSH Configuration

A powerful and modular ZSH configuration setup focused on productivity and user experience. Works seamlessly across both desktop and server environments.

## ✨ Features

- Fast and responsive shell experience with Starship and Znap
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
git clone https://github.com/Pakrohk-DotFiles/zsh-config.git ~/.zsh_config
```

2. Create symbolic links:
```bash
ln -sf ~/.zsh_config/.zshrc ~/.zshrc
ln -sf ~/.zsh_config/.zshrc.local ~/.zshrc.local
ln -sf ~/.zsh_config/.paru_fzf.zsh ~/.paru_fzf.zsh
ln -sf ~/.zsh_config/.prompt.local ~/.prompt.local
ln -sf ~/.zsh_config/.zsh_aliases ~/.zsh_aliases
```

3. Set ZSH as default shell:
```bash
chsh -s $(which zsh)
```

The first time you run ZSH, `znap` and `starship` will be automatically installed.

## 🔧 Configuration Structure

```
~/.zsh_config/
├── .zshrc           # Main configuration file
├── .zshrc.local     # Local/machine-specific settings
├── .prompt.local    # Starship prompt configuration and installation
├── .zsh_aliases     # Collection of shell aliases and functions
└── .paru_fzf.zsh    # Package management utilities
```

### Main Components

- **Base Configuration** (.zshrc)
  - Shell options, history, and key bindings
  - Completion system configuration
  - Plugin management with Znap
  - Sources external configuration files

- **Prompt Configuration** (.prompt.local)
  - Ensures Starship is installed
  - Initializes the Starship prompt
  - Creates a default `starship.toml` if none exists

- **Local Configuration** (.zshrc.local)
  - Machine-specific environment variables and settings
  - Can be used to override default settings

- **Aliases and Functions** (.zsh_aliases)
  - Contains shortcuts, system maintenance functions, and navigation helpers

- **Package Management** (.paru_fzf.zsh)
  - Interactive package management interface
  - Fuzzy search capabilities
  - System maintenance utilities

## 🔌 Included Plugins

- `fast-syntax-highlighting`: Real-time command syntax highlighting
- `zsh-autosuggestions`: Fish-like command suggestions
- `zsh-completions`: Additional completion definitions
- `z`: Quick directory jumping
- `wd`: Directory bookmarking
- `git`: Enhanced Git integration
- `colored-man-pages`: Colorized man pages
- `virtualenvwrapper`: Python virtual environment management
- `alias-tips`: Reminds you when you forget to use an alias
- `zcolors`: Provides colorized `ls` output

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

## 🔐 SSH Agent Management

The configuration automatically manages an `ssh-agent` instance for you:
- The agent is started on your first ZSH session.
- The agent's environment is saved and reused across all subsequent shell sessions.
- It automatically loads your `~/.ssh/id_ed25519` key, so you only need to enter your passphrase once.

## 🛠 Customization

1. **Local Settings**: Machine-specific configurations can be added to `.zshrc.local`.
2. **Aliases**: Additional aliases and functions can be defined in `.zsh_aliases`.
3. **Prompt**: The Starship prompt can be configured by editing `~/.config/starship.toml`. If this file doesn't exist, it will be created with a default configuration the first time you start ZSH. You can learn more about configuring Starship in the [official documentation](https://starship.rs/config/).

## 🔍 Useful Commands & Aliases

### Functions
- `mkcd <dir>`: Create a directory and enter it.
- `cdf`: Fuzzy search for a subdirectory and `cd` into it.
- `up <n>`: Go up `n` parent directories.
- `extract <file>`: Extract common archive types.
- `cheat <cmd> <term>`: Search the man page of `<cmd>` for `<term>`.
- `AReboot`: Restart the Pipewire audio system.
- `DAReboot`: Restart Discord and the audio system.
- `reflectmirrors [countries]`: Refresh Arch Linux mirrors (e.g., `reflectmirrors "United States,Germany"`).
- `repack_arch`: Reinstall all native packages from repositories.
- `refonts`: Refresh the system's font cache.
- `softar`: Remove orphaned packages.
- `rebuild_system`: Rebuild initramfs and GRUB.

### Global Aliases
- `G`: Pipe to `grep` (e.g., `ps aux G zsh`).
- `H`: Pipe to `head`.
- `T`: Pipe to `tail`.
- `L`: Pipe to `less`.

## 💻 Server-Specific Considerations

For server environments:
- The Starship prompt automatically adjusts for non-GUI environments
- Package management features work with basic package managers
- Performance optimizations help with remote connections
- No GUI-dependent features are required

## 📝 License

MIT License - feel free to use and modify as needed.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
