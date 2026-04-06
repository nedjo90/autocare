const DIRECTUS_URL = 'https://adventurous-determination-production.up.railway.app'
const DIRECTUS_TOKEN = 'frontend-readonly-token'

async function fetchDirectus(path: string) {
  try {
    const res = await fetch(`${DIRECTUS_URL}${path}`, {
      headers: { Authorization: `Bearer ${DIRECTUS_TOKEN}` },
    })
    const json = await res.json()
    return json.data || []
  } catch {
    return []
  }
}

export async function getSiteSettings() {
  return fetchDirectus('/items/site_settings')
}

export async function getServices() {
  return fetchDirectus('/items/services?filter[actif][_eq]=true&sort=nom')
}

export async function getHoraires() {
  return fetchDirectus('/items/horaires?sort=jour')
}

export function imageUrl(fileId: string | null) {
  if (!fileId) return null
  return `${DIRECTUS_URL}/assets/${fileId}?access_token=${DIRECTUS_TOKEN}`
}

export { DIRECTUS_URL, DIRECTUS_TOKEN }
