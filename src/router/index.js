import {createRouter, createWebHistory} from "vue-router";

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
import AarelyView from "@/views/AarelyView.vue";
import VirexView from "@/views/VirexView.vue";
import AasmiasView from "@/views/AasmiasView.vue";
import InitiativeView from "../views/InitiativeView.vue";
import MoltynView from "@/views/MoltynView.vue";

const router = createRouter({
    history: createWebHistory(),
    routes: [
        {
            path: "/",
            name: "home",
            component: HomeView
        },
        { path: '/world',
            component: () => import('@/views/WorldView.vue') },

        { path: '/kingdom',
            component: () => import('@/views/KingdomView.vue') },

        { path: '/npcs',
            component: () => import('@/views/NpcsView.vue') },

        { path: '/spells',
            component: () => import('@/views/Spellsview.vue') },

        // { path: '/character',
        //     component: () => import('@/views/CharacterView.vue') },
        //
        // { path: '/character/:id',
        //     component: () => import('@/views/Charactersheet.vue') },

        {
            path: "/world/norrun",
            name: "norrun",
            component: NorrunView
        },

        {
            path: "/world/liira",
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
            path: "/kingdom/dredel",
            name: "dredel",
            component: DredelView
        },

        {
            path: "/kingdom/lacrima",
            name: "lacrima",
            component: LacrimaView
        },

        {
            path: "/kingdom/duweil",
            name: "duweil",
            component: DuweilView
        },

        {
            path: "/kingdom/ivia",
            name: "ivia",
            component: IviaView
        },

        {
            path: "/kingdom/letlon",
            name: "letlon",
            component: LetlonView
        },

        {
            path: "/npcs/aarely",
            name: "aarely",
            component: AarelyView
        },

        {
            path: "/npcs/virex",
            name: "virex",
            component: VirexView
        },

        {
            path: "/npcs/aasmias",
            name: "aasmias",
            component: AasmiasView
        },
        {
            path: "/npcs/moltyn",
            name: "moltyn",
            component: MoltynView
        },


        // {
        //     path: "/fight",
        //     name: "fight",
        //     component: InitiativeView
        // },

        {path: '/sessions',
            component: () => import('@/views/SessionsView.vue')
        },

        {path: '/sessions/:id',
            component: () => import('@/views/SessionDetail.vue')
        },

        { path: '/gallery',
            component: () => import('@/views/GalleryView.vue')
        },


    ]
});

export default router;