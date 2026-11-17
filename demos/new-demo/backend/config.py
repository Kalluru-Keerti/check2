"""Application settings. All credentials come from environment variables."""
from functools import lru_cache
from pathlib import Path
from typing import List, Optional

from pydantic_settings import BaseSettings, SettingsConfigDict

BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"

DISCLAIMER = "All data is synthetic. No real client data or PII is used."
ADVISORY = (
    "Advisory only. This result is an AI-generated suggestion to help you plan your career. "
    "It is not a hiring decision, and it is not stored."
)


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=(".env", "../.env"), extra="ignore")

    DEMO_MODE: str = "mock"  # "mock" (default) or "live"
    WATSONX_API_KEY: Optional[str] = None
    WATSONX_PROJECT_ID: Optional[str] = None
    WATSONX_SPACE_ID: Optional[str] = None
    WATSONX_URL: str = "https://us-south.ml.cloud.ibm.com"
    WATSONX_MODEL_ID: str = "meta-llama/llama-4-maverick-17b-128e-instruct-fp8"
    MAX_UPLOAD_MB: int = 10
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://127.0.0.1:3000",
    ]

    @property
    def is_live(self) -> bool:
        return self.DEMO_MODE.lower() == "live"

    @property
    def live_configured(self) -> bool:
        has_scope = bool(self.WATSONX_PROJECT_ID) != bool(self.WATSONX_SPACE_ID)  # exactly one
        return bool(self.WATSONX_API_KEY) and has_scope


@lru_cache
def get_settings() -> Settings:
    return Settings()
