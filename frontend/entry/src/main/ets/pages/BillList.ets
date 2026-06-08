/**
 * 账单列表页 - 展示所有账单记录
 */

import router from '@ohos.router';
import { getBills, deleteBill } from '../data/api';
import { Bill } from '../data/models';
import { CategoryBadge } from '../components/CategoryIcon';

@Entry
@Component
struct BillListPage {
  @State bills: Bill[] = [];
  @State loading: boolean = true;
  @State selectedCategory: string = '';

  aboutToAppear() {
    this.loadBills();
  }

  async loadBills() {
    this.loading = true;
    try {
      const result = await getBills(1, this.selectedCategory || undefined);
      this.bills = result.items;
    } catch (e) {
      console.error('Failed to load bills:', JSON.stringify(e));
    }
    this.loading = false;
  }

  build() {
    Column() {
      // 顶部
      Row() {
        Text('📋 账单')
          .fontSize(20)
          .fontWeight(FontWeight.Bold);
        Blank();
        Button('+ 记一笔')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A90D9')
          .borderRadius(16)
          .height(32)
          .onClick(() => router.pushUrl({ url: 'pages/AddBill' }));
      }
      .width('90%')
      .padding({ top: 16, bottom: 12 });

      // 导入账单入口
      Row() {
        Text('📥 导入账单')
          .fontSize(14)
          .fontColor('#4A90D9');
        Text(' 快速同步微信/支付宝账单')
          .fontSize(12)
          .fontColor('#9999AA');
        Blank();
        Text('→')
          .fontColor('#4A90D9');
      }
      .width('90%')
      .padding(14)
      .backgroundColor('#E8F4FD')
      .borderRadius(12)
      .onClick(() => router.pushUrl({ url: 'pages/ImportBills' }));

      // 列表
      if (this.loading) {
        Text('加载中...')
          .margin({ top: 40 })
          .fontColor('#9999AA');
      } else if (this.bills.length === 0) {
        Text('暂无账单记录')
          .margin({ top: 40 })
          .fontColor('#9999AA');
      } else {
        Scroll() {
          Column() {
            ForEach(this.bills, (bill: Bill) => {
              BillItem({ bill });
            });
          }
          .width('100%');
        }
        .width('90%')
        .margin({ top: 12 });
      }

      Blank();

      // 底部导航
      BottomNavBar({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .alignItems(HorizontalAlign.Center);
  }
}

@Component
struct BillItem {
  private bill: Bill = {
    id: 0, userId: 0, amount: 0, category: '', description: '',
    billDate: '', billType: 'expense', aiTag: '', aiComment: ''
  };

  getTagColor(): string {
    switch (this.bill.aiTag) {
      case '必要': return '#E8F5E9';
      case '想要': return '#FFF3E0';
      case '冲动': return '#FFEBEE';
      default: return '#F5F7FA';
    }
  }

  getTagTextColor(): string {
    switch (this.bill.aiTag) {
      case '必要': return '#2E7D32';
      case '想要': return '#E65100';
      case '冲动': return '#C62828';
      default: return '#666680';
    }
  }

  build() {
    Row() {
      CategoryBadge({ category: this.bill.category, size: 36 });

      Column() {
        Text(this.bill.description || this.bill.category)
          .fontSize(15)
          .fontColor('#1A1A2E');
        Row() {
          Text(this.bill.aiTag || '未分类')
            .fontSize(11)
            .fontColor(this.getTagTextColor())
            .backgroundColor(this.getTagColor())
            .borderRadius(8)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 });
          if (this.bill.aiComment) {
            Text(this.bill.aiComment)
              .fontSize(11)
              .fontColor('#9999AA')
              .margin({ left: 6 });
          }
        }
        .margin({ top: 4 });
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 });

      Blank();

      Text(`${this.bill.billType === 'income' ? '+' : '-'}¥${this.bill.amount.toFixed(2)}`)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.bill.billType === 'income' ? '#4CAF50' : '#1A1A2E');
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 8 });
  }
}

@Component
struct BottomNavBar {
  private activeIndex: number = 0;

  build() {
    Row() {
      NavItem('🏠', '首页', this.activeIndex === 0,
        () => router.replaceUrl({ url: 'pages/Home' }));
      NavItem('📋', '账单', this.activeIndex === 1, () => {});
      NavItem('🤖', 'AI建议', this.activeIndex === 2,
        () => router.pushUrl({ url: 'pages/AIAdvice' }));
      NavItem('👤', '我的', this.activeIndex === 3,
        () => router.pushUrl({ url: 'pages/Profile' }));
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
      Text(this.label)
        .fontSize(11)
        .fontColor(this.active ? '#4A90D9' : '#9999AA');
    }
    .onClick(() => this.onClick());
  }
}
