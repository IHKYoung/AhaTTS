"""Web frontend router for serving static files."""

from pathlib import Path

from fastapi import APIRouter
from fastapi.responses import FileResponse, HTMLResponse

router = APIRouter(tags=["web"])

# Get the web directory path
# __file__ = api/src/routers/web.py -> 3 parents to reach api
WEB_DIR = Path(__file__).parent.parent.parent / "web"


@router.get("/")
async def serve_index():
    """Serve the main index.html page."""
    index_path = WEB_DIR / "index.html"
    if index_path.exists():
        headers = {
            "Cache-Control": "no-cache, no-store, must-revalidate",
            "Pragma": "no-cache",
            "Expires": "0"
        }
        return FileResponse(index_path, media_type="text/html", headers=headers)
    return HTMLResponse("<h1>Frontend not found</h1>", status_code=404)


@router.get("/{filename:path}")
async def serve_static(filename: str):
    """Serve static files (CSS, JS, etc.)."""
    file_path = WEB_DIR / filename

    # Security check - prevent directory traversal
    try:
        file_path.resolve().relative_to(WEB_DIR.resolve())
    except ValueError:
        return HTMLResponse("Not found", status_code=404)

    if file_path.exists() and file_path.is_file():
        # Determine content type
        suffix = file_path.suffix.lower()
        content_types = {
            ".html": "text/html",
            ".css": "text/css",
            ".js": "application/javascript",
            ".json": "application/json",
            ".png": "image/png",
            ".jpg": "image/jpeg",
            ".jpeg": "image/jpeg",
            ".svg": "image/svg+xml",
            ".ico": "image/x-icon",
        }
        media_type = content_types.get(suffix, "application/octet-stream")

        # Add cache control headers - no cache for HTML/JS/CSS in development
        headers = {}
        if suffix in [".html", ".js", ".css"]:
            headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
            headers["Pragma"] = "no-cache"
            headers["Expires"] = "0"

        return FileResponse(file_path, media_type=media_type, headers=headers)

    return HTMLResponse("Not found", status_code=404)
