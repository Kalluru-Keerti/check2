from fastapi import APIRouter

from config import get_settings

router = APIRouter()


@router.get("/config")
def config():
    s = get_settings()
    return {
        "mode": "live" if s.is_live and s.live_configured else "mock",
        "requestedMode": s.DEMO_MODE,
        "model": s.WATSONX_MODEL_ID,
        "services": {"watsonx.ai": "connected" if s.is_live and s.live_configured else "mock"},
        "maxUploadMb": s.MAX_UPLOAD_MB,
        "storage": "none - resumes are processed in memory and discarded",
    }


@router.post("/reset")
def reset():
    return {"status": "ok", "message": "Nothing to reset - no resume data is stored."}
