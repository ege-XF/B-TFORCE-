from fastapi import FastAPI
from src.Infrastructure.akademik_scraper import scrape_akademik_kadro

@app.get("/api/v1/akademisyenler")
def get_akademisyenler():
    data = scrape_akademik_kadro()
    return {"status": "success", "count": len(data), "data": data}