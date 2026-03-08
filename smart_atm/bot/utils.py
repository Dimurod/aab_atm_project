# bot/utils.py
from datetime import datetime
from bot.config import GOOGLE_MAPS_KEY


def google_maps_url(lat: float, lon: float, label: str = "") -> str:
    """Generate a Google Maps directions URL."""
    label_enc = label.replace(" ", "+")
    return f"https://www.google.com/maps/dir/?api=1&destination={lat},{lon}&destination_place_id={label_enc}"


def google_maps_static(lat: float, lon: float) -> str:
    """Generate a static map image URL."""
    if not GOOGLE_MAPS_KEY:
        return ""
    return (
        f"https://maps.googleapis.com/maps/api/staticmap"
        f"?center={lat},{lon}&zoom=16&size=400x200"
        f"&markers=color:red%7C{lat},{lon}"
        f"&key={GOOGLE_MAPS_KEY}"
    )


def format_amount(amount: float) -> str:
    return f"{amount:,.0f}".replace(",", " ")


def now_str() -> str:
    return datetime.now().strftime("%d.%m.%Y %H:%M")


def parse_amount(text: str) -> float | None:
    """Parse amount from user input, return None if invalid."""
    cleaned = text.strip().replace(" ", "").replace(",", "").replace(".", "")
    try:
        val = float(cleaned)
        if val <= 0 or val > 100_000_000_000:
            return None
        return val
    except ValueError:
        return None
