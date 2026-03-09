import { defineStore } from "pinia";

export const useWorldStore = defineStore("world", {
    state: () => ({
        entries: {}
    }),
    actions: {
        async fetchWorld() {
            const res = await fetch("http://localhost:3000/api/world");
            this.entries = await res.json();
        }
    }
});