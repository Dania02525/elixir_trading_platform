import MainView from '../main';
import Vue from 'vue'
import TradingView from '../vue/trading/trading-view.vue'

export default class View extends MainView {
  mount() {
    super.mount();

    new Vue({
      el: '#trading-view',
      components: { TradingView }
    });
    // Specific logic here
    console.log('PageTradingView mounted');
  }

  unmount() {
    super.unmount();

    // Specific logic here
    console.log('PageTradingView unmounted');
  }
}
