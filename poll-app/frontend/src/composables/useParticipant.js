import { ref } from 'vue'

// Generate UUID (fallback for older browsers)
function generateUUID() {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) {
    return crypto.randomUUID()
  }
  // Fallback for older browsers
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0
    const v = c === 'x' ? r : (r & 0x3 | 0x8)
    return v.toString(16)
  })
}

// Initialize participant ID immediately (not in onMounted)
function getOrCreateParticipantId() {
  try {
    // Check if we're in browser environment
    if (typeof window !== 'undefined' && window.localStorage) {
      let id = localStorage.getItem('polly-participant-id')
      
      if (!id) {
        id = generateUUID()
        localStorage.setItem('polly-participant-id', id)
      }
      
      return id
    }
  } catch (e) {
    console.error('Error accessing localStorage:', e)
  }
  
  // Fallback
  return generateUUID()
}

const participantId = ref(getOrCreateParticipantId())

export function useParticipant() {
  
  function getShortId() {
    if (!participantId.value) return '...'
    return participantId.value.substring(0, 8)
  }
  
  function resetId() {
    const id = generateUUID()
    try {
      localStorage.setItem('polly-participant-id', id)
    } catch (e) {
      console.error('Failed to save new participant ID:', e)
    }
    participantId.value = id
    return id
  }
  
  return {
    participantId,
    getShortId,
    resetId
  }
}
