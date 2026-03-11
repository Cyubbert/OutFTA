import { createRouter, createWebHistory } from "vue-router";

import HomeView from "../views/HomeView.vue";
import NorrunView from "../views/NorrunView.vue";
import SuneView from "../views/SuneView.vue";
import LiiraView from "@/views/LiiraView.vue";
import TalonaView from "@/views/TalonaView.vue";
import DredelView from "@/views/DredelView.vue";
import LacrimaView from "@/views/LacrimaView.vue";
import DuweilView from "@/views/DuweilView.vue";
import IviaView from "@/views/IviaView.vue";
import LetlonView from "@/views/LetlonView.vue";

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
    },

    {
      path: "/kingdoms/dredel",
      name: "dredel",
      component: DredelView
    },

    {
      path: "/kingdoms/lacrima",
      name: "lacrima",
      component: LacrimaView
    },

    {
      path: "/kingdoms/duweil",
      name: "duweil",
      component: DuweilView
    },
    {
      path: "/kingdoms/ivia",
      name: "ivia",
      component: IviaView
    },
    {
      path: "/kingdoms/letlon",
      name: "letlon",
      component: LetlonView
    }

  ]
});

export default router;