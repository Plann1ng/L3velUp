import { GOALS, GOAL_DESCRIPTIONS, GOAL_LABELS } from '@l3velup/shared';

export default function DashboardPage() {
  return (
    <main className="min-h-screen bg-slate-50 p-12">
      <div className="max-w-4xl mx-auto">
        <div className="mb-10">
          <h1 className="text-4xl font-extrabold text-slate-900 mb-2">L3velUp Admin</h1>
          <p className="text-slate-500 text-lg">Gym management dashboard — scaffold ready</p>
        </div>

        <section>
          <h2 className="text-xl font-semibold text-slate-700 mb-4">
            Supported Training Goals ({GOALS.length})
          </h2>
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
            {GOALS.map((goal) => (
              <div
                key={goal}
                className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm"
              >
                <p className="font-semibold text-slate-800 text-sm mb-1">{GOAL_LABELS[goal]}</p>
                <p className="text-slate-500 text-xs leading-relaxed">{GOAL_DESCRIPTIONS[goal]}</p>
              </div>
            ))}
          </div>
        </section>
      </div>
    </main>
  );
}
