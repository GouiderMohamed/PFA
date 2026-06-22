#!/bin/bash
set -e

G=/sys/kernel/config/usb_gadget/g1

# ---------------------------------------------------------------------------
# Load config + defaults
# ---------------------------------------------------------------------------
[ -f /etc/conf.d/usb-gadget ] && source /etc/conf.d/usb-gadget

MANUFACTURER="${MANUFACTURER:-BeagleBone}"
PRODUCT="${PRODUCT:-BBB USB Gadget}"
SERIAL="${SERIAL:-0001}"
VENDOR_ID="${VENDOR_ID:-0x1d6b}"
PRODUCT_ID="${PRODUCT_ID:-0x0104}"
BCD_USB="${BCD_USB:-0x0200}"
USB_IP="${USB_IP:-192.168.7.2}"
USB_PREFIX="${USB_PREFIX:-24}"
CONFIG_LABEL="${CONFIG_LABEL:-NCM + RNDIS}"
MAX_POWER="${MAX_POWER:-250}"

# ---------------------------------------------------------------------------
up() {
    echo "[USB-GADGET] starting..."

    # Load modules
    modprobe libcomposite 2>/dev/null || true

    # Mount configfs safely
    mountpoint -q /sys/kernel/config || \
        mount -t configfs none /sys/kernel/config

    # Wait for UDC (IMPORTANT for Yocto boot race)
    UDC=""
    for i in $(seq 1 50); do
        UDC=$(ls /sys/class/udc 2>/dev/null | head -n 1 || true)
        [ -n "$UDC" ] && break
        sleep 0.1
    done

    if [ -z "$UDC" ]; then
        echo "[USB-GADGET] ERROR: no UDC found"
        exit 1
    fi

    # Clean previous instance
    [ -d "$G" ] && down

    mkdir -p "$G"
    cd "$G"

    # Identity
    echo "$VENDOR_ID"  > idVendor
    echo "$PRODUCT_ID" > idProduct
    echo "$BCD_USB"    > bcdUSB

    mkdir -p strings/0x409
    echo "$MANUFACTURER" > strings/0x409/manufacturer
    echo "$PRODUCT"      > strings/0x409/product
    echo "$SERIAL"       > strings/0x409/serialnumber

    # Config
    mkdir -p configs/c.1/strings/0x409
    echo "$CONFIG_LABEL" > configs/c.1/strings/0x409/configuration
    echo "$MAX_POWER"    > configs/c.1/MaxPower

    # Distinct MACs for each function (shared MACs cause silent bind failure)
    HOST_MAC_NCM=$(printf   "02:11:%02X:%02X:%02X:%02X" $RANDOM $RANDOM $RANDOM $RANDOM)
    HOST_MAC_RNDIS=$(printf "02:22:%02X:%02X:%02X:%02X" $RANDOM $RANDOM $RANDOM $RANDOM)
    DEV_MAC_NCM="02:11:22:33:44:55"
    DEV_MAC_RNDIS="02:22:33:44:55:66"

    # NCM function (modern Linux / macOS / Linux host)
    mkdir -p functions/ncm.usb0
    echo "$DEV_MAC_NCM"   > functions/ncm.usb0/dev_addr
    echo "$HOST_MAC_NCM"  > functions/ncm.usb0/host_addr

    # RNDIS function (Windows host support)
    mkdir -p functions/rndis.usb0
    echo "$DEV_MAC_RNDIS"  > functions/rndis.usb0/dev_addr
    echo "$HOST_MAC_RNDIS" > functions/rndis.usb0/host_addr

    # Link functions into config
    ln -s functions/ncm.usb0   configs/c.1/
    ln -s functions/rndis.usb0 configs/c.1/

    # Bind gadget to UDC
    echo "$UDC" > UDC

    # Wait for usb0 interface to appear (active wait, more reliable than sleep)
    for i in $(seq 1 30); do
        ip link show usb0 &>/dev/null && break
        sleep 0.2
    done

    # Network setup
    ip link set usb0 up                        2>/dev/null || true
    ip addr add "$USB_IP/$USB_PREFIX" dev usb0 2>/dev/null || true

    echo "[USB-GADGET] started on UDC=$UDC  ip=$USB_IP/$USB_PREFIX"
}

# ---------------------------------------------------------------------------
down() {
    echo "[USB-GADGET] stopping..."

    [ -d "$G" ] || return 0

    # Unbind gadget first
    echo "" > "$G/UDC" 2>/dev/null || true

    sleep 0.5

    # Remove symlinks from config only (NOT rm -f * which would hit strings/ too)
    rm -f "$G/configs/c.1/ncm.usb0"   2>/dev/null || true
    rm -f "$G/configs/c.1/rndis.usb0" 2>/dev/null || true

    # Tear down in reverse order (kernel requires strict ordering)
    rmdir "$G/configs/c.1/strings/0x409" 2>/dev/null || true
    rmdir "$G/configs/c.1"               2>/dev/null || true
    rmdir "$G/functions/ncm.usb0"        2>/dev/null || true
    rmdir "$G/functions/rndis.usb0"      2>/dev/null || true
    rmdir "$G/strings/0x409"             2>/dev/null || true
    rmdir "$G"                           2>/dev/null || true

    echo "[USB-GADGET] stopped"
}

# ---------------------------------------------------------------------------
case "$1" in
    up)   up   ;;
    down) down ;;
    *)
        echo "Usage: $0 up|down"
        exit 1
        ;;
esac