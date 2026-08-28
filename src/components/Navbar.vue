<script setup>
import {ref, computed, onMounted, onUnmounted} from 'vue'
import {useRoute} from 'vue-router'
import {useAuth} from '@/composables/useAuth'

const route = useRoute()
const menuOpen = ref(false)
const profileMenuOpen = ref(false)
const profileMenuEl = ref(null)
const {user, profile, signOut} = useAuth()

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
  // {label: 'Fight', to: '/fight'},
  // {label: 'Charactersheet', to: '/character'},
]

function isActive(to) {
  if (to === '/') return route.path === '/'
  return route.path.startsWith(to)
}

function close() {
  menuOpen.value = false
}

function toggleProfileMenu() {
  profileMenuOpen.value = !profileMenuOpen.value
}

function closeProfileMenu() {
  profileMenuOpen.value = false
}

function onDocumentClick(e) {
  if (profileMenuOpen.value && profileMenuEl.value && !profileMenuEl.value.contains(e.target)) {
    profileMenuOpen.value = false
  }
}

onMounted(() => document.addEventListener('click', onDocumentClick))
onUnmounted(() => document.removeEventListener('click', onDocumentClick))
</script>

<template>
  <nav class="navbar">
    <div class="navbar-inner">

      <!-- Logo / Title -->
      <router-link to="/" class="navbar-logo" @click="close">
        <span class="logo-rune"></span>
        <span class="logo-text">Out for the Ancients</span>
      </router-link>

      <!-- Desktop links -->
      <ul class="navbar-links">
        <li v-for="link in links" :key="link.to">
          <router-link
              :to="link.to"
              class="nav-link"
              :class="{ active: isActive(link.to) }"
          >
            {{ link.label }}
            <span class="link-dot" v-if="isActive(link.to)"/>
          </router-link>
        </li>
      </ul>

      <!-- Auth -->
      <div class="navbar-auth">
        <div v-if="user" class="profile-menu" ref="profileMenuEl">
          <button
              class="profile-trigger"
              :class="{ open: profileMenuOpen }"
              :title="profile.username || user.email"
              @click="toggleProfileMenu"
          >
            <span class="profile-avatar">
              <img v-if="profile.avatar_url" :src="profile.avatar_url" class="auth-avatar-img" alt="Profile" />
              <span v-else class="auth-avatar-placeholder">{{ avatarInitial }}</span>
            </span>
            <span class="profile-chevron">▾</span>
          </button>

          <transition name="dropdown">
            <ul class="profile-dropdown" v-if="profileMenuOpen">
              <li class="dropdown-identity">{{ profile.username || user.email }}</li>
              <li>
                <router-link to="/profile" class="dropdown-link" @click="closeProfileMenu">Profile</router-link>
              </li>
              <li>
                <router-link to="/community" class="dropdown-link" @click="closeProfileMenu">Community</router-link>
              </li>
              <li class="dropdown-divider"/>
              <li>
                <button class="dropdown-link dropdown-signout" @click="signOut(); closeProfileMenu()">Sign out</button>
              </li>
            </ul>
          </transition>
        </div>
        <router-link v-else to="/login" class="auth-login" @click="close">Login</router-link>
      </div>

      <!-- Mobile burger -->
      <button
          class="burger"
          :class="{ open: menuOpen }"
          @click="menuOpen = !menuOpen"
          aria-label="Menu"
      >
        <span/><span/><span/>
      </button>
    </div>

    <!-- Mobile dropdown -->
    <transition name="dropdown">
      <ul class="mobile-menu" v-if="menuOpen">
        <li v-for="link in links" :key="link.to">
          <router-link
              :to="link.to"
              class="mobile-link"
              :class="{ active: isActive(link.to) }"
              @click="close"
          >
            {{ link.label }}
          </router-link>
        </li>
        <li v-if="user">
          <router-link to="/profile" class="mobile-link" :class="{ active: isActive('/profile') }" @click="close">Profile</router-link>
        </li>
        <li class="mobile-auth">
          <template v-if="user">
            <span class="auth-email">{{ user.email }}</span>
            <button class="auth-signout" @click="signOut(); close()">Sign out</button>
          </template>
          <router-link v-else to="/login" class="mobile-link" @click="close">Login</router-link>
        </li>
      </ul>
    </transition>
  </nav>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Iosevka+Charon:ital,wght@0,300;0,400;0,500;0,700;1,300;1,400;1,500;1,700&family=Jost:ital,wght@0,100..900;1,100..900&display=swap');

.iosevka-charon-light {
  font-family: "Iosevka Charon", monospace;
  font-weight: 300;
  font-style: normal;
}

.iosevka-charon-regular {
  font-family: "Iosevka Charon", monospace;
  font-weight: 400;
  font-style: normal;
}

.iosevka-charon-medium {
  font-family: "Iosevka Charon", monospace;
  font-weight: 500;
  font-style: normal;
}

.iosevka-charon-bold {
  font-family: "Iosevka Charon", monospace;
  font-weight: 700;
  font-style: normal;
}

.iosevka-charon-light-italic {
  font-family: "Iosevka Charon", monospace;
  font-weight: 300;
  font-style: italic;
}

.iosevka-charon-regular-italic {
  font-family: "Iosevka Charon", monospace;
  font-weight: 400;
  font-style: italic;
}

.iosevka-charon-medium-italic {
  font-family: "Iosevka Charon", monospace;
  font-weight: 500;
  font-style: italic;
}

