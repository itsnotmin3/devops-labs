import { revalidatePath } from 'next/cache'
import { getCollection } from '../lib/mongo'

// Render on every request (so it reads the DB live, not at build time).
export const dynamic = 'force-dynamic'

// A Server Action — this runs on the SERVER, inside the Next.js app itself.
async function addMessage(formData) {
  'use server'
  const text = (formData.get('text') || '').toString().trim()
  if (!text) return
  const col = await getCollection()
  await col.insertOne({ text, at: new Date().toISOString() })
  revalidatePath('/')
}

export default async function Home() {
  const col = await getCollection()
  const rows = await col.find().sort({ _id: -1 }).limit(50).toArray()
  const messages = rows.map((m) => ({ text: m.text, at: m.at }))

  return (
    <main style={{ maxWidth: 560, margin: '8vh auto', padding: '0 20px' }}>
      <h1 style={{ color: '#111827' }}>▲ Next.js + MongoDB</h1>
      <p style={{ color: '#6b7280' }}>
        The server is built into the Next.js app (a Server Action). It reads and writes MongoDB —
        all running in Docker Compose.
      </p>

      <form action={addMessage} style={{ display: 'flex', gap: 8, margin: '18px 0' }}>
        <input
          name="text"
          placeholder="Leave a message…"
          autoComplete="off"
          style={{ flex: 1, padding: 12, border: '1px solid #d1d5db', borderRadius: 10, fontSize: 15 }}
        />
        <button
          type="submit"
          style={{ padding: '12px 18px', border: 0, borderRadius: 10, background: '#111827', color: '#fff', fontSize: 15 }}
        >
          Post
        </button>
      </form>

      <ul style={{ listStyle: 'none', padding: 0 }}>
        {messages.length === 0 && <li style={{ color: '#9ca3af' }}>No messages yet — add one above.</li>}
        {messages.map((m, i) => (
          <li
            key={i}
            style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 12, padding: '12px 16px', marginBottom: 8 }}
          >
            {m.text}
            <br />
            <small style={{ color: '#9ca3af' }}>{m.at}</small>
          </li>
        ))}
      </ul>
    </main>
  )
}
