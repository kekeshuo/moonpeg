'use strict';
// Independent reference: string occupancies and exhaustive DFS, no bitsets,
// symmetry, reverse generator, GF(2), or MoonBit internal search calls.
const assert = require('node:assert/strict');
const {handle} = require('../_build/js/release/build/cmd/bridge/bridge.js');
const fs = require('node:fs');
const started = Date.now();
let cases = 0, replayed = 0, obstructionChecks = 0;
function request(o) { return JSON.parse(handle(JSON.stringify({version:1,...o}))); }
function geometry(rows, lattice) {
  const cells = [];
  for (let y=0;y<rows.length;y++) for (let x=0;x<rows[y].length;x++) if (rows[y][x] !== '#') cells.push([x,y]);
  const jumps=[];
  // Enumerate endpoints and midpoint; deliberately not a directional offset compiler.
  for(let a=0;a<cells.length;a++) for(let c=0;c<cells.length;c++) {
    const [ax,ay]=cells[a], [cx,cy]=cells[c], dx=cx-ax,dy=cy-ay;
    const valid=(Math.abs(dx)===2&&dy===0)||(Math.abs(dy)===2&&dx===0)||
      (lattice==='triangular' && Math.abs(dx)===2 && dx===dy);
    if(!valid) continue;
    const mid=cells.findIndex(([x,y])=>2*x===ax+cx && 2*y===ay+cy);
    if(mid!==-1) jumps.push([a,mid,c]);
  }
  return {cells,jumps};
}
const enabled=(s,[a,b,c])=>s[a]==='1'&&s[b]==='1'&&s[c]==='0';
function apply(s,[a,b,c]) { const next=s.split('');next[a]='0';next[b]='0';next[c]='1';return next.join(''); }
function render(rows,state) { let i=0;return rows.map(row=>[...row].map(c=>c==='#'?'#':state[i++]==='1'?'o':'.').join('')).join('\n'); }
function matches(state,target) { return target===null?[...state].filter(c=>c==='1').length===1:state===target; }
function explore(state,target,jumps,memo) {
  if(matches(state,target)) return true;
  if(memo.has(state)) return memo.get(state);
  const result=jumps.some(j=>enabled(state,j)&&explore(apply(state,j),target,jumps,memo));
  memo.set(state,result);return result;
}
for(const [name, rows, lattice] of [
  ['line-6',['......'],'orthogonal'],
  ['square-3',['...','...','...'],'orthogonal'],
  ['triangle-4',['.###','..##','...#','....'],'triangular'],
  ['disconnected',['...#...'],'orthogonal'],
  ['irregular',['...','.##','...'],'orthogonal'],
]) {
  const {cells,jumps}=geometry(rows,lattice), n=cells.length;
  const targets=[null,...Array.from({length:n},(_,i)=>'0'.repeat(i)+'1'+'0'.repeat(n-i-1))];
  // Also exercise exact multi-peg goals, not merely singleton endgames.
  targets.push('11'+'0'.repeat(n-2));
  const memos=targets.map(()=>new Map());
  for(let occupancy=0;occupancy<2**n;occupancy++) {
    const state=occupancy.toString(2).padStart(n,'0');
    const board=render(rows,state);
    const analysis=request({command:'analyze',board,lattice});
    assert.equal(analysis.status,'ok');
    assert.deepEqual(analysis.jumps.map(String).sort(),jumps.map(String).sort(),name+' geometry');
    assert.deepEqual(analysis.legal_moves.map(i=>String(analysis.jumps[i])).sort(),jumps.filter(j=>enabled(state,j)).map(String).sort());
    for(let t=0;t<targets.length;t++) {
      const target=targets[t], goal=target===null?'any':render(rows,target);
      const expected=explore(state,target,jumps,memos[t]);
      const result=request({command:'solve',board,lattice,goal,budget:100000});
      assert.equal(result.status,expected?'solved':'unsolvable',JSON.stringify({name,state,target,result}));
      const evidence=request({command:'analyze',board,lattice,goal});
      if(evidence.obstructions.length) { assert.equal(expected,false,'false impossibility claim');obstructionChecks++; }
      if(result.status==='solved') {
        let current=state;
        for(const id of result.moves) {
          assert.ok(Number.isInteger(id)&&id>=0&&id<analysis.jumps.length);
          const jump=analysis.jumps[id];assert.ok(enabled(current,jump),'illegal solution');
          current=apply(current,jump);
        }
        assert.ok(matches(current,target));
        assert.equal(result.moves.length,[...state].filter(c=>c==='1').length-[...current].filter(c=>c==='1').length);
        replayed++;
      }
      cases++;
    }
  }
  console.log(`oracle: ${name}, ${2**n} occupancies x ${targets.length} goals passed`);
}
const summary={cases,replayed,obstructionChecks,elapsedMs:Date.now()-started};
console.log(JSON.stringify(summary));
if(process.argv[2]) fs.writeFileSync(process.argv[2],JSON.stringify(summary,null,2)+'\n');
