/**
 * 快速记一笔 - 添加账单
 */

import router from '@ohos.router';
import { createBill } from '../data/api';
import { BILL_CATEGORIES } from '../data/models';
import { CategorySelector, QUICK_CATEGORIES, CategoryIcon } from '../components/CategoryIcon';

@Entry
@Component
struct AddBillPage {
  @State amount: string = '';
  @State description: string = '';
  @State selectedCategory: number = 0;
  @State billType: string = 'expense';
  @State saving: boolean = false;

  async handleSave() {
    if (!this.amount || parseFloat(this.amount) <= 0) return;
    this.saving = true;
    try {
      await createBill({
        amount: parseFloat(this.amount),
        category: BILL_CATEGORIES[this.selectedCategory] || '其他',
        description: this.description,
      });
      router.back();
    } catch (e) {
      console.error('Save bill failed:', JSON.stringify(e));
    }
    this.saving = false;
  }

  build() {
    Column() {
      // 顶部
      Row() {
        Text('←')
          .fontSize(24)
          .onClick(() => router.back());
        Blank();
        Text('快速记一笔')
          .fontSize(20)
          .fontWeight(FontWeight.Bold);
        Blank();
        Text('🕐')
          .fontSize(24);
      }
      .width('90%')
      .padding({ top: 16, bottom: 12 });

      // AI智能识别
      Column() {
        Row() {
          Text('✨ AI智能识别')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#4A90D9');
          Text(' 支持自然语言输入，自动识别金额和分类')
            .fontSize(12)
            .fontColor('#9999AA');
        }
        .width('100%');

        TextInput({
          placeholder: '例如：午餐18元、打车去公司花了25...'
        })
          .value(this.description)
          .onChange(v => this.description = v)
          .height(44)
          .backgroundColor('#F5F7FA')
          .borderRadius(10)
          .padding({ left: 12 })
          .margin({ top: 8 });
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#FFFFFF')
      .borderRadius(16);

      // 快捷录入
      Text('快捷录入')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ top: 16, bottom: 8 });

      Row() {
        QuickTypeBtn('支出', '#FF5252', this.billType === 'expense', () => this.billType = 'expense');
        QuickTypeBtn('收入', '#4CAF50', this.billType === 'income', () => this.billType = 'income');
        QuickTypeBtn('转账', '#4A90D9', false, () => {});
        QuickTypeBtn('退款', '#FF9800', false, () => {});
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);

      // 金额
      TextInput({ placeholder: '输入金额' })
        .value(this.amount)
        .onChange(v => this.amount = v)
        .height(48)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .padding({ left: 12 })
        .type(InputType.Number)
        .margin({ top: 12 });

      // 选择分类
      Text('选择分类')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .margin({ top: 16, bottom: 8 });

      // 快捷分类行
      Row() {
        ForEach(QUICK_CATEGORIES.slice(0, 4), (cat) => {
          Column() {
            CategoryIcon({ category: cat, size: 44 });
            Text(cat)
              .fontSize(11)
              .fontColor('#666680')
              .margin({ top: 2 });
          }
          .onClick(() => {
            this.selectedCategory = BILL_CATEGORIES.indexOf(cat);
          });
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 8 });

      Row() {
        ForEach(QUICK_CATEGORIES.slice(4, 8), (cat) => {
          Column() {
            CategoryIcon({ category: cat, size: 44 });
            Text(cat)
              .fontSize(11)
              .fontColor('#666680')
              .margin({ top: 2 });
          }
          .onClick(() => {
            this.selectedCategory = BILL_CATEGORIES.indexOf(cat);
          });
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);

      Blank();

      // 保存
      Button(this.saving ? '保存中...' : '保存')
        .width('100%')
        .height(48)
        .backgroundColor('#4A90D9')
        .borderRadius(24)
        .fontColor('#FFFFFF')
        .fontSize(16)
        .enabled(!!this.amount && !this.saving)
        .onClick(() => this.handleSave());

      // 底部导航
      BottomNavBar({ activeIndex: 0 });
    }
    .width('90%')
    .height('100%')
    .backgroundColor('#F5F7FA');
  }
}

@Component
struct QuickTypeBtn {
  private label: string = '';
  private color: string = '#4A90D9';
  private active: boolean = false;
  private onClick: () => void = () => {};

  build() {
    Column() {
      Text(this.label)
        .fontSize(13)
        .fontColor(this.active ? '#FFFFFF' : this.color);
    }
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(this.active ? this.color : '#FFFFFF')
    .borderRadius(16)
    .border({ width: 1, color: this.active ? this.color : '#E0E0E0' })
    .onClick(() => this.onClick());
  }
}

@Component
struct CategoryBtn {
  private label: string = '';
  private active: boolean = false;
  private onClick: () => void = () => {};

  build() {
    Column() {
      Text(this.label)
        .fontSize(13)
        .fontColor(this.active ? '#FFFFFF' : '#666680');
    }
    .padding({ left: 20, right: 20, top: 8, bottom: 8 })
    .backgroundColor(this.active ? '#4A90D9' : '#F5F7FA')
    .borderRadius(14)
    .onClick(() => this.onClick());
  }
}

@Component
struct BottomNavBar {
  private activeIndex: number = 0;

  build() {
    Row() {
      NavItem('🏠', '首页', this.activeIndex === 0, () => router.replaceUrl({ url: 'pages/Home' }));
      NavItem('📋', '账单', this.activeIndex === 1, () => router.replaceUrl({ url: 'pages/BillList' }));
      NavItem('🤖', 'AI建议', this.activeIndex === 2, () => router.replaceUrl({ url: 'pages/AIAdvice' }));
      NavItem('👤', '我的', this.activeIndex === 3, () => router.replaceUrl({ url: 'pages/Profile' }));
    }
    .width('100%')
    .height(64)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ bottom: 8 });
  }
}

@Component
struct NavItem {
  private icon: string = '';
  private label: string = '';
  private active: boolean = false;
  private onClick: () => void = () => {};

  build() {
    Column() {
      Text(this.icon).fontSize(22);
      Text(this.label).fontSize(11).fontColor(this.active ? '#4A90D9' : '#9999AA');
    }
    .onClick(() => this.onClick());
  }
}
