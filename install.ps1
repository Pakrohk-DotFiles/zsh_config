# ==========================================================
# Enhanced ZSH Configuration Installer for Windows
# نصاب پیکربندی پیشرفته ZSH برای ویندوز
# ==========================================================

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Helper function to write colored messages
function Write-Color {
    param(
        [string]$Message,
        [ConsoleColor]$Color = [ConsoleColor]::White,
        [bool]$NoNewLine = $false
    )
    $origColor = [Console]::ForegroundColor
    [Console]::ForegroundColor = $Color
    if ($NoNewLine) {
        Write-Host $Message -NoNewline
    } else {
        Write-Host $Message
    }
    [Console]::ForegroundColor = $origColor
}

function Show-Header {
    Clear-Host
    Write-Color "==========================================================" -Color Cyan
    Write-Color "      نصاب پیکربندی پیشرفته ZSH برای ویندوز" -Color Green
    Write-Color "      Enhanced ZSH Configuration Installer for Windows" -Color Green
    Write-Color "==========================================================" -Color Cyan
    Write-Color ""
}

Show-Header

Write-Color "لطفاً یکی از گزینه‌های زیر را انتخاب کنید / Please choose an option:" -Color Yellow
Write-Color "1) نصب در محیط WSL (Windows Subsystem for Linux)" -Color White
Write-Color "   Install inside WSL (Windows Subsystem for Linux)" -Color White
Write-Color "2) نصب بومی در ویندوز از طریق MSYS2" -Color White
Write-Color "   Install natively on Windows via MSYS2" -Color White
Write-Color "3) خروج / Exit" -Color Red
Write-Color ""

$choice = Read-Host "گزینه / Choice [1-3]"

