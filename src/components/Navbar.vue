<script setup>
import {ref, computed, watch} from 'vue'
import {useRoute} from 'vue-router'
import {useAuth} from '@/composables/useAuth'

const route = useRoute()
const menuOpen = ref(false)
const {user, profile, isAdmin, signOut} = useAuth()

const avatarInitial = computed(() => (profile.value.username || user.value?.email || '?')[0]?.toUpperCase())

const links = [
  {label: 'Home', to: '/'},
  {label: 'World & Deities', to: '/world'},
  {label: 'Kingdoms', to: '/kingdom'},
  {label: 'NPCs', to: '/npcs'},
  {label: 'Sessions', to: '/sessions'},
  {label: 'Community', to: '/community'},
  {label: 'Spells', to: '/spells'},
  {label: 'Gallery', to: '/gallery'},
]

function isActive(to) {
  if (to === '/') return route.path === '/'
  return route.path.startsWith(to)
}

function close() {
  menuOpen.value = false
}

function toggleMenu() {
  menuOpen.value = !menuOpen.value
}

watch(menuOpen, (open) => {
  document.body.style.overflow = open ? 'hidden' : ''
})
</script>

<template>
  <nav class="navbar">
    <div class="navbar-inner">
      <router-link to="/" class="navbar-logo" @click="close">
        <span class="logo-rune"></span>
        <span class="logo-text">Out for the Ancients</span>
      </router-link>

      <button
          class="burger"
          :class="{ open: menuOpen }"
          @click="toggleMenu"
          aria-label="Menu"
      >
        <span/><span/><span/>
      </button>
    </div>
  </nav>

  <Teleport to="body">
    <transition name="fade">
      <div class="menu-backdrop" v-if="menuOpen" @click="close"/>
    </transition>

    <transition name="slide">
      <aside class="menu-panel" v-if="menuOpen">
        <ul class="menu-links">
          <li v-for="link in links" :key="link.to">
            <router-link
                :to="link.to"
                class="menu-link"
                :class="{ active: isActive(link.to) }"
                @click="close"
            >
              {{ link.label }}
              <span class="link-dot" v-if="isActive(link.to)"/>
            </router-link>
          </li>
        </ul>

        <div class="menu-divider"/>

        <div class="menu-auth">
          <template v-if="user">
            <div class="menu-identity">
              <span class="menu-avatar">
                <img v-if="profile.avatar_url" :src="profile.avatar_url" class="menu-avatar-img" alt="Profile" />
                <span v-else class="menu-avatar-placeholder">{{ avatarInitial }}</span>
              </span>
              <span class="menu-identity-name">{{ profile.username || user.email }}</span>
            </div>
            <router-link to="/profile" class="menu-link" :class="{ active: isActive('/profile') }" @click="close">Profile</router-link>
            <router-link v-if="isAdmin" to="/admin" class="menu-link" :class="{ active: isActive('/admin') }" @click="close">Admin</router-link>
            <button class="menu-link menu-signout" @click="signOut(); close()">Sign out</button>
          </template>
          <router-link v-else to="/login" class="menu-link" @click="close">Login</router-link>
        </div>
      </aside>
    </transition>
  </Teleport>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Iosevka+Charon:ital,wght@0,300;0,400;0,500;0,700;1,300;1,400;1,500;1,700&family=Jost:ital,wght@0,100..900;1,100..900&display=swap');

.navbar {
  position: sticky;
  top: 0;
  z-index: 100;
  width: 100%;
  background: rgba(18, 18, 18, 0.95);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-bottom: 1px solid rgba(144, 202, 249, 0.08);
  transform: translateZ(0);
  -webkit-transform: translateZ(0);
}

.navbar-inner {
  max-width: 900px;
  margin: 0 auto;
  padding: 0 1.5rem;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
}

/* ── Logo ── */
.navbar-logo {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  text-decoration: none;
  flex-shrink: 0;
}

.logo-rune {
  font-size: 1rem;
  color: #90caf9;
  opacity: 0.85;
  transition: opacity 0.2s;
}

.logo-text {
  font-family: 'Iosevka Charon', regular;
  font-size: 1rem;
  font-weight: 500;
  letter-spacing: 0.08em;
  color: #e0e0e0;
  white-space: nowrap;
  transition: color 0.2s;
}

.navbar-logo:hover .logo-rune {
  opacity: 1;
}

.navbar-logo:hover .logo-text {
  color: #fff;
}

/* ── Burger ── */
.burger {
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 5px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  width: 32px;
  height: 32px;
  flex-shrink: 0;
  position: relative;
  z-index: 210;
}

.burger span {
  display: block;
  width: 22px;
  height: 1.5px;
  background: #bbb;
  border-radius: 2px;
  transition: transform 0.25s, opacity 0.2s, background 0.2s;
  transform-origin: center;
}

.burger:hover span {
  background: #e0e0e0;
}

.burger.open span:nth-child(1) {
  transform: translateY(6.5px) rotate(45deg);
  background: #90caf9;
}

.burger.open span:nth-child(2) {
  opacity: 0;
}

.burger.open span:nth-child(3) {
  transform: translateY(-6.5px) rotate(-45deg);
  background: #90caf9;
}
</style>

<style>
/* Unscoped: this panel/backdrop is teleported to <body>, outside this
   component's DOM subtree, so scoped [data-v-xxx] attribute selectors
   would never match it. */
.menu-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  z-index: 190;
}

.menu-panel {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  width: min(320px, 85vw);
  z-index: 200;
  background: #161616;
  border-left: 1px solid rgba(144, 202, 249, 0.12);
  box-shadow: -12px 0 40px rgba(0, 0, 0, 0.5);
  padding: 72px 0 1rem;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.menu-links {
  list-style: none;
  margin: 0;
  padding: 0 1rem;
}

.menu-link {
  position: relative;
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  box-sizing: border-box;
  padding: 0.75rem 0.5rem;
  text-decoration: none;
  font-family: 'Iosevka Charon', regular;
  font-size: 0.85rem;
  letter-spacing: 0.06em;
  color: #888;
  background: none;
  border: none;
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  cursor: pointer;
  text-align: left;
  transition: color 0.2s, padding-left 0.2s;
}

.menu-link:hover {
  color: #e0e0e0;
  padding-left: 0.9rem;
}

.menu-link.active {
  color: #90caf9;
}

.link-dot {
  width: 3px;
  height: 3px;
  border-radius: 50%;
  background: #90caf9;
  opacity: 0.8;
}

.menu-divider {
  height: 1px;
  margin: 0.5rem 1rem;
  background: rgba(255, 255, 255, 0.08);
}

.menu-auth {
  display: flex;
  flex-direction: column;
  padding: 0 1rem;
}

.menu-identity {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding: 0.6rem 0.5rem;
}

.menu-avatar {
  display: block;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
  background: #1a1a1a;
  border: 1px solid rgba(255, 255, 255, 0.15);
}

.menu-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.menu-avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #90caf9;
  font-family: 'Iosevka Charon', monospace;
  font-size: 0.8rem;
}

.menu-identity-name {
  font-size: 0.85rem;
  color: #ccc;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.menu-signout:hover {
  color: #e05252;
}

/* ── Transitions ── */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.25s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.slide-enter-active,
.slide-leave-active {
  transition: transform 0.28s ease;
}

.slide-enter-from,
.slide-leave-to {
  transform: translateX(100%);
}
</style>
