"""DeepSeek AI 服务"""

from typing import Optional

from openai import OpenAI

from app.core.config import settings


class AIService:
    """封装 DeepSeek API 调用"""
    
    def __init__(self):
        self.client = None
        if settings.deepseek_api_key:
            self.client = OpenAI(
                api_key=settings.deepseek_api_key,
                base_url=settings.deepseek_base_url,
            )
    
    def is_available(self) -> bool:
        return self.client is not None
    
    def _call(self, system_prompt: str, user_prompt: str) -> str:
        """调用 DeepSeek"""
        if not self.client:
            return "AI 服务未配置，请设置 DEEPSEEK_API_KEY"
        
        response = self.client.chat.completions.create(
            model=settings.deepseek_model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            temperature=0.7,
            max_tokens=1000,
        )
        return response.choices[0].message.content or ""
    
    def analyze_spending(self, item_name: str, price: float, category: str,
                         reason: str, monthly_income: float,
                         savings: float, life_stage: str) -> dict:
        """分析'这笔钱该花吗'"""
        system_prompt = """你是一个理性的消费顾问。请分析一笔消费是否需要，输出 JSON 格式：
{
  "decision": "建议买 | 再想想 | 别买",
  "reason": "详细理由（中文，50-150字）",
  "confidence": "high | medium | low",
  "alternatives": ["替代建议1", "替代建议2"]
}
"""
        user_prompt = f"""帮我分析这笔消费：
- 商品：{item_name}
- 价格：{price}元
- 分类：{category}
- 购买理由：{reason or '未说明'}
- 月收入：{monthly_income}元
- 当前储蓄：{savings}元
- 生活阶段：{life_stage}"""
        
        result = self._call(system_prompt, user_prompt)
        # 尝试解析 JSON
        import json
        try:
            # 查找 JSON 块
            json_str = result
            if "```json" in result:
                json_str = result.split("```json")[1].split("```")[0]
            elif "```" in result:
                json_str = result.split("```")[1].split("```")[0]
            return json.loads(json_str.strip())
        except (json.JSONDecodeError, IndexError):
            return {
                "decision": "再想想",
                "reason": result,
                "confidence": "medium",
                "alternatives": ["等发工资再考虑", "对比一下其他平台的价格"],
            }
    
    def tag_bill(self, item_name: str, amount: float, category: str) -> dict:
        """给一笔消费打 AI 标签"""
        system_prompt = """给这笔消费打标签，输出 JSON：
{
  "tag": "必要 | 想要 | 冲动",
  "comment": "简短评论（20字以内）"
}
"""
        user_prompt = f"消费：{item_name}，{amount}元，分类：{category}"
        
        result = self._call(system_prompt, user_prompt)
        import json
        try:
            json_str = result
            if "```json" in result:
                json_str = result.split("```json")[1].split("```")[0]
            elif "```" in result:
                json_str = result.split("```")[1].split("```")[0]
            return json.loads(json_str.strip())
        except (json.JSONDecodeError, IndexError):
            return {"tag": "想要", "comment": "合理消费"}
    
    def generate_report_suggestion(self, report_data: dict) -> str:
        """生成月度消费建议"""
        system_prompt = "你是一个贴心的理财顾问，给出简洁的月度消费建议（50-100字中文）。"
        user_prompt = f"用户本月数据：收入{report_data['total_income']}元，支出{report_data['total_expense']}元，结余{report_data['balance']}元。"
        
        return self._call(system_prompt, user_prompt)


ai_service = AIService()
