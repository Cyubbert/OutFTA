// One-off migration helper: converts public/images/* into compressed WebP files
// under scripts/compressed-images/, preserving base filenames.
import { readdir, mkdir, stat, copyFile } from 'node:fs/promises'
import path from 'node:path'
import sharp from 'sharp'

const SRC_DIR = path.resolve('public/images')
const OUT_DIR = path.resolve('scripts/compressed-images')

async function main() {
  await mkdir(OUT_DIR, { recursive: true })
  const files = (await readdir(SRC_DIR)).filter((f) => !f.startsWith('.'))

  let totalBefore = 0
  let totalAfter = 0

  for (const file of files) {
    const srcPath = path.join(SRC_DIR, file)
    const ext = path.extname(file).toLowerCase()
    const base = path.basename(file, ext)
    const before = (await stat(srcPath)).size
    totalBefore += before

    if (ext === '.svg') {
      const outPath = path.join(OUT_DIR, file)
      await copyFile(srcPath, outPath)
      const after = (await stat(outPath)).size
      totalAfter += after
      console.log(`${file}: kept as-is (svg)`)
      continue
    }

    const outPath = path.join(OUT_DIR, `${base}.webp`)
    await sharp(srcPath).webp({ quality: 80 }).toFile(outPath)
    const after = (await stat(outPath)).size
    totalAfter += after
    const pct = (100 * (1 - after / before)).toFixed(0)
    console.log(`${file} -> ${base}.webp: ${(before / 1e6).toFixed(2)}MB -> ${(after / 1e6).toFixed(2)}MB (-${pct}%)`)
  }

  console.log('---')
  console.log(`Total: ${(totalBefore / 1e6).toFixed(1)}MB -> ${(totalAfter / 1e6).toFixed(1)}MB`)
}

main()
