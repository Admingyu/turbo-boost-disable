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

# 提取主版本号和次版本号（例如 13.1 -> 13）
OS_MAJOR=$(echo "$OS_VERSION" | cut -d '.' -f 1)
OS_MINOR=$(echo "$OS_VERSION" | cut -d '.' -f 2)
echo "Detected macOS version: $OS_VERSION"


echo "Checking if Turbo Boost already disabled..."
# define which command to use
results=0
if [[ $OS_MAJOR -eq 10 && $OS_MINOR -lt 15 ]]; then
    echo "Using kextstat to check the kernel extension."
    results=`kextstat | grep -c com.rugarciap.DisableTurboBoost`
elif [[ $OS_MAJOR -ge 10 && $OS_MINOR -ge 15 ]] || [[ $OS_MAJOR -gt 10 ]]; then
    echo "Using kmutil to check the kernel extension."
    results=`kmutil showloaded | grep -c com.rugarciap.DisableTurboBoost`
else
    echo "Unsupported macOS version: $OS_VERSION"
    exit 1
fi
if [ $results -gt 0 ]
then
    echo "Found kext com.rugarciap.DisableTurboBoost"
    echo "Turbo Boost already disabled!"
    exit 0
fi
echo "[TurboBoost is currently enabled]"
echo
echo "Disabling TurboBoost now..."


# define which command to use
if [[ $OS_MAJOR -eq 10 && $OS_MINOR -lt 15 ]]; then
    echo "Using kextutil to load the kernel extension."
    sudo /usr/bin/kextutil -v "$KEXT_PATH"
elif [[ $OS_MAJOR -ge 10 && $OS_MINOR -ge 15 ]] || [[ $OS_MAJOR -gt 10 ]]; then
    echo "Using kmutil to load the kernel extension."
    sudo /usr/bin/kmutil load --bundle-path "$KEXT_PATH"
else
    echo "Unsupported macOS version: $OS_VERSION"
    exit 1
fi
echo "Turbo Boost disabled."

