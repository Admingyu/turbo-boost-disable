#!/usr/bin/env sh
# Re-enables turbo boost by disabling the kext that enabled it

# define .kext path
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

echo "Checking if Turbo Boost is enabled..."
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
if [ $results -eq 0 ]
then 
    echo "No kext to disable."
    echo "Turbo Boost is still enabled."
    exit 0
fi

echo "[Turbo Boost is currently enabled]"
echo 
echo "Unloading kext and disabling now..."
# define which command to use
if [[ $OS_MAJOR -eq 10 && $OS_MINOR -lt 15 ]]; then
    echo "Using kextunload to load the kernel extension."
    sudo /sbin/kextunload -v "$KEXT_PATH"
elif [[ $OS_MAJOR -ge 10 && $OS_MINOR -ge 15 ]] || [[ $OS_MAJOR -gt 10 ]]; then
    echo "Using kmutil to load the kernel extension."
    sudo /usr/bin/kmutil unload --bundle-path "$KEXT_PATH"
else
    echo "Unsupported macOS version: $OS_VERSION"
    exit 1
fi

echo "Turbo Boost Enabled."
