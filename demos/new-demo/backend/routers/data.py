from typing import Optional

from fastapi import APIRouter, HTTPException, Query

from services import catalog

router = APIRouter()


@router.get("/categories")
def categories():
    return {"categories": catalog.get_catalog()["categories"], "disclaimer": catalog.get_catalog()["disclaimer"]}


@router.get("/roles")
def roles(category: Optional[str] = Query(default=None, max_length=60)):
    items = catalog.get_roles(category)
    return {"count": len(items), "roles": items}


@router.get("/roles/{role_id}")
def role(role_id: str):
    item = catalog.get_role(role_id)
    if not item:
        raise HTTPException(status_code=404, detail="Role not found")
    return item


@router.get("/samples")
def samples():
    return {"samples": [{k: v for k, v in s.items() if k != "text"} for s in catalog.get_samples()]}
