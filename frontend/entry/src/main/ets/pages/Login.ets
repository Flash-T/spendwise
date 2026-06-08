/**
 * 登录 / 注册页
 */

import router from '@ohos.router';
import { login, register, setToken } from '../data/api';

@Entry
@Component
struct LoginPage {
  @State isLogin: boolean = true;
  @State username: string = '';
  @State password: string = '';
  @State email: string = '';
  @State loading: boolean = false;
  @State errorMsg: string = '';

  build() {
    Column() {
      // 顶部装饰区
      Column() {
        Text('SpendWise')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4A90D9');
        Text('该花吗？')
          .fontSize(18)
          .fontColor('#666680')
          .margin({ top: 8 });
        Text('AI 消费决策助手')
          .fontSize(14)
          .fontColor('#9999AA')
          .margin({ top: 4 });
      }
      .width('100%')
      .padding({ top: 80, bottom: 40 });

      // 登录/注册切换
      Row() {
        Text('登录')
          .fontSize(18)
          .fontWeight(this.isLogin ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.isLogin ? '#4A90D9' : '#9999AA')
          .onClick(() => { this.isLogin = true; this.errorMsg = ''; });
        Text('  |  ')
          .fontColor('#DDD');
        Text('注册')
          .fontSize(18)
          .fontWeight(!this.isLogin ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(!this.isLogin ? '#4A90D9' : '#9999AA')
          .onClick(() => { this.isLogin = false; this.errorMsg = ''; });
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 30 });

      // 输入表单
      Column() {
        TextInput({ placeholder: '用户名' })
          .value(this.username)
          .onChange(v => this.username = v)
          .height(48)
          .backgroundColor('#F5F7FA')
          .borderRadius(12)
          .padding({ left: 16 })
          .margin({ bottom: 12 });

        if (!this.isLogin) {
          TextInput({ placeholder: '邮箱' })
            .value(this.email)
            .onChange(v => this.email = v)
            .height(48)
            .backgroundColor('#F5F7FA')
            .borderRadius(12)
            .padding({ left: 16 })
            .margin({ bottom: 12 });
        }

        TextInput({ placeholder: '密码' })
          .value(this.password)
          .onChange(v => this.password = v)
          .height(48)
          .backgroundColor('#F5F7FA')
          .borderRadius(12)
          .padding({ left: 16 })
          .type(InputType.Password)
          .margin({ bottom: 20 });

        // 错误提示
        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(13)
            .fontColor('#FF5252')
            .margin({ bottom: 10 });
        }

        // 按钮
        Button(this.loading ? '处理中...' : (this.isLogin ? '登录' : '注册'))
          .width('100%')
          .height(48)
          .backgroundColor('#4A90D9')
          .borderRadius(24)
          .fontColor('#FFFFFF')
          .fontSize(16)
          .enabled(!this.loading)
          .onClick(() => this.handleSubmit());
      }
      .width('85%')
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Center);
  }

  async handleSubmit() {
    if (!this.username || !this.password) {
      this.errorMsg = '请填写用户名和密码';
      return;
    }
    if (!this.isLogin && !this.email) {
      this.errorMsg = '请填写邮箱';
      return;
    }

    this.loading = true;
    this.errorMsg = '';

    try {
      let result;
      if (this.isLogin) {
        result = await login(this.username, this.password);
      } else {
        result = await register(this.username, this.email, this.password);
      }
      setToken(result.access_token);
      router.replaceUrl({ url: 'pages/Home' });
    } catch (e) {
      this.errorMsg = e.message || '操作失败，请重试';
    } finally {
      this.loading = false;
    }
  }
}
