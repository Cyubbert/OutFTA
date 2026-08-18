import { createApp } from "vue";
import { createPinia } from "pinia";
import router from "./router";
import App from "./App.vue";
import "./assets/theme.css";
import "./assets/detail-page.css";

createApp(App)
    .use(createPinia())
    .use(router)
    .mount("#app");