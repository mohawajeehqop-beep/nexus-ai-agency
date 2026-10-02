import { apiFetch } from '@/lib/api';

export async function login(email: string, password: string) {
  return apiFetch('/api/v1/auth/token', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  });
}

export async function register(email: string, password: string, full_name?: string) {
  return apiFetch('/api/v1/auth/register', {
    method: 'POST',
    body: JSON.stringify({ email, password, full_name }),
  });
}
