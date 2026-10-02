// Simple API helper for the frontend to call the backend and handle JWT token

export async function apiFetch(path: string, opts: any = {}) {
  const token = typeof window !== 'undefined' ? localStorage.getItem('nexus_token') : null;
  const headers = opts.headers || {};
  if (token) headers['Authorization'] = `Bearer ${token}`;
  headers['Content-Type'] = headers['Content-Type'] || 'application/json';
  const res = await fetch((process.env.NEXT_PUBLIC_API_URL || '') + path, { ...opts, headers });
  if (res.status === 401) {
    // handle logout
    if (typeof window !== 'undefined') localStorage.removeItem('nexus_token');
  }
  return res.json();
}
