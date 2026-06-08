# SpendWise (该花吗？)

一个 AI 驱动的消费决策助手 App。

## 技术栈

- **前端**: ArkTS (鸿蒙原生)
- **后端**: Python FastAPI
- **AI**: DeepSeek API

## 项目结构

```
spendwise/
├── backend/
│   ├── app/
│   │   ├── api/        # API 路由
│   │   ├── core/       # 配置、安全等
│   │   ├── models/     # 数据库模型
│   │   ├── schemas/    # Pydantic 模型
│   │   └── services/   # 业务逻辑
│   ├── tests/
│   └── requirements.txt
├── frontend/           # 鸿蒙 ArkTS 项目
└── README.md
```

## 开发

```bash
# 后端
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload

# 前端 - 使用 DevEco Studio 打开 frontend/ 目录
```
