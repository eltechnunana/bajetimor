import { neon } from '@netlify/neon';

// Netlify Function: GET /api/get-post?id=<id>
// Queries a Neon Postgres database using NETLIFY_DATABASE_URL.
export default async (event) => {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };

  try {
    const id = event.queryStringParameters?.id;
    if (!id) {
      return { statusCode: 400, headers, body: JSON.stringify({ error: 'Missing id' }) };
    }

    const sql = neon(); // automatically uses env NETLIFY_DATABASE_URL
    const rows = await sql`SELECT * FROM posts WHERE id = ${id} LIMIT 1`;
    const post = rows?.[0] ?? null;

    return { statusCode: 200, headers, body: JSON.stringify({ post }) };
  } catch (err) {
    return { statusCode: 500, headers, body: JSON.stringify({ error: String(err) }) };
  }
}