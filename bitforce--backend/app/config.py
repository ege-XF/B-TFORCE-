import os
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List, Optional


class Settings(BaseSettings):
    # --- PROJE AYARLARI ---
    PROJECT_NAME: str = "ATÜ Bilişim MYO Backend API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"

    # --- CORS AYARLARI ---
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost",
        "http://localhost:8000",
        "http://127.0.0.1:8000",
        "http://localhost:3000",
        "*"
    ]

    # --- SUPABASE & AUTH AYARLARI ---
    SUPABASE_URL: str
    SUPABASE_ANON_KEY: str
    SUPABASE_SERVICE_ROLE_KEY: Optional[str] = ""
    SUPABASE_JWKS_URL: Optional[str] = ""
    SUPABASE_JWT_SECRET: str

    # --- BOT / SCRAPER AYARLARI ---
    TARGET_SCHOOL_URL: str = "https://bilisimtekmyo.atu.edu.tr/#/"
    SCRAPE_INTERVAL_MINUTES: int = 30
    VERI_DOSYASI_YOLU: str = "okul_verileri_akisi.json"

    # Pydantic .env yapılandırması
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


settings = Settings()