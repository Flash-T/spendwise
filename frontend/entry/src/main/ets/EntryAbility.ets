/**
 * SpendWise - 应用入口
 */

import UIAbility from '@ohos.app.ability.UIAbility';
import Window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    console.log('SpendWise Ability onCreate');
  }

  onDestroy() {
    console.log('SpendWise Ability onDestroy');
  }

  onWindowStageCreate(windowStage: Window.WindowStage) {
    windowStage.loadContent('pages/Login', (err) => {
      if (err) {
        console.error('Failed to load login page', JSON.stringify(err));
      }
    });
  }

  onWindowStageDestroy() {
    // release
  }

  onForeground() {
    // App进入前台
  }

  onBackground() {
    // App进入后台
  }
}
