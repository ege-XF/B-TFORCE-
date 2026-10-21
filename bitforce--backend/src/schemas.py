from pydantic import BaseModel
from typing import Optional

class AkademisyenSchema(BaseModel):
    unvan: str
    ad_soyad: str
    eposta: Optional[str] = None
    dahili_tel: Optional[str] = None
    oda_no: Optional[str] = None
    anabilim_dali: Optional[str] = None
    profil_foto: Optional[str] = None