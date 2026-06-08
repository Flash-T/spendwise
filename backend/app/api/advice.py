"""AI 建议页面 API"""

from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.api.users import get_current_user_id
from app.core.database import get_db
from app.models.bill import Bill
from app.models.user import User
from app.services.ai_service import ai_service

router = APIRouter(prefix="/api/advice", tags=["advice"])


@router.get("/daily")
def daily_advice(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """获取今日 AI 建议"""
    user = db.query(User).filter(User.id == user_id).first()
    
    # 今日已消费
    today_start = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
    today_expense = db.query(func.coalesce(func.sum(Bill.amount), 0)).filter(
        Bill.user_id == user_id,
        Bill.bill_type == "expense",
        Bill.bill_date >= today_start,
    ).scalar()
    
    # 可自由支配金额
    disposable = max(0, (user.monthly_income or 0) - (user.fixed_expenses or 0))
    daily_budget = round(disposable / 30, 2) if disposable > 0 else 0
    
    # 高风险支出类目
    high_risk_categories = []
    if user.monthly_income:
        category_totals = db.query(
            Bill.category, func.sum(Bill.amount).label("total")
        ).filter(
            Bill.user_id == user_id,
            Bill.bill_type == "expense",
            func.strftime("%Y-%m", Bill.bill_date) == datetime.now(timezone.utc).strftime("%Y-%m"),
        ).group_by(Bill.category).all()
        
        for cat, total in category_totals:
            if total > user.monthly_income * 0.15:
                high_risk_categories.append({"category": cat, "amount": round(total, 2)})
    
    # AI 今日建议
    ai_tip = ""
    if ai_service.is_available():
        prompt = f"用户今日已消费{today_expense}元，每日预算{daily_budget}元。给出1句简短的消费提醒。"
        ai_tip = ai_service._call("你是一个体贴的理财顾问，给出简短建议。", prompt)[:100]
    
    return {
        "disposable_income": disposable,
        "daily_budget": daily_budget,
        "today_expense": round(today_expense, 2),
        "remaining_budget": round(max(0, daily_budget - today_expense), 2),
        "ai_tip": ai_tip or "理性消费，量入为出 💪",
        "high_risk_categories": high_risk_categories[:3],
    }
