'use strict';
const assert = require('node:assert/strict');
const {spawnSync} = require('node:child_process');
const path = require('node:path');
const cli = path.join(__dirname, 'moonpeg.cjs');
function call(input, args = []) { return spawnSync(process.execPath, [cli, ...args], {input, encoding:'utf8', timeout:15000}); }
const request = {version:1, command:'solve', board:'oo.'};
for (const [patch, status, exit] of [[{},'solved',0], [{board:'o.o'},'unsolvable',1], [{budget:0},'exhausted',3], [{budget:-1},'error',2]]) {
  const r = call(JSON.stringify({...request,...patch}));
  assert.equal(r.error, undefined); assert.equal(r.status, exit, r.stderr);
  assert.equal(JSON.parse(r.stdout).status, status);
}
for (const bad of ['{', Buffer.from([255]), 'x'.repeat(65537)]) assert.equal(call(bad).status, 2);
assert.equal(call('', ['--help']).status, 0);
assert.equal(call('', ['--unknown']).status, 2);
assert.equal(call('', ['not-a-real-file-moonpeg.json']).status, 2);
const fs = require('node:fs'), os = require('node:os');
const dir = fs.mkdtempSync(path.join(os.tmpdir(),'moonpeg-cli-'));
const file = path.join(dir,'request with spaces.json');
try {
  fs.writeFileSync(file, JSON.stringify(request));
  const r = call('', [file]); assert.equal(r.status,0,r.stderr);
  assert.deepEqual(JSON.parse(r.stdout).moves,[0]);
} finally { fs.unlinkSync(file); fs.rmdirSync(dir); }
console.log('CLI: 11 process/transport cases passed');
