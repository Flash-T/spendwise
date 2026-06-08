/**
 * 消费分类图标组件
 * 根据分类名称显示对应的彩色图标
 */

// 分类图标配置
export interface CategoryIconInfo {
  name: string;       // 分类名称
  icon: string;       // 显示的图标字符
  color: string;      // 主色
  bgColor: string;    // 背景色
}

export const CATEGORY_CONFIG: CategoryIconInfo[] = [
  { name: '早餐', icon: '🌅', color: '#FF6B35', bgColor: '#FFF0E8' },
  { name: '午餐', icon: '🍱', color: '#FF8C42', bgColor: '#FFF3E8' },
  { name: '晚餐', icon: '🍜', color: '#E67E22', bgColor: '#FDF0E6' },
  { name: '饮料', icon: '🧋', color: '#8B5CF6', bgColor: '#F3EEFF' },
  { name: '外卖', icon: '📦', color: '#FF6B6B', bgColor: '#FFEEEE' },
  { name: '零食', icon: '🍿', color: '#F472B6', bgColor: '#FCE7F3' },
  { name: '交通', icon: '🚇', color: '#3B82F6', bgColor: '#E8F0FE' },
  { name: '购物', icon: '🛍️', color: '#EC4899', bgColor: '#FCE7F3' },
  { name: '游戏', icon: '🎮', color: '#8B5CF6', bgColor: '#F3EEFF' },
  { name: '书本', icon: '📚', color: '#10B981', bgColor: '#E8F5E9' },
  { name: '医疗', icon: '🏥', color: '#EF4444', bgColor: '#FFEBEE' },
  { name: '娱乐', icon: '🎬', color: '#F59E0B', bgColor: '#FFF8E1' },
  { name: '住房', icon: '🏠', color: '#6366F1', bgColor: '#EEF2FF' },
  { name: '通讯', icon: '📱', color: '#06B6D4', bgColor: '#E0F7FA' },
  { name: '数码', icon: '💻', color: '#1E293B', bgColor: '#F1F5F9' },
  { name: '服饰', icon: '👔', color: '#8B5CF6', bgColor: '#F3EEFF' },
  { name: '美容', icon: '💄', color: '#EC4899', bgColor: '#FCE7F3' },
  { name: '宠物', icon: '🐾', color: '#F97316', bgColor: '#FFF7ED' },
  { name: '运动', icon: '⚽', color: '#22C55E', bgColor: '#F0FDF4' },
  { name: '旅行', icon: '✈️', color: '#0EA5E9', bgColor: '#E0F2FE' },
  { name: '其他', icon: '📦', color: '#94A3B8', bgColor: '#F1F5F9' },
];

export function getCategoryConfig(name: string): CategoryIconInfo {
  return CATEGORY_CONFIG.find(c => c.name === name) || CATEGORY_CONFIG[CATEGORY_CONFIG.length - 1];
}

@Component
export struct CategoryIcon {
  private category: string = '其他';
  private size: number = 40;
  private showLabel: boolean = false;

  build() {
    const config = getCategoryConfig(this.category);
    Column() {
      // 圆形图标
      Text(config.icon)
        .fontSize(this.size * 0.45)
        .width(this.size)
        .height(this.size)
        .backgroundColor(config.bgColor)
        .borderRadius(this.size / 2)
        .textAlign(TextAlign.Center)
        .lineHeight(this.size);

      if (this.showLabel) {
        Text(this.category)
          .fontSize(11)
          .fontColor('#666680')
          .margin({ top: 4 })
          .textAlign(TextAlign.Center)
          .width(this.size + 10);
      }
    }
    .alignItems(HorizontalAlign.Center);
  }
}

@Component
export struct CategoryBadge {
  private category: string = '其他';
  private size: number = 32;

  build() {
    const config = getCategoryConfig(this.category);
    Text(config.icon)
      .fontSize(this.size * 0.45)
      .width(this.size)
      .height(this.size)
      .backgroundColor(config.bgColor)
      .borderRadius(this.size / 2)
      .textAlign(TextAlign.Center)
      .lineHeight(this.size);
  }
}

@Component
export struct CategoryGrid {
  private selectedCategory: string = '';
  private onSelect: (category: string) => void = () => {};
  private showAll: boolean = true;

  build() {
    Column() {
      ForEach(CATEGORY_CONFIG, (config) => {
        if (this.showAll || config.name !== '其他') {
          Column() {
            CategoryIcon({ category: config.name, size: 44, showLabel: true });
          }
          .padding(8)
          .backgroundColor(this.selectedCategory === config.name ? '#E8F4FD' : 'transparent')
          .borderRadius(12)
          .onClick(() => this.onSelect(config.name));
        }
      });
    }
    .width('100%');
  }
}

@Component
export struct CategorySelector {
  private categories: string[];
  private selected: string = '';
  private onSelect: (category: string) => void = () => {};
  private columns: number = 4;

  build() {
    Column() {
      // 按列数分组展示
      ForEach(this.categories, (cat, idx) => {
        if (idx % this.columns === 0) {
          Row() {
            ForEach([0, 1, 2, 3], (offset) => {
              const i = idx + offset;
              if (i < this.categories.length) {
                Column() {
                  CategoryIcon({ category: this.categories[i], size: 48, showLabel: true });
                }
                .width(1 / this.columns * 100 + '%')
                .alignItems(HorizontalAlign.Center)
                .padding(6)
                .onClick(() => this.onSelect(this.categories[i]));
              }
            });
          }
          .width('100%')
          .margin({ bottom: 8 });
        }
      });
    }
    .width('100%');
  }
}

// 常用的分类子集
export const QUICK_CATEGORIES = ['早餐', '午餐', '晚餐', '饮料', '外卖', '零食', '交通', '购物'];
export const ALL_CATEGORIES = CATEGORY_CONFIG.map(c => c.name);
