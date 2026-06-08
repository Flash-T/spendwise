/**
 * SpendWise (该花吗) - 数据类型定义
 */

// 用户信息 / 财务画像
export interface UserProfile {
  id: number;
  username: string;
  email: string;
  monthlyIncome: number;
  fixedExpenses: number;
  savingGoal: number;
  debtAmount: number;
  lifeStage: string;
  avatarUrl: string;
}

// 账单
export interface Bill {
  id: number;
  userId: number;
  amount: number;
  category: string;
  description: string;
  billDate: string;
  billType: 'expense' | 'income';
  aiTag: string;
  aiComment: string;
}

// 首页数据
export interface HomeData {
  disposableIncome: number;
  dailyBudget: number;
  todayExpense: number;
  remainingBudget: number;
  aiTip: string;
  highRiskCategories: HighRiskCategory[];
}

export interface HighRiskCategory {
  category: string;
  amount: number;
}

// 消费决策
export interface SpendingDecision {
  decision: string;
  reason: string;
  confidence: string;
  alternatives: string[];
}

// 月度报告
export interface MonthlyReport {
  totalIncome: number;
  totalExpense: number;
  balance: number;
  savingGoalProgress: number;
  categoryBreakdown: Record<string, number>;
  aiSuggestion: string;
  bestSpending: string[];
  worstSpending: string[];
}

// 生活阶段
export const LIFE_STAGES = [
  { value: 'student', label: '学生' },
  { value: 'office', label: '刚工作' },
  { value: 'freelancer', label: '自由职业' },
];

// 账单分类列表
export const BILL_CATEGORIES = [
  '早餐', '午餐', '晚餐', '饮料', '外卖', '零食',
  '交通', '购物', '游戏', '书本', '医疗',
  '娱乐', '住房', '通讯', '其他'
];
