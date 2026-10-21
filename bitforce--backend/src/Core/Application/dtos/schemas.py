from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


# ===========================================================================
# 📢 DUYURU DTO'LARI
# ===========================================================================

class DuyuruBase(BaseModel):
    baslik: str = Field(..., description="Duyuru başlığı")
    gun: str = Field(..., description="Günü temsil eden string")
    ay: str = Field(..., description="Ayo temsil eden string")
    tarih_tam: Optional[str] = Field(None, description="Tam birleştirilmiş tarih")
    detay_html: Optional[str] = Field(None, description="Detay metni / HTML")


class DuyuruCreate(DuyuruBase):
    pass


class DuyuruResponse(DuyuruBase):
    id: int
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ===========================================================================
# 📰 HABER DTO'LARI
# ===========================================================================

class HaberBase(BaseModel):
    baslik: str = Field(..., description="Haber başlığı")
    gun: str = Field(..., description="Günü temsil eden string")
    ay: str = Field(..., description="Ayı temsil eden string")
    gorsel_url: Optional[str] = Field(None, description="Haber görsel adresi")
    detay_html: Optional[str] = Field(None, description="Haber detay metni")


class HaberCreate(HaberBase):
    pass


class HaberResponse(HaberBase):
    id: int
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ===========================================================================
# 📱 AKIŞ (FEED) DTO'SU
# ===========================================================================

class FeedResponse(BaseModel):
    duyurular: List[DuyuruResponse]
    haberler: List[HaberResponse]
    son_guncelleme: str