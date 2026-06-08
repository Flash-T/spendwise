/**
 * 导入账单页
 */

import router from '@ohos.router';

@Entry
@Component
struct ImportBillsPage {
  build() {
    Column() {
      // 顶部
      Row() {
        Text('←')
          .fontSize(24)
          .onClick(() => router.back());
        Blank();
        Text('导入账单')
          .fontSize(20)
          .fontWeight(FontWeight.Bold);
        Blank();
        Text('🔔')
          .fontSize(20);
      }
      .width('90%')
      .padding({ top: 16, bottom: 12 });

      Text('快速同步你的日常消费')
        .fontSize(14)
        .fontColor('#9999AA')
        .width('90%');

      // 平台入口
      Row() {
        ImportEntry('💬', '微信账单', '#4CAF50');
        ImportEntry('💳', '支付宝账单', '#4A90D9');
      }
      .width('90%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 20 });

      // 导入方式
      Column() {
        Text('导入方式')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ bottom: 12 });

        ImportMethod('📄', '文件导入', '从微信/支付宝导出的账单文件');
        ImportMethod('📸', '截图识别', '上传账单截图，AI自动提取');
        ImportMethod('📝', '粘贴文本', '复制粘贴账单文本内容');
      }
      .width('90%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ top: 16 });

      // 操作步骤
      Column() {
        Text('操作步骤')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ bottom: 12 });

        StepItem('1', '导出账单', '在微信/支付宝中导出交易记录');
        StepItem('2', '上传文件', '选择文件或截图上传');
        StepItem('3', 'AI自动分析', '智能识别并分类入账');
      }
      .width('90%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ top: 12 });

      // 开始导引
      Button('开始导引')
        .width('90%')
        .height(48)
        .backgroundColor('#4A90D9')
        .borderRadius(24)
        .fontColor('#FFFFFF')
        .fontSize(16)
        .margin({ top: 20, bottom: 12 });

      Blank();

      BottomNavBar({ activeIndex: 1 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .alignItems(HorizontalAlign.Center);
  }
}

@Component
struct ImportEntry {
  private icon: string = '';
  private label: string = '';
  private color: string = '#4A90D9';

  build() {
    Column() {
      Text(this.icon)
        .fontSize(36);
      Text(this.label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 8 });
    }
    .width('47%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(16);
  }
}

@Component
struct ImportMethod {
  private icon: string = '';
  private title: string = '';
  private desc: string = '';

  build() {
    Row() {
      Text(this.icon).fontSize(24);
      Column() {
        Text(this.title).fontSize(15).fontWeight(FontWeight.Medium);
        Text(this.desc).fontSize(12).fontColor('#9999AA');
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 });
      Blank();
      Text('→').fontColor('#CCCCCC').fontSize(18);
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 });
  }
}

@Component
struct StepItem {
  private num: string = '';
  private title: string = '';
  private desc: string = '';

  build() {
    Row() {
      Text(this.num)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width(24)
        .height(24)
        .backgroundColor('#4A90D9')
        .borderRadius(12)
        .textAlign(TextAlign.Center);
      Column() {
        Text(this.title).fontSize(14).fontWeight(FontWeight.Medium).margin({ left: 10 });
        Text(this.desc).fontSize(12).fontColor('#9999AA').margin({ left: 10 });
      }
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 });
  }
}

@Component
struct BottomNavBar {
  private activeIndex: number = 0;

  build() {
    Row() {
      NavItem('🏠', '首页', this.activeIndex === 0, () => router.replaceUrl({ url: 'pages/Home' }));
      NavItem('📋', '账单', this.activeIndex === 1, () => {});
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
