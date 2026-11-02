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
            path: "/world/:slug",
            name: "world-page",
            component: () => import("@/views/WorldViews/PageView.vue")
        },

        // ── Kingdom ──

        {
            path: "/kingdom",
            name: "kingdom",
            component: () => import("@/views/WorldViews/KingdomView.vue")
        },
        {
            path: "/kingdom/:slug",
            name: "kingdom-page",
            component: () => import("@/views/WorldViews/PageView.vue")
        },

        // ── NPCs ──

        {
            path: "/npcs",
            name: "npcs",
            component: () => import("@/views/NPCViews/NpcsView.vue")
        },
        {
            path: "/npcs/:slug",
            name: "npc-page",
            component: () => import("@/views/WorldViews/PageView.vue")
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
        {
            path: "/quinlan",
            name: "quinlan",
            component: () => import("@/views/QuinlanViews/DiaryView.vue")
        },
        {
            path: "/diary-gallery",
            name: "diary-gallery",
            component: () => import("@/views/OtherViews/DiaryGalleryView.vue")
        },
        {
            path: "/notebook",
            name: "notebook",
            component: () => import("@/views/NotebookViews/NotebookView.vue")
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
        },
        {
            path: "/profile/:username",
            name: "public-profile",
            component: () => import("@/views/AuthViews/PublicProfileView.vue")
        },
        {
            path: "/people",
            name: "people",
            component: () => import("@/views/AuthViews/PeopleView.vue")
        }

    ]
});

// After a deploy, a cached index can point at view chunks that no longer exist.
// Reload once to fetch the fresh build instead of rendering an empty page.
router.onError((error, to) => {
    const chunkFailed = /Failed to fetch dynamically imported module|Importing a module script failed|error loading dynamically imported module/i.test(error?.message ?? "");
    if (!chunkFailed) return;
    try {
        if (sessionStorage.getItem("chunk-reload")) return;
        sessionStorage.setItem("chunk-reload", "1");
    } catch {}
    window.location.hash = to.fullPath;
    window.location.reload();
});

router.afterEach(() => {
    try { sessionStorage.removeItem("chunk-reload"); } catch {}
});

export default router;