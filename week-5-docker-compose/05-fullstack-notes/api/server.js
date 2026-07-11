const express = require('express')
const { MongoClient } = require('mongodb')

const app = express()
app.use(express.json())

const PORT = process.env.PORT || 3000
const MONGO_URL = process.env.MONGO_URL || 'mongodb://db:27017'

let notes

// Mongo may start after the API — retry the connection.
async function connectWithRetry() {
  const client = new MongoClient(MONGO_URL)
  for (let i = 1; i <= 30; i++) {
    try {
      await client.connect()
      return client
    } catch (err) {
      console.log(`waiting for MongoDB... (${i})`)
      await new Promise((r) => setTimeout(r, 2000))
    }
  }
  throw new Error('could not connect to MongoDB')
}

async function start() {
  const client = await connectWithRetry()
  notes = client.db('notesapp').collection('notes')
  console.log('connected to MongoDB')

  // list notes (newest first)
  app.get('/api/notes', async (req, res) => {
    const list = await notes.find().sort({ _id: -1 }).toArray()
    res.json(list)
  })

  // add a note
  app.post('/api/notes', async (req, res) => {
    const text = ((req.body && req.body.text) || '').trim()
    if (!text) return res.status(400).json({ error: 'text is required' })
    await notes.insertOne({ text, at: new Date().toISOString() })
    res.status(201).json({ ok: true })
  })

  app.get('/health', (req, res) => res.send('OK'))

  app.listen(PORT, () => console.log(`notes-api listening on ${PORT}`))
}

start().catch((err) => {
  console.error(err)
  process.exit(1)
})
