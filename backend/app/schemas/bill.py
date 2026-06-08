"""Pydantic schemas — 账单"""

from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel, Field


class BillCreate(BaseModel):
    amount: float = Field(gt=0)
    category: str = Field(min_length=1, max_length=30)
    description: str = ""
    bill_date: Optional[datetime] = None
    bill_type: str = "expense"


class BillUpdate(BaseModel):
    amount: Optional[float] = None
    category: Optional[str] = None
    description: Optional[str] = None
    bill_date: Optional[datetime] = None
    bill_type: Optional[str] = None


class BillResponse(BaseModel):
    id: int
    user_id: int
    amount: float
    category: str
    description: str
    bill_date: datetime
    bill_type: str
    ai_tag: str
    ai_comment: str
    created_at: datetime
    
    model_config = {"from_attributes": True}


class BillListResponse(BaseModel):
    total: int
    items: List[BillResponse]


class SpendingDecisionRequest(BaseModel):
    """'这笔钱该花吗?' 请求"""
    item_name: str = Field(min_length=1, max_length=200)
    price: float = Field(gt=0)
    category: str = Field(default="其他", max_length=30)
    reason: str = ""
    monthly_income: Optional[float] = None
    savings: Optional[float] = None


class SpendingDecisionResponse(BaseModel):
    decision: str          # 建议买 / 再想想 / 别买
    reason: str            # 详细理由
    confidence: str        # high / medium / low
    alternatives: list[str] = []   # 替代建议


class MonthlyReport(BaseModel):
    total_income: float
    total_expense: float
    balance: float
    saving_goal_progress: float     # 存钱目标完成率 %
    category_breakdown: dict        # 分类支出占比
    ai_suggestion: str              # AI 建议
    best_spending: list[str]        # 最值得花
    worst_spending: list[str]       # 最不建议花
