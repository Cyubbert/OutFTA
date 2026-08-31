import { createRouter, createWebHashHistory } from "vue-router";

const router = createRouter({
    history: createWebHashHistory(),
    routes: [
        {
            path: "/",
            name: "home",
            component: () => import("@/views/OtherViews/HomeView.vue")
        },

        // ── World ──

        {
            path: "/world",
            name: "world",
            component: () => import("@/views/WorldViews/WorldView.vue")
        },
        {
            path: "/world/norrun",
            name: "norrun",
            component: () => import("@/views/WorldViews/NorrunView.vue")
        },
        {
            path: "/world/liira",
            name: "liira",
            component: () => import("@/views/DeityViews/LiiraView.vue")
        },
        {
            path: "/world/sune",
            name: "sune",
            component: () => import("@/views/DeityViews/SuneView.vue")
        },
        {
            path: "/world/talona",
            name: "talona",
            component: () => import("@/views/DeityViews/TalonaView.vue")
        },

        // ── Kingdom ──

        {
            path: "/kingdom",
            name: "kingdom",
            component: () => import("@/views/WorldViews/KingdomView.vue")
        },
        {
            path: "/kingdom/dredel",
            name: "dredel",
            component: () => import("@/views/WorldViews/DredelView.vue")
        },
        {
            path: "/kingdom/lacrima",
            name: "lacrima",
            component: () => import("@/views/WorldViews/LacrimaView.vue")
        },
        {
            path: "/kingdom/duweil",
            name: "duweil",
            component: () => import("@/views/WorldViews/DuweilView.vue")
        },
        {
            path: "/kingdom/ivia",
            name: "ivia",
            component: () => import("@/views/WorldViews/IviaView.vue")
        },
        {
            path: "/kingdom/letlon",
            name: "letlon",
            component: () => import("@/views/WorldViews/LetlonView.vue")
        },

        // ── NPCs ──

        {
            path: "/npcs",
            name: "npcs",
            component: () => import("@/views/NPCViews/NpcsView.vue")
        },
        {
            path: "/npcs/aarely",
            name: "aarely",
            component: () => import("@/views/NPCViews/AarelyView.vue")
        },
        {
            path: "/npcs/virex",
            name: "virex",
            component: () => import("@/views/NPCViews/VirexView.vue")
        },
        {
            path: "/npcs/aasmias",
            name: "aasmias",
            component: () => import("@/views/NPCViews/AasmiasView.vue")
        },
        {
            path: "/npcs/moltyn",
            name: "moltyn",
            component: () => import("@/views/NPCViews/MoltynView.vue")
        },
        {
            path: "/npcs/selene",
            name: "selene",
            component: () => import("@/views/NPCViews/SeleneView.vue")
        },

        // ── Sessions ──

        {
            path: "/sessions",
            name: "sessions",
            component: () => import("@/views/SessionViews/SessionsView.vue")
        },
        {
            path: "/sessions/:id",
            name: "session-detail",
            component: () => import("@/views/SessionViews/SessionDetail.vue")
        },

        // ── Community ──

        {
            path: "/community",
            name: "community",
            component: () => import("@/views/CommunityViews/CommunityView.vue")
        },

        // ── Other ──

        {
            path: "/spells",
            name: "spells",
            component: () => import("@/views/OtherViews/Spellsview.vue")
        },
        {
            path: "/gallery",
            name: "gallery",
            component: () => import("@/views/OtherViews/GalleryView.vue")
        },
        {
            path: "/mory",
            name: "mory",
            component: () => import("@/views/MoryViews/DiaryView.vue")
        },
        {
            path: "/moryquinau",
            name: "mory-quinau",
            component: () => import("@/views/MoryViews/QuinauView.vue")
        },

        // ── Auth ──

        {
            path: "/login",
            name: "login",
            component: () => import("@/views/AuthViews/LoginView.vue")
        },
        {
            path: "/reset-password",
            name: "reset-password",
            component: () => import("@/views/AuthViews/ResetPasswordView.vue")
        },
        {
            path: "/admin",
            name: "admin",
            component: () => import("@/views/AuthViews/AdminView.vue")
        },
        {
            path: "/profile",
            name: "profile",
            component: () => import("@/views/AuthViews/ProfileView.vue")
        }

    ]
});

export default router;