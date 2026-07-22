import os

class Settings:
    PROJECT_NAME: str = "Dental Root Resorption Analysis API"
    API_V1_STR: str = "/api/v1"
    
    # Database Connection
    # Default to a local SQLite database for easy out-of-the-box execution
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./dental_root_analysis.db")
    
    # Secret key for simple JWT signing (optional placeholder for authentication token generation)
    SECRET_KEY: str = os.getenv("SECRET_KEY", "SUPER_SECRET_DENTAL_KEY_123456789")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7 # 7 days
    
    # Storage folders
    UPLOAD_DIR: str = "uploads"
    PROCESSED_DIR: str = "processed"
    REPORTS_DIR: str = "reports"

settings = Settings()

# Make sure storage directories exist
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
os.makedirs(settings.PROCESSED_DIR, exist_ok=True)
os.makedirs(settings.REPORTS_DIR, exist_ok=True)

