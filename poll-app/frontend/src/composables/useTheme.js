import { ref, watch, onMounted } from 'vue'
import { usePreferredDark, useStorage } from '@vueuse/core'

const isDark = ref(true)

export function useTheme() {
  const prefersDark = usePreferredDark()
  const storedTheme = useStorage('polly-theme', 'dark')
  
  onMounted(() => {
    // Initialize based on stored preference or system preference
    if (storedTheme.value === 'system') {
      isDark.value = prefersDark.value
    } else {
      isDark.value = storedTheme.value === 'dark'
    }
  })
  
  // Watch for system preference changes when in 'system' mode
  watch(prefersDark, (newValue) => {
    if (storedTheme.value === 'system') {
      isDark.value = newValue
    }
  })
  
  function toggleTheme() {
    isDark.value = !isDark.value
    storedTheme.value = isDark.value ? 'dark' : 'light'
  }
  
  function setTheme(theme) {
    storedTheme.value = theme
    if (theme === 'system') {
      isDark.value = prefersDark.value
    } else {
      isDark.value = theme === 'dark'
    }
  }
  
  return {
    isDark,
    toggleTheme,
    setTheme,
    storedTheme
  }
}
