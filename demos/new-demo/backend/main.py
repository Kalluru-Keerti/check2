"""FastAPI entry point - IBM Role-Fit Resume Analyser (DEMO-RESUME-001)."""
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import get_settings
from routers import ai, data, demo, health

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("demo")


@asynccontextmanager
async def lifespan(_: FastAPI):
    s = get_settings()
    mode = "LIVE" if s.is_live and s.live_configured else "MOCK"
    log.info("Starting Role-Fit Resume Analyser in %s mode (requested: %s)", mode, s.DEMO_MODE)
    yield


app = FastAPI(title="IBM Role-Fit Resume Analyser", version="1.0.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=get_settings().CORS_ORIGINS,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)

app.include_router(health.router, prefix="/api")
app.include_router(data.router, prefix="/api/data")
app.include_router(ai.router, prefix="/api/ai")
app.include_router(demo.router, prefix="/api/demo")
