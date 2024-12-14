#!/usr/bin/env sh
# disables turbo boost by enabling a pre-signed kext
# (taken from the core of TurboBoost Switcher, but avoids their crappy interface)

# .kext path
KEXT_PATH="/Applications/tbswitcher_resources/DisableTurboBoost.64bits.kext"
# 检查 .kext 文件是否存在
if [[ ! -d "$KEXT_PATH" ]]; then
    echo "Error: The specified kext file does not exist at $KEXT_PATH"
    exit 1
fi
# get current macOS version
OS_VERSION=$(sw_vers -productVersion)

# get the major and minor version numbers（eg 13.1 -> 13）
OS_MAJOR=$(echo "$OS_VERSION" | cut -d '.' -f 1)
OS_MINOR=$(echo "$OS_VERSION" | cut -d '.' -f 2)
echo "Detected macOS version: $OS_VERSION"

# define which command to use
CHECK_CMD=""
LOAD_CMD=""
if [[ $OS_MAJOR -eq 10 && $OS_MINOR -lt 15 ]]; then
    CHECK_CMD="kextstat"
    LOAD_CMD="kextutil -v"
elif [[ $OS_MAJOR -ge 10 && $OS_MINOR -ge 15 ]] || [[ $OS_MAJOR -gt 10 ]]; then
    CHECK_CMD="kmutil showloaded"
    LOAD_CMD="kmutil load --bundle-path"
else
    echo "Unsupported macOS version: $OS_VERSION"
    exit 1
fi

echo "Using $CHECK_CMD to check if Turbo Boost already disabled..."
if [[ $($CHECK_CMD | grep -c com.rugarciap.DisableTurboBoost) -gt 0 ]]; then
    echo "Turbo Boost already disabled!"
    exit 0
fi
echo "[TurboBoost is currently enabled]"
echo
echo "Disabling TurboBoost now..."


# define which command to use
echo "Using $LOAD_CMD to load the kernel extension."
sudo $LOAD_CMD "$KEXT_PATH"

echo "Turbo Boost disabled."

