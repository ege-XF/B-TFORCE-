import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
import threading
import time
import uvicorn
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from src.Presentation.API.v1.router import api_router
from src.Infrastructure.ExternalServices.okul_scraper import OkulScraperService
from src.Infrastructure.Persistence.repository import SchoolRepository


# =========================================================================
# 🔄 OTOMATİK ARKA PLAN BOT DÖNGÜSÜ
# =========================================================================

def _otomatik_bot_dizisi():
    repo = SchoolRepository()
    scraper = OkulScraperService()
    
    print(f"🚀 [OTOMASYON] Arka plan bot zamanlayıcısı aktif. (Aralık: {settings.SCRAPE_INTERVAL_MINUTES} dk)")
    
    while True:
        try:
            print(f"\n[{time.strftime('%Y-%m-%d %H:%M:%S')}] 🕷️ [OTOMATİK SCRAPER] Okul sistemi taranıyor...")
            veri = scraper.scrape_all()
            
            if veri["duyurular"]:
                repo.save_duyurular(veri["duyurular"])
                print(f"✅ {len(veri['duyurular'])} duyuru Supabase'e kaydedildi.")
                
            if veri["haberler"]:
                repo.save_haberler(veri["haberler"])
                print(f"✅ {len(veri['haberler'])} haber Supabase'e kaydedildi.")
                
        except Exception as e:
            print(f"❌ [OTOMATİK SCRAPER HATA]: {e}")
            
        bekleme_saniyesi = settings.SCRAPE_INTERVAL_MINUTES * 60
        time.sleep(bekleme_saniyesi)


# =========================================================================
# 🚀 FASTAPI LIFESPAN
# =========================================================================

@asynccontextmanager
async def lifespan(app: FastAPI):
    bot_thread = threading.Thread(target=_otomatik_bot_dizisi, daemon=True)
    bot_thread.start()
    yield


# =========================================================================
# 🏛️ FASTAPI UYGULAMASI
# =========================================================================

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/", summary="Sistem Durum Kontrolü")
def root():
    return {
        "status": "online",
        "message": f"{settings.PROJECT_NAME} sorunsuz çalışıyor.",
        "docs": "/docs"
    }


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)