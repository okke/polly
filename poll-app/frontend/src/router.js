import { createRouter, createWebHistory } from 'vue-router'
import PollView from './views/PollView.vue'
import AdminView from './views/AdminView.vue'

const routes = [
  {
    path: '/',
    name: 'poll',
    component: PollView
  },
  {
    path: '/admin',
    name: 'admin',
    component: AdminView
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
