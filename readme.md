# Enhanced ZSH Configuration

> A powerful, modular, and performance-optimized Zsh configuration designed for developers and power users.

This project provides a comprehensive Zsh setup that balances rich features with a fast and responsive shell experience. It is built to be easily customizable and works seamlessly across both desktop and server environments. The configuration is kept clean and organized by sourcing modular files from a central directory (`~/.zsh_config`), ensuring your home directory remains uncluttered.

## ✨ Core Features

- **Fast & Responsive:** Utilizes `zsh-snap` (znap) for efficient plugin management and instant prompt loading.
- **Powerful Prompt:** A feature-rich and informative prompt powered by [Starship](https://starship.rs/).
- **Intelligent Completions:** Advanced command completion system with auto-suggestions and syntax highlighting.
- **Efficient Workflow:** A curated collection of aliases, functions, and plugins to streamline common tasks.
- **Arch-Focused Tools:** Includes a powerful `fzf`-based package manager for Arch Linux users.
- **Clean & Organized:** A modular structure that is easy to manage and customize.

## 🚀 Installation

The easiest way to install this configuration is using the provided automated installer.

### Quick Install (Recommended)

Run the following command in your terminal:

```bash
# For a standard installation (will prompt for mode)
curl -fsSL https://raw.githubusercontent.com/Pakrohk-DotFiles/zsh-config/refs/heads/main/install.sh | bash
```

The installer will:
1. Detect your Operating System.
2. Ask you to choose between **Desktop/Personal** or **Server** mode.
   - **Root User:** If running as root, Server mode is enforced automatically.
3. Automatically install necessary dependencies.
   - **Server Mode:** Only essential tools (`zsh`, `git`, `curl`) are installed.
4. Set up the configuration and symbolic links.

### Security on Servers

This configuration is designed with security in mind for server environments:
- **No SSH Agent:** Automatic `ssh-agent` management and key loading are disabled on servers to prevent socket exposure.
- **Minimal Plugins:** Only essential plugins like syntax highlighting and autosuggestions are loaded.
- **Minimal Dependencies:** GUI-related tools and AUR helpers are not installed or configured.

### Manual Installation

**Note:** This configuration is primarily designed for **Arch Linux**. While it can be adapted for other distributions, the package management functions and some aliases will require modification.

#### Core Requirements
These packages are essential for the basic functionality of the shell configuration.
```bash
# The shell itself, a tool for cloning, and a tool for downloading installers
sudo pacman -S zsh git curl
```

#### For Package Management (`pf` command)
These are required for the interactive package management script.
```bash
# A command-line fuzzy finder
sudo pacman -S fzf

# An AUR helper is required for the 'pf' script.
# This config uses 'paru', but you can adapt the script for another.
# To install 'paru' from the AUR:
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

#### For Full Alias & Function Support
These packages enable various helper functions and aliases found in the `.zsh_aliases` file.
```bash
sudo pacman -S reflector p7zip unzip z
```
- `reflector`: Used by the `reflectmirrors` function.
- `p7zip`: Used by the `extract` function for `.7z` files.
- `unzip`: Used by the `extract` function for `.zip` files.
- `z`: Required for the `z` command (directory jumping).

#### Optional (for Python Development)
This is only needed if you work with Python virtual environments.
```bash
# Required for the virtualenvwrapper plugin
sudo pacman -S python-virtualenvwrapper
```

### Setup Steps

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Pakrohk-DotFiles/zsh-config.git ~/.zsh_config
    ```

2.  **Create the symbolic link:**
    ```bash
    ln -sf ~/.zsh_config/.zshrc ~/.zshrc
    ```

3.  **Set Zsh as your default shell:**
    ```bash
    chsh -s $(which zsh)
    ```

Now, restart your terminal. The first time you launch Zsh, `znap` and `starship` will be automatically installed.

## 🔧 Configuration Deep Dive

The configuration is split into several files, each with a specific purpose. All files are located in `~/.zsh_config`.

-   `.zshrc`: The main entry point. It handles `znap` bootstrapping, sets core Zsh options, and sources all other configuration files. This is the **only** file that needs to be symlinked to your home directory.
-   `.prompt.local`: Manages the Starship prompt. It ensures Starship is installed and generates a default `starship.toml` configuration if one doesn't exist.
-   `.zsh_aliases`: Contains a curated set of aliases and shell functions to simplify common commands and workflows. See the "Aliases and Functions" section below for details.
-   `.paru_fzf.zsh`: Implements the interactive package management function (`pf`) for Arch Linux.
-   `.zshrc.local`: An optional file for your private, machine-specific settings (e.g., environment variables with sensitive keys). It is sourced by `.zshrc` if it exists.

### Aliases and Functions (`.zsh_aliases`)

This file is the heart of the workflow enhancements. Here are some of the key helpers available:

| Command                             | Description                                                              |
| ----------------------------------- | ------------------------------------------------------------------------ |
| **Navigation**                      |                                                                          |
| `mkcd <dir>`                        | Creates a directory and immediately `cd`'s into it.                      |
| `cdf`                               | Uses `fzf` to fuzzy-find a subdirectory and `cd` into it.                |
| `up <n>`                            | Navigates up `n` parent directories (e.g., `up 3`).                      |
| **System Maintenance (Arch)**       |                                                                          |
| `softar`                            | Safely removes all orphaned packages.                                    |
| `rebuild_system`                    | Rebuilds the initramfs and GRUB configuration in one go.                 |
| `reflectmirrors [countries]`        | Refreshes Arch Linux mirrors, sorting by speed (e.g., `reflectmirrors "Germany,France"`). |
| **Utilities**                       |                                                                          |
| `extract <file>`                    | Extracts any common archive type (`.zip`, `.tar.gz`, `.rar`, etc.).       |
| `cheat <cmd> <term>`                | Searches the man page of `<cmd>` for a specific `<term>`.                |
| `refonts`                           | Force-refreshes the system's font cache.                                 |
| **Global Aliases**                  |                                                                          |
| `G`                                 | Global alias for `| grep`. Example: `ps aux G zsh`                       |
| `H` / `T` / `L`                     | Global aliases for piping to `head`, `tail`, or `less`.                  |

### Package Management (`pf`)

Run the `pf` command to open an interactive `fzf` menu for managing your Arch Linux packages. It allows you to:
-   **Search and install packages** from both the official repositories and the AUR.
-   **Remove packages** that are currently installed.
-   **Clean orphaned packages** to free up disk space.
-   **List explicitly installed** or **foreign (AUR)** packages.

### SSH Agent Management

The configuration includes a robust script to automatically manage an `ssh-agent` instance.
-   The agent is started on your first Zsh session.
-   The agent's environment is saved and reused across all subsequent shell sessions.
-   It automatically loads your `~/.ssh/id_ed25519` key, so you only need to enter your passphrase once per session.

## 🔌 Plugins

This setup uses a minimal but powerful set of plugins, all loaded via `znap`:
-   `fast-syntax-highlighting`: Provides real-time syntax highlighting for commands.
-   `zsh-autosuggestions`: Suggests commands as you type based on your history.
-   `zsh-completions`: Provides additional completion definitions for many common tools.
-   `z`: Allows you to jump to your most frequently used directories.
-   And several others for git integration, colored man pages, and more.

## 📝 License

This project is licensed under the MIT License. Feel free to use, modify, and distribute it as you see fit.
