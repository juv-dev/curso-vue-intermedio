import fs from 'fs'
import path from 'path'

const root = process.cwd()
const outputRoot = path.join(root, 'dist')

// crear dist raíz
fs.mkdirSync(outputRoot, { recursive: true })

// leer carpetas del root
const entries = fs.readdirSync(root, { withFileTypes: true })

for (const entry of entries) {
  if (!entry.isDirectory()) continue

  const projectPath = path.join(root, entry.name)
  const distPath = path.join(projectPath, 'dist')

  // ignorar node_modules y dist raíz
  if (['node_modules', 'dist', '.git', '.pnpm'].includes(entry.name)) {
    continue
  }

  if (fs.existsSync(distPath)) {
    const target = path.join(outputRoot, entry.name, 'dist')

    fs.mkdirSync(path.dirname(target), { recursive: true })
    fs.cpSync(distPath, target, { recursive: true })

    console.log(`✅ Collected: ${entry.name}`)
  }
}

console.log('🚀 All dist folders collected')
