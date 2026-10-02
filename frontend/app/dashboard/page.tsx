export default function DashboardPage() {
  return (
    <main className="min-h-screen p-8 bg-slate-900 text-white">
      <h1 className="text-3xl font-bold mb-4">لوحة التحكم</h1>
      <p className="text-slate-300">مرحباً بك في لوحة NEXUS — هنا ستجد حالة المشاريع والمهام والوكلاء.</p>

      <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="p-4 rounded bg-slate-800">Projects: --</div>
        <div className="p-4 rounded bg-slate-800">Tasks: --</div>
        <div className="p-4 rounded bg-slate-800">Agents: 20</div>
      </div>
    </main>
  );
}
