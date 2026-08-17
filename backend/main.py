# backend/main.py

from fastapi import FastAPI, HTTPException, Depends
from fastapi.responses import RedirectResponse
from sqlalchemy.orm import Session
from pydantic import BaseModel
import random
import string
import models
from database import engine, get_db

# Create tables on startup
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="URL Shortener API", version="1.0.0")


# Request / Response Models


class ShortenRequest(BaseModel):
    url: str

class URLResponse(BaseModel):
    short_code:   str
    original_url: str
    short_url:    str
    click_count:  int


# Helper


def generate_code(length=6) -> str:
    chars = string.ascii_letters + string.digits
    return ''.join(random.choices(chars, k=length))


# Routes


@app.get("/health")
def health_check():
    return {
        "status":  "healthy",
        "service": "url-shortener-api"
    }


@app.post("/shorten", response_model=URLResponse)
def shorten_url(request: ShortenRequest, db: Session = Depends(get_db)):

    # Generate unique short code
    code = generate_code()
    while db.query(models.URL).filter(models.URL.short_code == code).first():
        code = generate_code()

    # Save to database
    url_entry = models.URL(
        short_code   = code,
        original_url = request.url,
        click_count  = 0
    )
    db.add(url_entry)
    db.commit()
    db.refresh(url_entry)

    # Build short URL using request host
    short_url = f"http://localhost/{code}"

    return URLResponse(
        short_code   = url_entry.short_code,
        original_url = url_entry.original_url,
        short_url    = short_url,
        click_count  = 0
    )


@app.get("/urls")
def list_all_urls(db: Session = Depends(get_db)):
    urls = db.query(models.URL).all()

    return {
        "total": len(urls),
        "urls": [
            {
                "short_code"  : u.short_code,
                "original_url": u.original_url,
                "short_url"   : f"http://localhost/{u.short_code}",
                "click_count" : u.click_count,
                "created_at"  : u.created_at
            }
            for u in urls
        ]
    }


@app.get("/{short_code}")
def redirect_to_url(short_code: str, db: Session = Depends(get_db)):

    url_entry = db.query(models.URL)\
                  .filter(models.URL.short_code == short_code)\
                  .first()

    if not url_entry:
        raise HTTPException(status_code=404, detail="Short URL not found")

    # Increment click count
    url_entry.click_count += 1
    db.commit()

    return RedirectResponse(url=url_entry.original_url)