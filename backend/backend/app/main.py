from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os

from app.core.config import settings
from app.models.database import init_db
from app.api.endpoints import router as api_router

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="FastAPI Backend for Dental Root Resorption Analysis in Child Primary Teeth using PyTorch CNN",
    version="1.0.0"
)

# Enable CORS (Cross-Origin Resource Sharing)
# Allows the mobile emulator and external devices to make requests to the API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Startup DB initializations
@app.on_event("startup")
def startup_event():
    print("Initializing Database tables...")
    init_db()
    print("Database tables initialized successfully.")

# Include router endpoints
app.include_router(api_router, prefix=settings.API_V1_STR)
# Mirror router endpoints at root for simpler network integration on Retrofit if needed
app.include_router(api_router)

# Mount static files directories to serve uploaded radiographs and processed heatmaps
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
os.makedirs(settings.PROCESSED_DIR, exist_ok=True)

app.mount("/files/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")
app.mount("/files/processed", StaticFiles(directory=settings.PROCESSED_DIR), name="processed")

@app.get("/")
def read_root():
    return {
        "status": "online",
        "app": settings.PROJECT_NAME,
        "docs": "/docs",
        "health": "OK"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
