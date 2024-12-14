#!/usr/bin/env sh
# Re-enables turbo boost by disabling the kext that enabled it

# define .kext path
KEXT_PATH="/Applications/tbswitcher_resources/DisableTurboBoost.64bits.kext"
# check if .kext file exists
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
CHECK_CMD=""
UNLOAD_CMD=""
if [[ $OS_MAJOR -eq 10 && $OS_MINOR -lt 15 ]]; then
    CHECK_CMD="kextstat"
    UNLOAD_CMD="kextunload -v"
elif [[ $OS_MAJOR -ge 10 && $OS_MINOR -ge 15 ]] || [[ $OS_MAJOR -gt 10 ]]; then
    CHECK_CMD="kmutil showloaded"
    UNLOAD_CMD="kmutil unload --bundle-path"
else
    echo "Unsupported macOS version: $OS_VERSION"
    exit 1
fi

echo "Using $CHECK_CMD to check if Turbo Boost is still enabled..."
if [[ $($CHECK_CMD | grep -c com.rugarciap.DisableTurboBoost) -eq 0 ]]; then
    echo "No kext to disable."
    echo "Turbo Boost is still enabled."
    exit 0
fi

echo "[Turbo Boost is currently disabled.]"
echo 
echo "Unloading kext and disabling now..."
sudo $UNLOAD_CMD "$KEXT_PATH"

echo "Turbo Boost Enabled."