if ($choice -eq "1") {
    Show-Header
    Write-Color "[*] در حال بررسی وضعیت WSL... / Checking WSL status..." -Color Blue
    $wslCheck = Get-Command wsl -ErrorAction SilentlyContinue
    if (-not $wslCheck) {
        Write-Color "[!] ابزار WSL یافت نشد. لطفاً ابتدا WSL را روی ویندوز خود فعال کنید." -Color Red
        Write-Color "[!] WSL was not found. Please enable/install WSL on your Windows machine first." -Color Red
        Write-Color "    راهنما / Help: https://learn.microsoft.com/en-us/windows/wsl/install" -Color Yellow
        Read-Host "کلیدی را برای خروج فشار دهید... / Press any key to exit..."
        exit
    }

    Write-Color "[+] توزیع‌های نصب شده WSL / Installed WSL distributions:" -Color Yellow

    # Get WSL distros list. We filter out the header and extra lines.
    $distros = @()
    $wslList = wsl.exe --list --quiet
    foreach ($line in $wslList) {
        $cleanLine = $line.Replace([char]0, "").Trim() # Remove null characters if any (WSL sometimes outputs UTF-16)
        if ($cleanLine -ne "") {
            $distros += $cleanLine
        }
    }

    if ($distros.Count -eq 0) {
        Write-Color "[!] هیچ توزیع فعال WSL یافت نشد. لطفاً ابتدا یک توزیع (مانند اوبونتو) نصب کنید." -Color Red
        Write-Color "[!] No active WSL distributions found. Please install a distribution (e.g., Ubuntu) first." -Color Red
        Read-Host "کلیدی را برای خروج فشار دهید... / Press any key to exit..."
        exit
    }

    for ($i = 0; $i -lt $distros.Count; $i++) {
        Write-Color "  $($i + 1)) $($distros[$i])" -Color White
    }
    Write-Color ""

    $distroChoice = Read-Host "شماره توزیع مورد نظر را وارد کنید / Enter distribution number [1-$($distros.Count)]"
    if ($distroChoice -as [int] -and [int]$distroChoice -le $distros.Count -and [int]$distroChoice -gt 0) {
        $selectedDistro = $distros[[int]$distroChoice - 1]
        Write-Color "`n[+] توزیع انتخاب شده / Selected Distro: $selectedDistro" -Color Green
        Write-Color "[*] در حال اجرای اسکریپت نصب در توزیع $selectedDistro..." -Color Blue
        Write-Color "[*] Launching installation script inside $selectedDistro..." -Color Blue

        # We run the installer inside WSL. We ensure curl/wget is available, then download and execute the script.
        # This approach ensures the Unix line-endings of the script are maintained.
        wsl.exe -d $selectedDistro -e bash -c "curl -fsSL https://raw.githubusercontent.com/Pakrohk-DotFiles/zsh_config/refs/heads/main/install.sh | bash"
    } else {
        Write-Color "[!] انتخاب نامعتبر / Invalid selection" -Color Red
    }
}
elseif ($choice -eq "2") {
    Show-Header
    Write-Color "[*] در حال بررسی وجود MSYS2... / Checking for MSYS2..." -Color Blue
    $msysPaths = @("C:\msys64", "C:\msys32", "D:\msys64", "$env:SystemDrive\msys64")
    $msysRoot = ""
    foreach ($path in $msysPaths) {
        if (Test-Path "$path\usr\bin\bash.exe") {
            $msysRoot = $path
            break
        }
    }

    if ($msysRoot -eq "") {
        Write-Color "[!] پوشه نصب MSYS2 یافت نشد. آیا می‌خواهید MSYS2 به طور خودکار دانلود و نصب شود؟ (y/n)" -Color Yellow
        Write-Color "[!] MSYS2 installation not found. Do you want to download and install it automatically? (y/n)" -Color Yellow
        $installMsys = Read-Host "انتخاب / Choice"
        if ($installMsys -eq "y" -or $installMsys -eq "Y") {
            Write-Color "`n[*] در حال دانلود نصب‌کننده MSYS2... / Downloading MSYS2 installer..." -Color Blue
            $tempExe = "$env:TEMP\msys2-installer.exe"

            # Using reliable and secure GitHub release link for MSYS2 installer
            $msysUrl = "https://github.com/msys2/msys2-installer/releases/download/2024-07-27/msys2-x86_64-20240727.exe"
            Invoke-WebRequest -Uri $msysUrl -OutFile $tempExe

            Write-Color "[*] در حال نصب بی‌صدای MSYS2 در مسیر C:\msys64..." -Color Blue
            Write-Color "[*] Installing MSYS2 silently to C:\msys64... This may take a few minutes." -Color Blue

            # Run installer silently
            $process = Start-Process -FilePath $tempExe -ArgumentList "/S", "/D=C:\msys64" -Wait -PassThru
            if ($process.ExitCode -eq 0) {
                Write-Color "[+] نصب MSYS2 با موفقیت انجام شد / MSYS2 installed successfully." -Color Green
                $msysRoot = "C:\msys64"
            } else {
                Write-Color "[!] خطایی در هنگام نصب رخ داد / An error occurred during installation." -Color Red
                Read-Host "کلیدی را برای خروج فشار دهید... / Press any key to exit..."
                exit
            }
        } else {
            Write-Color "[!] نصب لغو شد / Installation cancelled." -Color Red
            Read-Host "کلیدی را برای خروج فشار دهید... / Press any key to exit..."
            exit
        }
    }

    if (Test-Path "$msysRoot\usr\bin\bash.exe") {
        Write-Color "`n[+] مسیر MSYS2 یافت شد / MSYS2 path found: $msysRoot" -Color Green
        Write-Color "[*] در حال اجرای اسکریپت نصب داخل MSYS2..." -Color Blue
        Write-Color "[*] Launching installation script inside MSYS2..." -Color Blue

        $bashPath = "$msysRoot\usr\bin\bash.exe"

        # Run MSYS2 bash and install the zsh configuration
        # Using login shell (-lc) ensures standard paths and settings are correctly loaded
        & $bashPath -lc "curl -fsSL https://raw.githubusercontent.com/Pakrohk-DotFiles/zsh_config/refs/heads/main/install.sh | bash"
    } else {
        Write-Color "[!] خطا در اجرای MSYS2 / Error executing MSYS2." -Color Red
    }
}
else {
    Write-Color "`nخروج از نصب‌کننده / Exiting installer..." -Color Yellow
}

Write-Color "`n==========================================================" -Color Cyan
Write-Color "عملیات خاتمه یافت. برای خروج یک کلید را فشار دهید." -Color Green
Write-Color "Process finished. Press any key to exit." -Color Green
Write-Color "==========================================================" -Color Cyan
Read-Host
