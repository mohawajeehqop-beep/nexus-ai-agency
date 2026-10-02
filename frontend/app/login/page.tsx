import { useState } from 'react';
import { login } from '@/lib/auth';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  async function handleSubmit(e: any) {
    e.preventDefault();
    try {
      const res: any = await login(email, password);
      if (res?.access_token) {
        localStorage.setItem('nexus_token', res.access_token);
        window.location.href = '/dashboard';
      } else {
        setError('Login failed');
      }
    } catch (err) {
      setError('Login failed');
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-slate-900 text-white">
      <form onSubmit={handleSubmit} className="w-full max-w-md p-6 bg-slate-800 rounded-lg">
        <h2 className="text-2xl mb-4">تسجيل الدخول</h2>
        {error && <div className="text-red-400 mb-2">{error}</div>}
        <input className="w-full p-3 mb-3 rounded bg-slate-700" placeholder="البريد الإلكتروني" value={email} onChange={(e) => setEmail(e.target.value)} />
        <input type="password" className="w-full p-3 mb-3 rounded bg-slate-700" placeholder="كلمة المرور" value={password} onChange={(e) => setPassword(e.target.value)} />
        <button className="w-full p-3 rounded bg-cyan-500 text-slate-900">دخول</button>
      </form>
    </div>
  );
}
