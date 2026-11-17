"""Load role catalog and sample resumes from JSON (synthetic data only)."""
import json
from functools import lru_cache
from typing import Any, Dict, List, Optional

from config import DATA_DIR


@lru_cache
def _load(name: str) -> Dict[str, Any]:
    with open(DATA_DIR / name, encoding="utf-8") as fh:
        return json.load(fh)


def get_catalog() -> Dict[str, Any]:
    return _load("roles.json")


def get_roles(category: Optional[str] = None) -> List[Dict[str, Any]]:
    roles = get_catalog()["roles"]
    if category:
        roles = [r for r in roles if r["category"].lower() == category.lower()]
    return roles


def get_role(role_id: str) -> Optional[Dict[str, Any]]:
    return next((r for r in get_catalog()["roles"] if r["id"] == role_id), None)


def get_samples() -> List[Dict[str, Any]]:
    return _load("sample_resumes.json")["samples"]


def get_sample(sample_id: str) -> Optional[Dict[str, Any]]:
    return next((s for s in get_samples() if s["id"] == sample_id), None)
