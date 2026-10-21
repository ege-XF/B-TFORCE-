import time
from typing import List, Dict, Any


class OkulScraperService:
    def __init__(self):
        self.base_url = "https://bilisimtekmyo.atu.edu.tr"

    def scrape_akademik_kadro(self) -> List[Dict[str, Any]]:
        return []

    def scrape_all(self) -> Dict[str, Any]:
        return {
            "duyurular": [],
            "haberler": [],
            "akademisyenler": self.scrape_akademik_kadro()
        }