// One-off migration helper: uploads scripts/compressed-images/* to the Supabase
// "images" storage bucket using the service_role key (bypasses RLS for writes).
// Run with: node --env-file=.env scripts/upload-images.js
import { readdir, readFile } from 'node:fs/promises'
import path from 'node:path'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
    process.env.VITE_SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
)

const SRC_DIR = path.resolve('scripts/compressed-images')
const BUCKET = 'images'

const CONTENT_TYPES = { '.webp': 'image/webp', '.svg': 'image/svg+xml' }

async function main() {
  const files = (await readdir(SRC_DIR)).filter((f) => !f.startsWith('.'))
  let ok = 0
  let failed = 0

  for (const file of files) {
    const filePath = path.join(SRC_DIR, file)
    const ext = path.extname(file).toLowerCase()
    const buffer = await readFile(filePath)

    const { error } = await supabase.storage.from(BUCKET).upload(file, buffer, {
      contentType: CONTENT_TYPES[ext] ?? 'application/octet-stream',
      upsert: true,
    })

    if (error) {
      console.error(`FAILED: ${file} - ${error.message}`)
      failed++
    } else {
      ok++
    }
  }

  console.log(`---\nUploaded ${ok} files, ${failed} failed.`)
}

main()
