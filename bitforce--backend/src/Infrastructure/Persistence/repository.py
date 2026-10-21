from typing import List, Dict, Any
from supabase import Client
from src.Infrastructure.Persistence.supabase_client import get_supabase_client
from src.Core.Application.dtos.schemas import DuyuruCreate, HaberCreate

class SchoolRepository:
    def __init__(self, client: Client = None):
        self.client = client or get_supabase_client()

    # =========================================================================
    # 📢 DUYURU İŞLEMLERİ
    # =========================================================================

    def save_duyurular(self, duyurular: List[DuyuruCreate]) -> None:
        """
        Scraper tarafından çekilen duyuruları Supabase 'duyurular' tablosuna kaydeder / günceller.
        """
        data = [duyuru.model_dump() for duyuru in duyurular]
        if data:
            # baslik alanına göre çakışmayı önlemek için upsert mantığı
            self.client.from_("duyurular").upsert(data, on_conflict="baslik").execute()

    def get_duyurular(self, limit: int = 20) -> List[Dict[str, Any]]:
        """
        Veritabanındaki güncel duyuruları getirir.
        """
        response = self.client.from_("duyurular")\
            .select("*")\
            .order("id", desc=True)\
            .limit(limit)\
            .execute()
        return response.data or []

    # =========================================================================
    # 📰 HABER İŞLEMLERİ
    # =========================================================================

    def save_haberler(self, haberler: List[HaberCreate]) -> None:
        """
        Scraper tarafından çekilen haberleri Supabase 'haberler' tablosuna kaydeder / günceller.
        """
        data = [haber.model_dump() for haber in haberler]
        if data:
            self.client.from_("haberler").upsert(data, on_conflict="baslik").execute()

    def get_haberler(self, limit: int = 20) -> List[Dict[str, Any]]:
        """
        Veritabanındaki güncel haberleri getirir.
        """
        response = self.client.from_("haberler")\
            .select("*")\
            .order("id", desc=True)\
            .limit(limit)\
            .execute()
        return response.data or []