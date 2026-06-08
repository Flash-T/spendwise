"""用户模型"""

from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Float, DateTime, Text

from app.core.database import Base


class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    
    # 财务画像
    monthly_income = Column(Float, default=0.0)          # 月收入
    fixed_expenses = Column(Float, default=0.0)          # 固定支出
    saving_goal = Column(Float, default=0.0)             # 存钱目标
    debt_amount = Column(Float, default=0.0)             # 负债金额
    life_stage = Column(String(20), default="office")    # 生活阶段: student/office/freelancer
    
    # 基本信息
    avatar_url = Column(String(500), default="")
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
