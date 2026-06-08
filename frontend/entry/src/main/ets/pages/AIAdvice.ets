/**
 * AI 建议页 - "这笔钱该花吗？"
 */

import router from '@ohos.router';
import { decideSpending } from '../data/api';
import { BILL_CATEGORIES } from '../data/models';

@Entry
@Component
struct AIAdvicePage {
  @State itemName: string = '';
  @State price: string = '';
  @State category: number = 0;
  @State reason: string = '';
  @State showResult: boolean = false;
  @State decision: { decision: string; reason: string; alternatives: string[] } | null = null;
  @State loading: boolean = false;

  getDecisionColor(): string {
    switch (this.decision?.decision) {
      case '建议买': return '#4CAF50';
      case '再想想': return '#FF9800';
      case '别买': return '#FF5252';
      default: return '#4A90D9';
    }
  }

  async handleDecide() {
    if (!this.itemName || !this.price) return;
    this.loading = true;
    try {
      const result = await decideSpending(
        this.itemName,
        parseFloat(this.price),
        BILL_CATEGORIES[this.category] || '其他',
        this.reason
      );
      this.decision = result;
      this.showResult = true;
    } catch (e) {
      console.error('Decision failed:', JSON.stringify(e));
    }
    this.loading = false;
  }

  build() {
    Column() {
      // 顶部
      Row() {
        Text('←')
          .fontSize(24)
          .onClick(() => router.back());
        Blank();
        Text('🤖 AI 建议')
          .fontSize(20)
          .fontWeight(FontWeight.Bold);
        Blank();
        Text('').width(24);
      }
      .width('90%')
      .padding({ top: 16, bottom: 12 });

      Scroll() {
        Column() {
          if (!this.showResult) {
            // 输入区域
            Column() {
              Text('这笔钱该花吗？')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A2E');
              Text('买之前，先让AI帮你判断一下')
                .fontSize(14)
                .fontColor('#9999AA')
                .margin({ top: 4 });
            }
            .width('100%')
            .padding({ top: 20, bottom: 24 })
            .alignItems(HorizontalAlign.Center);

            // 商品名
            Text('商品名称')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .margin({ bottom: 6 });
            TextInput({ placeholder: '例如：索尼WH-1000XM5耳机' })
              .value(this.itemName)
              .onChange(v => this.itemName = v)
              .height(44)
              .backgroundColor('#F5F7FA')
              .borderRadius(10)
              .padding({ left: 12 })
              .margin({ bottom: 14 });

            // 价格
            Text('价格')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .margin({ bottom: 6 });
            TextInput({ placeholder: '例如：499' })
              .value(this.price)
              .onChange(v => this.price = v)
              .height(44)
              .backgroundColor('#F5F7FA')
              .borderRadius(10)
              .padding({ left: 12 })
              .type(InputType.Number)
              .margin({ bottom: 14 });

            // 分类
            Text('分类')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .width('100%').margin({ bottom: 6 });
            Row() {
              ForEach(BILL_CATEGORIES.slice(0, 6), (cat, idx) => {
                Text(cat)
                  .fontSize(12)
                  .fontColor(this.category === idx ? '#FFFFFF' : '#666680')
                  .backgroundColor(this.category === idx ? '#4A90D9' : '#F5F7FA')
                  .borderRadius(14)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .margin({ right: 6, bottom: 6 })
                  .onClick(() => this.category = idx);
              });
            }
            .flexWrap(FlexWrap.Wrap)
            .width('100%')
            .margin({ bottom: 14 });

            // 购买理由
            Text('购买理由（可选）')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .margin({ bottom: 6 });
            TextArea({ placeholder: '说说你为什么想买...' })
              .value(this.reason)
              .onChange(v => this.reason = v)
              .height(80)
              .backgroundColor('#F5F7FA')
              .borderRadius(10)
              .padding({ left: 12 })
              .margin({ bottom: 20 });

            // 按钮
            Button(this.loading ? 'AI分析中...' : '让AI判断一下')
              .width('100%')
              .height(48)
              .backgroundColor('#4A90D9')
              .borderRadius(24)
              .fontColor('#FFFFFF')
              .fontSize(16)
              .enabled(!!this.itemName && !!this.price && !this.loading)
              .onClick(() => this.handleDecide());
          } else {
            // 结果展示
            this.DecisionResult();
          }
        }
        .width('90%');
      }
      .width('90%');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .alignItems(HorizontalAlign.Center);
  }

  @Builder
  DecisionResult() {
    Column() {
      // 商品信息
      Row() {
        Text('📦')
          .fontSize(40);
        Column() {
          Text(this.itemName)
            .fontSize(18)
            .fontWeight(FontWeight.Bold);
          Text(`¥${this.price}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF5252');
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 });
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16);

      // AI 综合判断
      Column() {
        Row() {
          Text('🤖 AI综合判断')
            .fontSize(16)
            .fontWeight(FontWeight.Bold);
          Blank();
          Text(this.decision?.decision || '')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getDecisionColor())
            .backgroundColor(this.getDecisionColor() + '20')
            .borderRadius(12)
            .padding({ left: 12, right: 12, top: 4, bottom: 4 });
        }
        .width('100%');

        Text(this.decision?.reason || '')
          .fontSize(14)
          .fontColor('#666680')
          .width('100%')
          .margin({ top: 12 });
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ top: 12 });

      // 替代建议
      if (this.decision?.alternatives?.length) {
        Column() {
          Text('💡 AI替代建议')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 12 });

          ForEach(this.decision.alternatives, (alt) => {
            Row() {
              Text('•')
                .fontColor('#4A90D9')
                .fontSize(16);
              Text(alt)
                .fontSize(14)
                .fontColor('#666680')
                .margin({ left: 8 });
            }
            .width('100%')
            .margin({ bottom: 8 });
          });
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .margin({ top: 12 });
      }

      // 按钮
      Button('再问一个')
        .width('100%')
        .height(48)
        .backgroundColor('#4A90D9')
        .borderRadius(24)
        .fontColor('#FFFFFF')
        .fontSize(16)
        .margin({ top: 20 })
        .onClick(() => {
          this.showResult = false;
          this.itemName = '';
          this.price = '';
          this.reason = '';
        });
    }
    .width('100%');
  }
}
