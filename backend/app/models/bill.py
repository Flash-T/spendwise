"""账单模型"""

from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text

from app.core.database import Base


class Bill(Base):
    __tablename__ = "bills"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True, nullable=False)
    
    amount = Column(Float, nullable=False)               # 金额
    category = Column(String(30), nullable=False)         # 分类: 早餐/饮料/外卖/零食/交通/购物/游戏/书本/医疗/其他
    description = Column(Text, default="")                # 描述
    bill_date = Column(DateTime, default=lambda: datetime.now(timezone.utc))  # 消费日期
    bill_type = Column(String(10), default="expense")     # expense/income
    
    # AI 标签
    ai_tag = Column(String(50), default="")              # AI 判断标签: 必要/想要/冲动
    ai_comment = Column(Text, default="")                 # AI 评论
    
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