.iosevka-charon-bold-italic {
  font-family: "Iosevka Charon", monospace;
  font-weight: 700;
  font-style: italic;
}


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
  gap: 2rem;
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
  font-size: 1 rem;
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

/* ── Desktop links ── */
.navbar-links {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  list-style: none;
  margin: 0;
  padding: 0;
}

.nav-link {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  text-decoration: none;
  font-family: 'Iosevka Charon', regular;
  font-size: 1 rem;
  font-weight: 400;
  letter-spacing: 0.06em;
  color: #888;
  transition: color 0.2s, background 0.2s;
  white-space: nowrap;
}

.nav-link:hover {
  color: #e0e0e0;
  background: rgba(255, 255, 255, 0.04);
}

.nav-link.active {
  color: #90caf9;
}

.link-dot {
  width: 3px;
  height: 3px;
  border-radius: 50%;
  background: #90caf9;
  opacity: 0.8;
}

/* ── Auth ── */
.navbar-auth {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  flex-shrink: 0;
}

.auth-login {
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  text-decoration: none;
  font-family: 'Iosevka Charon', regular;
  font-size: 0.9rem;
  letter-spacing: 0.06em;
  color: #888;
  border: 1px solid rgba(255, 255, 255, 0.15);
  transition: color 0.2s, border-color 0.2s;
}

.auth-login:hover {
  color: #90caf9;
  border-color: #90caf9;
}

/* ── Profile dropdown ── */
.profile-menu {
  position: relative;
  flex-shrink: 0;
}

.profile-trigger {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  background: none;
  border: none;
  padding: 2px 4px 2px 2px;
  border-radius: 20px;
  cursor: pointer;
  transition: background 0.2s;
}

.profile-trigger:hover,
.profile-trigger.open {
  background: rgba(255, 255, 255, 0.06);
}

.profile-avatar {
  display: block;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
  border: 1px solid rgba(255, 255, 255, 0.15);
  transition: border-color 0.2s;
}

.profile-trigger:hover .profile-avatar,
.profile-trigger.open .profile-avatar {
  border-color: #90caf9;
}

.profile-chevron {
  font-size: 0.65rem;
  color: #888;
  transition: transform 0.2s, color 0.2s;
}

.profile-trigger:hover .profile-chevron,
.profile-trigger.open .profile-chevron {
  color: #90caf9;
}

.profile-trigger.open .profile-chevron {
  transform: rotate(180deg);
}

.profile-dropdown {
  position: absolute;
  top: calc(100% + 10px);
  right: 0;
  min-width: 190px;
  list-style: none;
  margin: 0;
  padding: 0.4rem;
  background: #181818;
  border: 1px solid #2a2a2a;
  border-radius: 10px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
}

.dropdown-identity {
  padding: 0.5rem 0.7rem 0.4rem;
  font-size: 0.75rem;
  color: #666;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.dropdown-divider {
  height: 1px;
  margin: 0.3rem 0.3rem;
  background: rgba(255, 255, 255, 0.08);
}

.dropdown-link {
  display: block;
  width: 100%;
  box-sizing: border-box;
  padding: 0.55rem 0.7rem;
  border-radius: 6px;
  background: none;
  border: none;
  text-align: left;
  text-decoration: none;
  font-family: 'Jost', sans-serif;
  font-size: 0.88rem;
  color: #ccc;
  cursor: pointer;
  transition: background 0.15s, color 0.15s;
}

.dropdown-link:hover {
  background: rgba(144, 202, 249, 0.08);
  color: #90caf9;
}

.dropdown-signout:hover {
  background: rgba(224, 82, 82, 0.1);
  color: #e05252;
}

.auth-avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.auth-avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #1a1a1a;
  color: #90caf9;
  font-family: 'Iosevka Charon', monospace;
  font-size: 0.9rem;
}

.auth-email {
  font-size: 0.8rem;
  color: #888;
  white-space: nowrap;
}

.auth-signout {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.15);
  color: #888;
  padding: 0.3rem 0.65rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  transition: color 0.2s, border-color 0.2s;
}

.auth-signout:hover {
  color: #90caf9;
  border-color: #90caf9;
}

.mobile-auth {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  padding: 0.7rem 0.5rem;
}

/* ── Burger (mobile) ── */
.burger {
  display: none;
  flex-direction: column;
  justify-content: center;
  gap: 5px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  width: 32px;
  height: 32px;
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

/* ── Mobile menu ── */
.mobile-menu {
  list-style: none;
  margin: 0;
  padding: 0.5rem 1.5rem 1rem;
  border-top: 1px solid rgba(144, 202, 249, 0.08);
  background: rgba(18, 18, 18, 0.97);
}

.mobile-link {
  display: block;
  padding: 0.7rem 0.5rem;
  text-decoration: none;
  font-family: 'Iosevka Charon', regular;
  font-size: 0.85rem;
  letter-spacing: 0.06em;
  color: #888;
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  transition: color 0.2s, padding-left 0.2s;
}

.mobile-link:last-child {
  border-bottom: none;
}

.mobile-link:hover {
  color: #e0e0e0;
  padding-left: 1rem;
}

.mobile-link.active {
  color: #90caf9;
}

/* ── Dropdown transition ── */
.dropdown-enter-active,
.dropdown-leave-active {
  transition: opacity 0.2s, transform 0.2s;
}

.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

/* ── Responsive ── */
@media (max-width: 680px) {
  .navbar-links {
    display: none;
  }

  .navbar-auth {
    display: none;
  }

  .burger {
    display: flex;
  }

  .logo-text {
    font-size: 1rem;
  }
}
</style>