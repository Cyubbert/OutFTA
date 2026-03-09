import { defineStore } from "pinia";

export const useWorldStore = defineStore("world", {
    state: () => ({
        world: []
    }),
    actions: {
        async fetchWorld() {
            try {
                // Mock data
                this.world = [
                    { name: "Norrun" },
                    { name: "Talona" },
                    { name: "Liira" },
                    { name: "Sune" }
                ];

            } catch (error) {
                console.error("fetchWorld error:", error);
            }
        }
    }
});