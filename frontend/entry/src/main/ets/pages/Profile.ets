/**
 * 财务画像设置页
 */

import router from '@ohos.router';
import { getProfile, updateProfile } from '../data/api';
import { UserProfile, LIFE_STAGES } from '../data/models';

@Entry
@Component
struct ProfilePage {
  @State monthlyIncome: string = '';
  @State fixedExpenses: string = '';
  @State savingGoal: string = '';
  @State debtAmount: string = '';
  @State lifeStage: number = 1;
  @State loading: boolean = true;
  @State saving: boolean = false;

  aboutToAppear() {
    this.loadProfile();
  }

  async loadProfile() {
    try {
      const user = await getProfile();
      this.monthlyIncome = user.monthlyIncome ? String(user.monthlyIncome) : '';
      this.fixedExpenses = user.fixedExpenses ? String(user.fixedExpenses) : '';
      this.savingGoal = user.savingGoal ? String(user.savingGoal) : '';
      this.debtAmount = user.debtAmount ? String(user.debtAmount) : '';
      this.lifeStage = LIFE_STAGES.findIndex(s => s.value === user.lifeStage);
      if (this.lifeStage < 0) this.lifeStage = 1;
    } catch (e) {
      console.error('Load profile failed:', JSON.stringify(e));
    }
    this.loading = false;
  }

  async handleSave() {
    this.saving = true;
    try {
      await updateProfile({
        monthlyIncome: parseFloat(this.monthlyIncome) || 0,
        fixedExpenses: parseFloat(this.fixedExpenses) || 0,
        savingGoal: parseFloat(this.savingGoal) || 0,
        debtAmount: parseFloat(this.debtAmount) || 0,
        lifeStage: LIFE_STAGES[this.lifeStage]?.value || 'office',
      });
      router.back();
    } catch (e) {
      console.error('Save profile failed:', JSON.stringify(e));
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
        Text('👤 我的')
          .fontSize(20)
          .fontWeight(FontWeight.Bold);
        Blank();
        Text('').width(24);
      }
      .width('90%')
      .padding({ top: 16, bottom: 12 });

      Scroll() {
        Column() {
          // 财务画像标题
          Column() {
            Text('财务画像')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A2E');
            Text('先了解你，AI 才能更懂你')
              .fontSize(14)
              .fontColor('#9999AA')
              .margin({ top: 4 });
          }
          .width('100%')
          .padding({ top: 20, bottom: 24 });

          // 表单卡片
          FormCard('💰 月收入', '请输入你的月收入', this.monthlyIncome, v => this.monthlyIncome = v);
          FormCard('🏠 固定支出', '房租、水电等每月固定支出', this.fixedExpenses, v => this.fixedExpenses = v);
          FormCard('🎯 存钱目标', '每月希望存多少钱', this.savingGoal, v => this.savingGoal = v);
          FormCard('📉 负债情况', '信用卡、贷款等负债总额', this.debtAmount, v => this.debtAmount = v);

          // 生活阶段
          Text('🧑 生活阶段')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .margin({ top: 16, bottom: 8 });

          Row() {
            ForEach(LIFE_STAGES, (stage, index) => {
              Column() {
                Text(stage.label)
                  .fontSize(14)
                  .fontColor(this.lifeStage === index ? '#FFFFFF' : '#666680')
                  .padding({ left: 20, right: 20, top: 10, bottom: 10 });
              }
              .backgroundColor(this.lifeStage === index ? '#4A90D9' : '#F5F7FA')
              .borderRadius(20)
              .onClick(() => this.lifeStage = index);
            });
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);

          // 保存按钮
          Button(this.saving ? '保存中...' : '保存')
            .width('100%')
            .height(48)
            .backgroundColor('#4A90D9')
            .borderRadius(24)
            .fontColor('#FFFFFF')
            .fontSize(16)
            .enabled(!this.saving)
            .margin({ top: 30, bottom: 40 })
            .onClick(() => this.handleSave());
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
struct FormCard {
  private label: string = '';
  private placeholder: string = '';
  private value: string = '';
  private onChange: (v: string) => void = () => {};

  build() {
    Column() {
      Text(this.label)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A2E')
        .width('100%');

      TextInput({ placeholder: this.placeholder })
        .value(this.value)
        .onChange(v => this.onChange(v))
        .height(44)
        .backgroundColor('#F5F7FA')
        .borderRadius(10)
        .padding({ left: 12 })
        .type(InputType.Number)
        .margin({ top: 8 });
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ bottom: 10 });
  }
}
