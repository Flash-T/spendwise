"""账单相关 API 路由"""

from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.api.users import get_current_user_id
from app.core.database import get_db
from app.models.bill import Bill
from app.models.user import User
from app.schemas.bill import (
    BillCreate,
    BillUpdate,
    BillResponse,
    BillListResponse,
    SpendingDecisionRequest,
    SpendingDecisionResponse,
    MonthlyReport,
)
from app.services.ai_service import ai_service

router = APIRouter(prefix="/api/bills", tags=["bills"])


@router.post("", response_model=BillResponse)
def create_bill(
    bill_in: BillCreate,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """添加账单"""
    bill = Bill(
        user_id=user_id,
        amount=bill_in.amount,
        category=bill_in.category,
        description=bill_in.description,
        bill_date=bill_in.bill_date or datetime.now(timezone.utc),
        bill_type=bill_in.bill_type,
    )
    
    # AI 自动打标签
    if ai_service.is_available():
        try:
            tag_result = ai_service.tag_bill(
                bill_in.description or bill_in.category,
                bill_in.amount,
                bill_in.category,
            )
            bill.ai_tag = tag_result.get("tag", "")
            bill.ai_comment = tag_result.get("comment", "")
        except Exception:
            bill.ai_tag = "想要"
    
    db.add(bill)
    db.commit()
    db.refresh(bill)
    return bill


@router.get("", response_model=BillListResponse)
def list_bills(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    category: Optional[str] = None,
    bill_type: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """获取账单列表（分页、筛选）"""
    query = db.query(Bill).filter(Bill.user_id == user_id)
    
    if category:
        query = query.filter(Bill.category == category)
    if bill_type:
        query = query.filter(Bill.bill_type == bill_type)
    if start_date:
        query = query.filter(Bill.bill_date >= datetime.fromisoformat(start_date))
    if end_date:
        query = query.filter(Bill.bill_date <= datetime.fromisoformat(end_date))
    
    total = query.count()
    items = query.order_by(Bill.bill_date.desc())\
                 .offset((page - 1) * page_size)\
                 .limit(page_size)\
                 .all()
    
    return BillListResponse(
        total=total,
        items=[BillResponse.model_validate(b) for b in items],
    )


@router.get("/{bill_id}", response_model=BillResponse)
def get_bill(
    bill_id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """获取单条账单"""
    bill = db.query(Bill).filter(
        Bill.id == bill_id,
        Bill.user_id == user_id,
    ).first()
    if not bill:
        raise HTTPException(status_code=404, detail="账单不存在")
    return bill


@router.put("/{bill_id}", response_model=BillResponse)
def update_bill(
    bill_id: int,
    bill_in: BillUpdate,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """修改账单"""
    bill = db.query(Bill).filter(
        Bill.id == bill_id,
        Bill.user_id == user_id,
    ).first()
    if not bill:
        raise HTTPException(status_code=404, detail="账单不存在")
    
    update_data = bill_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(bill, field, value)
    bill.updated_at = datetime.now(timezone.utc)
    
    db.commit()
    db.refresh(bill)
    return bill


@router.delete("/{bill_id}", status_code=204)
def delete_bill(
    bill_id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """删除账单"""
    bill = db.query(Bill).filter(
        Bill.id == bill_id,
        Bill.user_id == user_id,
    ).first()
    if not bill:
        raise HTTPException(status_code=404, detail="账单不存在")
    db.delete(bill)
    db.commit()


@router.post("/decide", response_model=SpendingDecisionResponse)
def decide_spending(
    request: SpendingDecisionRequest,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """'这笔钱该花吗?' — AI 决策"""
    user = db.query(User).filter(User.id == user_id).first()
    
    # 补充用户财务信息
    monthly_income = request.monthly_income or user.monthly_income or 0
    savings = request.savings or (user.monthly_income - user.fixed_expenses if user.monthly_income else 0)
    life_stage = user.life_stage or "office"
    
    if ai_service.is_available():
        result = ai_service.analyze_spending(
            item_name=request.item_name,
            price=request.price,
            category=request.category,
            reason=request.reason,
            monthly_income=monthly_income,
            savings=savings,
            life_stage=life_stage,
        )
    else:
        result = {
            "decision": "再想想",
            "reason": "AI 服务未配置，请设置 DEEPSEEK_API_KEY",
            "confidence": "low",
            "alternatives": ["设置 API Key 以获得 AI 建议"],
        }
    
    return SpendingDecisionResponse(
        decision=result.get("decision", "再想想"),
        reason=result.get("reason", ""),
        confidence=result.get("confidence", "medium"),
        alternatives=result.get("alternatives", []),
    )


@router.get("/report/monthly", response_model=MonthlyReport)
def monthly_report(
    year: int = Query(default=None),
    month: int = Query(default=None),
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """月度消费体检报告"""
    now = datetime.now(timezone.utc)
    year = year or now.year
    month = month or now.month
    
    user = db.query(User).filter(User.id == user_id).first()
    
    # 查询当月账单
    bills = db.query(Bill).filter(
        Bill.user_id == user_id,
        func.extract("year", Bill.bill_date) == year,
        func.extract("month", Bill.bill_date) == month,
    ).all()
    
    total_income = sum(b.amount for b in bills if b.bill_type == "income")
    total_expense = sum(b.amount for b in bills if b.bill_type == "expense")
    balance = total_income - total_expense
    
    # 分类支出占比
    category_amounts = {}
    for b in bills:
        if b.bill_type == "expense":
            category_amounts[b.category] = category_amounts.get(b.category, 0) + b.amount
    
    category_breakdown = {}
    if total_expense > 0:
        for cat, amt in sorted(category_amounts.items(), key=lambda x: -x[1]):
            category_breakdown[cat] = round(amt / total_expense * 100, 1)
    
    # 存钱目标完成率
    saving_goal_progress = 0.0
    if user and user.saving_goal and user.saving_goal > 0:
        current_savings = max(0, balance)
        saving_goal_progress = min(100, round(current_savings / user.saving_goal * 100, 1))
    
    # 最值得花 / 最不建议花（基于 AI 标签）
    best_spending = []
    worst_spending = []
    for b in bills:
        if b.bill_type == "expense":
            desc = b.description or b.category
            if b.ai_tag == "必要":
                best_spending.append(desc)
            elif b.ai_tag == "冲动":
                worst_spending.append(desc)
    
    # AI 建议
    ai_suggestion = ""
    if ai_service.is_available():
        report_data = {
            "total_income": total_income,
            "total_expense": total_expense,
            "balance": balance,
        }
        ai_suggestion = ai_service.generate_report_suggestion(report_data)
    else:
        ai_suggestion = "配置 DeepSeek API Key 后获取 AI 建议"
    
    return MonthlyReport(
        total_income=total_income,
        total_expense=total_expense,
        balance=balance,
        saving_goal_progress=saving_goal_progress,
        category_breakdown=category_breakdown,
        ai_suggestion=ai_suggestion,
        best_spending=best_spending[:3],
        worst_spending=worst_spending[:3],
    )
