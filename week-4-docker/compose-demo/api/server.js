const express = require('express')
const os = require('os')
const { MongoClient } = require('mongodb')

const app = express()
const PORT = process.env.PORT || 3000
const MONGO_URL = process.env.MONGO_URL || 'mongodb://db:27017'

let visits

// The API often starts before Mongo is ready — retry the connection.
async function connectWithRetry() {
  const client = new MongoClient(MONGO_URL)
  for (let i = 1; i <= 30; i++) {
    try {
      await client.connect()
      return client
    } catch (err) {
      console.log(`waiting for MongoDB at ${MONGO_URL}... (${i})`)
      await new Promise((r) => setTimeout(r, 2000))
    }
  }
  throw new Error('could not connect to MongoDB')
}

async function start() {
  const client = await connectWithRetry()
  visits = client.db('demo').collection('visits')
  console.log('connected to MongoDB')

  app.get('/api', async (req, res) => {
    await visits.updateOne({ _id: 'counter' }, { $inc: { count: 1 } }, { upsert: true })
    const doc = await visits.findOne({ _id: 'counter' })
    res.json({
      message: 'Hello from the API + MongoDB',
      visits: doc.count,
      api_host: os.hostname(),
    })
  })

  app.get('/health', (req, res) => res.send('OK'))

  app.listen(PORT, () => console.log(`api listening on ${PORT}`))
}

start().catch((err) => {
  console.error(err)
  process.exit(1)
})
