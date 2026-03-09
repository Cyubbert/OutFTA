import { createRouter, createWebHistory } from "vue-router";

import HomeView from "../views/HomeView.vue";
import NorrunView from "../views/NorrunView.vue";
import SuneView from "../views/SuneView.vue";
import LiiraView from "@/views/LiiraView.vue";
import TalonaView from "@/views/TalonaView.vue";

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/",
      name: "home",
      component: HomeView
    },

    {
      path: "/world/norrun",
      name: "norrun",
      component: NorrunView
    },

    {
      path:"/world/liira",
      name: "liira",
      component: LiiraView
    },

    {
      path: "/world/sune",
      name: "sune",
      component: SuneView
    },

    {
      path: "/world/talona",
      name: "talona",
      component: TalonaView
    }

  ]
});

export default router;