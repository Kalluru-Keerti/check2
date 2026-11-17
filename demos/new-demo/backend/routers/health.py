from fastapi import APIRouter

from config import DISCLAIMER, get_settings

router = APIRouter()


@router.get("/health")
def health():
    s = get_settings()
    return {
        "status": "ok",
        "mode": "live" if s.is_live and s.live_configured else "mock",
        "version": "1.0.0",
        "disclaimer": DISCLAIMER,
    }
