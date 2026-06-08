/**
 * 消费体检报告页
 */

import router from '@ohos.router';
import { getMonthlyReport } from '../data/api';
import { MonthlyReport } from '../data/models';

@Entry
@Component
struct ReportPage {
  @State report: MonthlyReport | null = null;
  @State loading: boolean = true;

  aboutToAppear() {
    this.loadReport();
  }

  async loadReport() {
    try {
      this.report = await getMonthlyReport();
    } catch (e) {
      console.error('Load report failed:', JSON.stringify(e));
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
        Text('📊 消费体检报告')
          .fontSize(20)
          .fontWeight(FontWeight.Bold);
        Blank();
        Text('').width(24);
      }
      .width('90%')
      .padding({ top: 16, bottom: 12 });

      Scroll() {
        Column() {
          Text('AI 为你总结这个月的花钱情况')
            .fontSize(14)
            .fontColor('#9999AA')
            .width('100%');

          if (this.report) {
            // 收支概况
            Row() {
              StatBlock('本月收入', `¥${this.report.totalIncome.toFixed(0)}`, '#4CAF50');
              StatBlock('本月支出', `¥${this.report.totalExpense.toFixed(0)}`, '#FF5252');
              StatBlock('本月结余', `¥${this.report.balance.toFixed(0)}`, '#4A90D9');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ top: 12 });

            // 存钱目标
            Column() {
              Text('🎯 存钱目标')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .margin({ bottom: 10 });
              Row() {
                Column() {
                  Text(`${this.report.savingGoalProgress.toFixed(0)}%`)
                    .fontSize(28)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#4CAF50');
                  Text('完成率')
                    .fontSize(12)
                    .fontColor('#9999AA');
                }
                .alignItems(HorizontalAlign.Center)
                .width('40%');

                Column() {
                  // 进度条
                  Column() {
                    Column()
                      .width(`${Math.min(this.report.savingGoalProgress, 100)}%`)
                      .height('100%')
                      .backgroundColor('#4CAF50')
                      .borderRadius(6);
                  }
                  .width('100%')
                  .height(12)
                  .backgroundColor('#E8F5E9')
                  .borderRadius(6);
                  Text(this.report.savingGoalProgress >= 100 ? '🎉 目标达成！' : '继续加油 💪')
                    .fontSize(12)
                    .fontColor('#9999AA')
                    .margin({ top: 4 });
                }
                .width('60%')
                .alignItems(HorizontalAlign.Start);
              }
              .width('100%');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ top: 12 });

            // 分类支出占比
            Column() {
              Text('📊 分类支出占比')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .margin({ bottom: 12 });

              const entries = Object.entries(this.report.categoryBreakdown);
              ForEach(entries, ([cat, pct]) => {
                Row() {
                  Text(cat)
                    .fontSize(13)
                    .width(60);
                  Column() {
                    Column()
                      .width(`${pct}%`)
                      .height('100%')
                      .backgroundColor('#4A90D9')
                      .borderRadius(4);
                  }
                  .width('70%')
                  .height(8)
                  .backgroundColor('#E8F4FD')
                  .borderRadius(4);
                  Text(`${pct.toFixed(1)}%`)
                    .fontSize(12)
                    .fontColor('#9999AA')
                    .width(40)
                    .textAlign(TextAlign.End);
                }
                .width('100%')
                .margin({ bottom: 8 });
              });
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ top: 12 });

            // 最值得花 / 最不建议
            Row() {
              Column() {
                Text('✅ 最值得花')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#4CAF50');
                ForEach(this.report.bestSpending, (item) => {
                  Text(`• ${item}`)
                    .fontSize(13)
                    .fontColor('#666680')
                    .margin({ top: 4 });
                });
                if (!this.report.bestSpending.length) {
                  Text('暂无数据')
                    .fontSize(12)
                    .fontColor('#9999AA')
                    .margin({ top: 4 });
                }
              }
              .width('48%')
              .padding(12)
              .backgroundColor('#E8F5E9')
              .borderRadius(12);

              Column() {
                Text('❌ 最不建议')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FF5252');
                ForEach(this.report.worstSpending, (item) => {
                  Text(`• ${item}`)
                    .fontSize(13)
                    .fontColor('#666680')
                    .margin({ top: 4 });
                });
                if (!this.report.worstSpending.length) {
                  Text('暂无数据')
                    .fontSize(12)
                    .fontColor('#9999AA')
                    .margin({ top: 4 });
                }
              }
              .width('48%')
              .padding(12)
              .backgroundColor('#FFEBEE')
              .borderRadius(12);
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: 12 });

            // AI 建议
            Column() {
              Text('🤖 AI建议')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 8 });
              Text(this.report.aiSuggestion || '暂无建议')
                .fontSize(14)
                .fontColor('#666680');
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#E8F4FD')
            .borderRadius(16)
            .margin({ top: 12, bottom: 30 });
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
}

@Component
struct StatBlock {
  private label: string = '';
  private value: string = '';
  private color: string = '#4A90D9';

  build() {
    Column() {
      Text(this.label)
        .fontSize(12)
        .fontColor('#9999AA');
      Text(this.value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.color)
        .margin({ top: 4 });
    }
    .alignItems(HorizontalAlign.Center);
  }
}
