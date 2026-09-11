#!/usr/bin/env node
'use strict';
// Transport only. Puzzle parsing, validation, search and replay are MoonBit.
const fs = require('node:fs');
const path = require('node:path');
function error(message) {
  console.error(`moonpeg: ${message}`);
  process.exitCode = 2;
}
function main() {
  const args = process.argv.slice(2);
  if (args.length === 1 && args[0] === '--help') {
    console.log('Usage: node scripts/moonpeg.cjs [REQUEST.json|-]\nRead one UTF-8 JSON v1 request; default: stdin.\nExit: 0 ok/solved, 1 unsolvable, 2 invalid/IO, 3 exhausted.');
    return;
  }
  if (args.length > 1 || (args[0]?.startsWith('-') && args[0] !== '-')) {
    error('expected one file or -; use --help'); return;
  }
  const artifact = path.join(__dirname, '../_build/js/release/build/cmd/bridge/bridge.js');
  if (!fs.existsSync(artifact)) { error('build first: moon build --target js --release'); return; }
  let fd;
  try {
    fd = args.length && args[0] !== '-' ? fs.openSync(args[0], 'r') : 0;
    const data = Buffer.alloc(65537);
    let length = 0;
    while (length < data.length) {
      const n = fs.readSync(fd, data, length, data.length - length, null);
      if (!n) break;
      length += n;
    }
    if (length > 65536) { error('input exceeds 65536 bytes'); return; }
    const text = new TextDecoder('utf-8', { fatal: true }).decode(data.subarray(0, length));
    const output = require(artifact).handle(text);
    console.log(output);
    const status = JSON.parse(output).status;
    process.exitCode = { ok: 0, solved: 0, unsolvable: 1, error: 2, exhausted: 3 }[status] ?? 2;
  } catch (e) { error(e.code || (e instanceof TypeError ? 'invalid UTF-8' : 'transport failure')); }
  finally { if (fd !== undefined && fd !== 0) fs.closeSync(fd); }
}
main();
