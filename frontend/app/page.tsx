export default function HomePage() {
  return (
    <main className="min-h-screen bg-slate-950 text-white">
      <div className="mx-auto max-w-6xl px-6 py-16">
        <div className="inline-flex rounded-full border border-cyan-500/40 bg-cyan-500/10 px-3 py-1 text-sm text-cyan-300">
          NEXUS AI Agency
        </div>

        <h1 className="mt-8 text-5xl font-bold tracking-tight md:text-7xl">
          AI operating system for agency workflows
        </h1>

        <p className="mt-6 max-w-2xl text-lg text-slate-300">
          Route briefs, orchestrate specialist agents, coordinate execution, and deliver measurable output from a single control layer.
        </p>

        <div className="mt-10 flex flex-wrap gap-4">
          <button className="rounded-xl bg-cyan-500 px-5 py-3 font-medium text-slate-950 shadow-lg shadow-cyan-500/20 transition hover:bg-cyan-400">
            Start a project
          </button>
          <button className="rounded-xl border border-slate-700 px-5 py-3 font-medium text-slate-100 transition hover:border-slate-500 hover:bg-slate-900">
            View agents
          </button>
        </div>

        <div className="mt-16 grid gap-6 md:grid-cols-3">
          {[
            { title: '20 specialists', text: 'High-skill agents covering strategy, ops, content, monitoring, and legal review.' },
            { title: 'Live dashboard', text: 'Track tasks, quality, and execution metrics in real time.' },
            { title: 'Report-ready output', text: 'Generate structured final deliverables and exportable artifacts.' },
          ].map((item) => (
            <div key={item.title} className="rounded-2xl border border-slate-800 bg-slate-900 p-6">
              <h2 className="text-xl font-semibold text-cyan-300">{item.title}</h2>
              <p className="mt-3 text-slate-300">{item.text}</p>
            </div>
          ))}
        </div>
      </div>
    </main>
  );
}
