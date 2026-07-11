import { MongoClient } from 'mongodb'

const uri = process.env.MONGO_URL || 'mongodb://db:27017'
let clientPromise

// Connect lazily (only on the first request, not at build time) and retry
// if Mongo is not ready yet.
export async function getCollection() {
  try {
    if (!clientPromise) clientPromise = new MongoClient(uri).connect()
    const client = await clientPromise
    return client.db('nextapp').collection('messages')
  } catch (err) {
    clientPromise = undefined // reset so the next request tries again
    throw err
  }
}
