import time
from typing import List, Dict, Any
from fastapi import APIRouter, BackgroundTasks

from src.Core.Application.dtos.schemas import DuyuruResponse, HaberResponse, FeedResponse
from src.Infrastructure.Persistence.repository import SchoolRepository

# Scraper servisi varsa içe aktar, yoksa çökmesini engelle
try:
    from src.Infrastructure.ExternalServices.okul_scraper import OkulScraperService
except ImportError:
    OkulScraperService = None

api_router = APIRouter()
repo = SchoolRepository()

# ATÜ BİLİŞİM MYO GERÇEK AKADEMİK KADRO LİSTESİ
AKADEMISYENLER_SEED = [
    {"unvan": "Öğr. Gör.", "ad_soyad": "Sami HEYBET", "eposta": "sheybet@atu.edu.tr", "orcid_id": "0000-0001-9063-3415", "arastirmaci_id": "417995", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Nuran MEMİLİ", "eposta": "nmemili@atu.edu.tr", "orcid_id": "-", "arastirmaci_id": "31773", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Yiğit ALİŞAN", "eposta": "yalisan@atu.edu.tr", "orcid_id": "0000-0003-2943-7743", "arastirmaci_id": "337396", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Enver Kaan ALPTÜRK", "eposta": "ekalpturk@atu.edu.tr", "orcid_id": "0000-0002-5158-5825", "arastirmaci_id": "418089", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Betül ERDEN", "eposta": "berden@atu.edu.tr", "orcid_id": "0000-0002-5945-2541", "arastirmaci_id": "310752", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Gözde NERGİZ", "eposta": "gnergiz@atu.edu.tr", "orcid_id": "0000-0001-5018-2031", "arastirmaci_id": "404519", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Gamze AYYILDIZ DOĞANSOY", "eposta": "gayyildiz@atu.edu.tr", "orcid_id": "0000-0001-9902-4739", "arastirmaci_id": "426012", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Mustafa DEMİRBİLEK", "eposta": "mdemirbilek@atu.edu.tr", "orcid_id": "0000-0003-4219-3288", "arastirmaci_id": "156509", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Umut Ahmet ÇETİN", "eposta": "uacetin@atu.edu.tr", "orcid_id": "0000-0001-8755-4417", "arastirmaci_id": "434498", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Mustafa PEKDEMİR", "eposta": "mpekdemir@atu.edu.tr", "orcid_id": "-", "arastirmaci_id": "434618", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Nihal Gülşah KÖROĞLU", "eposta": "nkoroglu@atu.edu.tr", "orcid_id": "0009-0003-5443-7822", "arastirmaci_id": "427488", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Hatice GÜÇLÜ", "eposta": "hguclu@atu.edu.tr", "orcid_id": "0000-0002-8191-6939", "arastirmaci_id": "379483", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Furkan SAY", "eposta": "fsay@atu.edu.tr", "orcid_id": "0009-0003-8086-2873", "arastirmaci_id": "450917", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Merve ÜNAL", "eposta": "merveunal@atu.edu.tr", "orcid_id": "0009-0008-6179-6096", "arastirmaci_id": "444872", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"},
    {"unvan": "Öğr. Gör.", "ad_soyad": "Raziye AKTAŞ", "eposta": "raktas@atu.edu.tr", "orcid_id": "-", "arastirmaci_id": "452029", "dahili_tel": "-", "oda_no": "BMYO", "anabilim_dali": "Bilişim Teknolojileri"}
]

@api_router.get("/akademisyenler", summary="Akademik Kadro Rehberi")
def get_akademisyenler():
    cadre = []
    if hasattr(repo, "get_akademisyenler"):
        try:
            cadre = repo.get_akademisyenler()
        except Exception:
            cadre = []

    if not cadre:
        cadre = AKADEMISYENLER_SEED

    return {
        "status": "success",
        "count": len(cadre),
        "data": cadre
    }