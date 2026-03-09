import { ref, onMounted } from 'vue'

const participantId = ref(null)

export function useParticipant() {
  onMounted(() => {
    // Try to get existing ID from localStorage
    let id = localStorage.getItem('polly-participant-id')
    
    if (!id) {
      // Generate new UUID
      id = crypto.randomUUID()
      localStorage.setItem('polly-participant-id', id)
    }
    
    participantId.value = id
  })
  
  function getShortId() {
    if (!participantId.value) return '...'
    return participantId.value.substring(0, 8)
  }
  
  function resetId() {
    const id = crypto.randomUUID()
    localStorage.setItem('polly-participant-id', id)
    participantId.value = id
    return id
  }
  
  return {
    participantId,
    getShortId,
    resetId
  }
}
