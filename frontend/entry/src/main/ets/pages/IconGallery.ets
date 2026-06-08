/**
 * 图标素材展示页 - 展示所有消费分类图标
 */

import router from '@ohos.router';
import { CategoryIcon, CATEGORY_CONFIG, CategoryIconInfo } from '../components/CategoryIcon';

@Entry
@Component
struct IconGalleryPage {
  build() {
    Column() {
      // 顶部
      Row() {
        Text('←')
          .fontSize(24)
          .onClick(() => router.back());
        Blank();
        Text('🎨 消费分类图标')
          .fontSize(20)
          .fontWeight(FontWeight.Bold);
        Blank();
        Text('').width(24);
      }
      .width('90%')
      .padding({ top: 16, bottom: 12 });

      Text('共 ' + CATEGORY_CONFIG.length + ' 个分类')
        .fontSize(14)
        .fontColor('#9999AA')
        .width('90%')
        .margin({ bottom: 16 });

      Scroll() {
        Column() {
          // 按行显示，每行4个
          ForEach(CATEGORY_CONFIG, (config, idx) => {
            if (idx % 4 === 0) {
              Row() {
                ForEach([0, 1, 2, 3], (offset) => {
                  const i = idx + offset;
                  if (i < CATEGORY_CONFIG.length) {
                    this.IconCard(CATEGORY_CONFIG[i]);
                  }
                });
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ bottom: 16 });
            }
          });
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
  IconCard(config: CategoryIconInfo) {
    Column() {
      // 圆形图标
      Text(config.icon)
        .fontSize(28)
        .width(56)
        .height(56)
        .backgroundColor(config.bgColor)
        .borderRadius(28)
        .textAlign(TextAlign.Center)
        .lineHeight(56);

      Text(config.name)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A2E')
        .margin({ top: 6 });

      // 色块副标题
      Text(config.color)
        .fontSize(9)
        .fontColor('#9999AA');
    }
    .width('22%')
    .alignItems(HorizontalAlign.Center)
    .padding(8)
    .backgroundColor('#FFFFFF')
    .borderRadius(16);
  }
}
