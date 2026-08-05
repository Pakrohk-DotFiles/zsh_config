# Enhanced ZSH Configuration

> A powerful, modular, and performance-optimized Zsh configuration designed for developers and power users.

This project provides a comprehensive Zsh setup that balances rich features with a fast and responsive shell experience. It is built to be easily customizable and works seamlessly across both desktop and server environments. The configuration is kept clean and organized by sourcing modular files from a central directory (`~/.zsh_config`), ensuring your home directory remains uncluttered.

## ✨ Core Features

- **Fast & Responsive:** Utilizes `zsh-snap` (znap) for efficient plugin management and instant prompt loading.
- **Powerful Prompt:** A feature-rich and informative prompt powered by [Starship](https://starship.rs/).
- **Intelligent Completions:** Advanced command completion system with auto-suggestions and syntax highlighting.
- **Efficient Workflow:** A curated collection of aliases, functions, and plugins to streamline common tasks.
- **Multi-OS & Cross-Platform:** Designed to run flawlessly on **Arch Linux, Debian/Ubuntu, Fedora, Alpine, openSUSE, and macOS** (latest version).
- **Interactive Multi-OS Package Manager:** Includes a powerful `fzf`-based package manager (`pf` command) compatible with all major package managers (`pacman/paru`, `brew`, `apt`, `dnf`, `apk`, and `zypper`).
- **Clean & Organized:** A modular structure that is easy to manage and customize.

## 🚀 Installation

The easiest way to install this configuration is using the provided automated installer.

### Quick Install (Recommended)

Run the following command in your terminal:

```bash
# For a standard interactive installation
curl -fsSL https://raw.githubusercontent.com/Pakrohk-DotFiles/zsh_config/refs/heads/main/install.sh | bash

# Non-interactive installation (choose your mode)
curl -fsSL https://raw.githubusercontent.com/Pakrohk-DotFiles/zsh_config/refs/heads/main/install.sh | bash -s -- --server
curl -fsSL https://raw.githubusercontent.com/Pakrohk-DotFiles/zsh_config/refs/heads/main/install.sh | bash -s -- --desktop
```

### 🪟 Windows Installation (WSL & MSYS2 / Native)

If you are on Windows, you can use our dedicated PowerShell installer supporting both **WSL (Windows Subsystem for Linux)** and **MSYS2 (Native Windows)**.

Run the following command in **PowerShell (as Administrator)**:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Pakrohk-DotFiles/zsh_config/refs/heads/main/install.ps1'))
```

This installer will guide you through:
1. **WSL (Option 1):** Installs the configuration inside your selected WSL distribution.
2. **MSYS2 (Option 2):** Detects existing MSYS2 installation or automatically installs MSYS2 silently, then configures Zsh as the default shell and sets up all configurations.

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

This configuration supports multiple Operating Systems. You can install core and optional dependencies manually using your favorite package manager.

#### Core Requirements
These packages are essential for the basic functionality of the shell configuration.

- **Arch Linux:** `sudo pacman -S zsh git curl fzf`
- **macOS:** `brew install zsh git curl fzf`
- **Debian/Ubuntu:** `sudo apt install zsh git curl fzf`
- **Fedora:** `sudo dnf install zsh git curl fzf`
- **Alpine:** `sudo apk add zsh git curl fzf`
- **openSUSE:** `sudo zypper install zsh git curl fzf`

#### Optional (for Full Alias, Function, & Extra Support)
These packages enable additional features, extracting functions, and utilities:

- **Arch Linux:** `sudo pacman -S base-devel reflector p7zip unzip python-virtualenvwrapper` (Plus AUR helper `paru`)
- **macOS:** `brew install p7zip unzip`
- **Debian/Ubuntu:** `sudo apt install p7zip-full unzip`
- **Fedora:** `sudo dnf install p7zip unzip`
- **Alpine:** `sudo apk add p7zip unzip`
- **openSUSE:** `sudo zypper install p7zip unzip`

### Setup Steps

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Pakrohk-DotFiles/zsh_config.git ~/.zsh_config
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
-   `.paru_fzf.zsh`: Implements the interactive package management function (`pf`) for all supported operating systems and package managers.
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

Run the `pf` command to open an interactive `fzf` menu for managing your system packages. It automatically detects your package manager and allows you to:
-   **Search and install packages** from the repositories.
-   **Remove packages** that are currently installed.
-   **Clean orphaned packages** to free up disk space.
-   **List explicitly installed** or **foreign/extra** packages.

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
