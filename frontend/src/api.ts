export const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ?? 'http://127.0.0.1:18082'

type ApiEnvelope<T> = {
  success: boolean
  message: string
  data: T
  timestamp: string
}

type RequestOptions = RequestInit & {
  authenticated?: boolean
}

export async function apiRequest<T>(
  path: string,
  options: RequestOptions = {},
): Promise<T> {
  const headers = new Headers(options.headers ?? {})
  headers.set('Content-Type', 'application/json')

  if (options.authenticated !== false) {
    const token = localStorage.getItem('four-survey-token')
    if (token) {
      headers.set('Authorization', `Bearer ${token}`)
    }
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers,
  })

  const envelope = (await response.json()) as ApiEnvelope<T>

  if (!response.ok || !envelope.success) {
    throw new Error(envelope.message || 'Request failed')
  }

  return envelope.data
}
