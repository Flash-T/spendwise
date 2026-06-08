"""Pydantic schemas — 用户"""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class UserCreate(BaseModel):
    username: str = Field(min_length=2, max_length=50)
    email: str = Field(min_length=5, max_length=100)
    password: str = Field(min_length=6, max_length=128)


class UserLogin(BaseModel):
    username: str
    password: str


class UserProfileUpdate(BaseModel):
    monthly_income: Optional[float] = None
    fixed_expenses: Optional[float] = None
    saving_goal: Optional[float] = None
    debt_amount: Optional[float] = None
    life_stage: Optional[str] = None
    avatar_url: Optional[str] = None


class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    monthly_income: float
    fixed_expenses: float
    saving_goal: float
    debt_amount: float
    life_stage: str
    avatar_url: str
    created_at: datetime
    
    model_config = {"from_attributes": True}


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
