from supabase import create_client, Client
from app.config import settings

def get_supabase_client() -> Client:
    """
    Supabase istemcisini başlatır ve döndürür (Singleton erişim).
    """
    if not settings.SUPABASE_URL or not settings.SUPABASE_ANON_KEY:
        raise ValueError("SUPABASE_URL ve SUPABASE_ANON_KEY .env dosyasında tanımlı olmalıdır.")
    
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_ANON_KEY)