<script setup>
import {ref} from 'vue'
import {useRoute} from 'vue-router'
import {useAuth} from '@/composables/useAuth'

const route = useRoute()
const menuOpen = ref(false)
const {user, signOut} = useAuth()

const links = [
  {label: 'Home', to: '/'},
  {label: 'World & Deities', to: '/world'},
  {label: 'Kingdoms', to: '/kingdom'},
  {label: 'NPCs', to: '/npcs'},
  {label: 'Sessions', to: '/sessions'},
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
        <template v-if="user">
          <span class="auth-email">{{ user.email }}</span>
          <button class="auth-signout" @click="signOut">Sign out</button>
        </template>
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