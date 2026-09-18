"""Read USB descriptors only; do not open/reset the JTAG chain."""
import json
from efx_pgm.usb_resolver import UsbResolver

print(json.dumps([{
    "serial": d.serial_number or "", "description": d.description,
    "vid": d.vendor_id, "pid": d.product_id,
    "urls": [url for url in d.URLS if url],
} for d in UsbResolver().get_usb_connections()]))
