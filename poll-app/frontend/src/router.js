import { createRouter, createWebHistory } from 'vue-router'
import HomeView from './views/HomeView.vue'
import AboutView from './views/AboutView.vue'
import PollView from './views/PollView.vue'
import AdminView from './views/AdminView.vue'
import PresentationView from './views/PresentationView.vue'
import ReviewView from './views/ReviewView.vue'
import ReviewFullView from './views/ReviewFullView.vue'
import FurtherReadingView from './views/FurtherReadingView.vue'

const routes = [
  {
    path: '/',
    name: 'home',
    component: HomeView
  },
  {
    path: '/disclaimer',
    name: 'disclaimer',
    component: HomeView
  },
  {
    path: '/about',
    name: 'about',
    component: AboutView
  },
  {
    path: '/vote',
    name: 'vote',
    component: PollView
  },
  {
    path: '/admin',
    name: 'admin',
    component: AdminView
  },
  {
    path: '/review',
    name: 'review',
    component: ReviewView
  },
  {
    path: '/review/full',
    name: 'review-full',
    component: ReviewFullView
  },
  {
    path: '/reading',
    name: 'reading',
    component: FurtherReadingView
  },
  {
    path: '/presentation',
    redirect: '/presentation/0'
  },
  {
    path: '/presentation/:slide',
    name: 'presentation',
    component: PresentationView
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    // If there's a saved position (e.g., back button), use it
    if (savedPosition) {
      return savedPosition
    }
    // Otherwise, scroll to top
    return { top: 0, behavior: 'smooth' }
  }
})

export default router
