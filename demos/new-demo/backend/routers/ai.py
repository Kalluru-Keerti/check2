from typing import Optional

from fastapi import APIRouter, File, Form, HTTPException, UploadFile
from fastapi.concurrency import run_in_threadpool

from config import get_settings
from services import catalog
from services.analyzer import analyze
from services.resume_parser import ResumeParseError, parse_resume

router = APIRouter()


@router.get("/models")
def models():
    s = get_settings()
    return {
        "default": s.WATSONX_MODEL_ID,
        "models": [
            {"id": "meta-llama/llama-4-maverick-17b-128e-instruct-fp8", "label": "Llama 4 Maverick 17B (multimodal, default)"},
            {"id": "ibm/granite-3-3-8b-instruct", "label": "IBM Granite 3.3 8B Instruct"},
        ],
        "note": "Model ids are confirmed against the live catalog at runtime in live mode.",
    }


@router.post("/analyze")
async def analyze_resume(
    role_id: str = Form(..., max_length=20),
    file: Optional[UploadFile] = File(default=None),
    sample_id: Optional[str] = Form(default=None, max_length=30),
):
    """Analyse a resume (uploaded in any format, OR a built-in synthetic sample) against a role.

    Advisory only: this endpoint never makes a hiring decision and nothing is stored.
    """
    settings = get_settings()
    role = catalog.get_role(role_id)
    if not role:
        raise HTTPException(status_code=404, detail="Unknown role.")

    if sample_id:
        sample = catalog.get_sample(sample_id)
        if not sample:
            raise HTTPException(status_code=404, detail="Unknown sample resume.")
        data, filename, ctype = sample["text"].encode("utf-8"), f"{sample['id']}.txt", "text/plain"
    elif file is not None:
        limit = settings.MAX_UPLOAD_MB * 1024 * 1024
        data = await file.read(limit + 1)
        if len(data) > limit:
            raise HTTPException(status_code=413, detail=f"File is larger than {settings.MAX_UPLOAD_MB} MB.")
        filename, ctype = file.filename or "resume", file.content_type or ""
    else:
        raise HTTPException(status_code=422, detail="Provide a resume file or a sample_id.")

    try:
        parsed = parse_resume(filename, data, ctype)
        return await run_in_threadpool(analyze, role, parsed, settings)
    except ResumeParseError as exc:
        raise HTTPException(status_code=422, detail=str(exc))
