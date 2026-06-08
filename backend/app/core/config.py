from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    app_name: str = "SpendWise"
    debug: bool = True
    
    # Database
    database_url: str = "sqlite:///./spendwise.db"
    
    # DeepSeek API
    deepseek_api_key: Optional[str] = None
    deepseek_base_url: str = "https://api.deepseek.com/v1"
    deepseek_model: str = "deepseek-chat"
    
    # JWT
    secret_key: str = "your-secret-key-change-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 24 * 30  # 30 days
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
