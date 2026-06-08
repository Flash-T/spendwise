/**
 * 首页看板
 */

import router from '@ohos.router';
import { getHomeData, getProfile, setToken, getToken } from '../data/api';
import { HomeData, UserProfile } from '../data/models';
import { CategoryBadge } from '../components/CategoryIcon';

@Entry
@Component
struct HomePage {
  @State homeData: HomeData | null = null;
  @State user: UserProfile | null = null;
  @State loading: boolean = true;

  aboutToAppear() {
    this.loadData();
  }

  async loadData() {
    try {
      const [home, profile] = await Promise.all([
        getHomeData(),
        getProfile()
      ]);
      this.homeData = home;
      this.user = profile;
    } catch (e) {
      console.error('Load failed:', JSON.stringify(e));
    }
    this.loading = false;
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Column() {
          Text('SpendWise')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A2E');
          Text('AI 消费决策助手')
            .fontSize(12)
            .fontColor('#9999AA');
        }
        .alignItems(HorizontalAlign.Start);

        Blank();

        Text(this.homeData?.aiTip ? '💡' : '☀️')
          .fontSize(24);
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16 });

      // 早安提示
      Row() {
        Text('☀️ 早上好，今天也要理性消费哦')
          .fontSize(13)
          .fontColor('#4A90D9')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 });
      }
      .backgroundColor('#E8F4FD')
      .borderRadius(20)
      .margin({ top: 12, left: 20, right: 20 })
      .width('90%');

      // 可支配金额卡片
      Column() {
        Text('今日可自由支配金额')
          .fontSize(14)
          .fontColor('#9999AA');
        Text(this.homeData ? `¥${this.homeData.disposableIncome.toFixed(2)}` : '--')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A2E')
          .margin({ top: 4 });
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ top: 16 })
      .shadow({ radius: 8, color: '#10000000', offsetY: 2 });

      // 支出统计行
      Row() {
        StatCard('本月已支出', this.homeData?.todayExpense ?? 0, '#FF5252');
        Blank();
        StatCard('建议今日不超', this.homeData?.dailyBudget ?? 0, '#4CAF50');
      }
      .width('90%')
      .margin({ top: 12 });

      // 高风险支出
      if (this.homeData?.highRiskCategories?.length) {
        Column() {
          Text('⚠️ 高风险支出')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 10 });

          ForEach(this.homeData.highRiskCategories, (item) => {
            Row() {
              CategoryBadge({ category: item.category, size: 32 });
              Column() {
                Text(item.category)
                  .fontSize(14)
                  .fontColor('#1A1A2E');
                Text(`¥${item.amount}`)
                  .fontSize(12)
                  .fontColor('#FF5252');
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 10 });

              Blank();

              Text('超出建议')
                .fontSize(12)
                .fontColor('#FF9800');
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 });
          });
        }
        .width('90%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .margin({ top: 12 });
      }

      // AI 建议
      if (this.homeData?.aiTip) {
        Row() {
          Text('🤖 AI今日建议')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#4A90D9');
          Blank();
          Text('→')
            .fontSize(18)
            .fontColor('#4A90D9');
        }
        .width('90%')
        .padding(16)
        .backgroundColor('#E8F4FD')
        .borderRadius(16)
        .margin({ top: 12 });
      }

      Blank();

      // 底部导航
      BottomNavBar({ activeIndex: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .alignItems(HorizontalAlign.Center);
  }
}

@Component
struct StatCard {
  private label: string = '';
  private amount: number = 0;
  private color: string = '#4A90D9';

  build() {
    Column() {
      Text(this.label)
        .fontSize(12)
        .fontColor('#9999AA');
      Text(`¥${this.amount.toFixed(2)}`)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.color)
        .margin({ top: 4 });
    }
    .width('47%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16);
  }
}

@Component
struct BottomNavBar {
  private activeIndex: number = 0;

  build() {
    Row() {
      NavItem('🏠', '首页', this.activeIndex === 0, () => {});
      NavItem('📋', '账单', this.activeIndex === 1,
        () => router.pushUrl({ url: 'pages/BillList' }));
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
      Text(this.icon)
        .fontSize(22);
      Text(this.label)
        .fontSize(11)
        .fontColor(this.active ? '#4A90D9' : '#9999AA');
    }
    .onClick(() => this.onClick());
  }
}
