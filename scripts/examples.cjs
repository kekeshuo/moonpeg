'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {handle}=require('../_build/js/release/build/cmd/bridge/bridge.js');
const request=q=>JSON.parse(handle(JSON.stringify(q)));
for(const [file,status] of [['line','solved'],['triangle','solved'],['generate','ok'],['hints','ok'],['impossible','unsolvable'],['exhausted','exhausted'],['replay','ok'],['disconnected','ok']]) {
  const q=JSON.parse(fs.readFileSync(path.join(__dirname,'../examples/requests/'+file+'.json'),'utf8'));
  const r=request(q);assert.equal(r.status,status,file);
  if(r.status==='solved')assert.equal(request({...q,command:'replay',budget:undefined,moves:r.moves}).valid_solution,true);
  if(file==='generate')assert.equal(request({version:1,command:'replay',board:r.board,goal:r.goal,moves:r.moves}).valid_solution,true);
  if(file==='hints')for(const h of r.hints)if(h.result.status==='solved')assert.equal(request({...q,command:'replay',budget:undefined,moves:h.result.moves}).valid_solution,true);
  if(file==='disconnected')assert.ok(r.obstructions.includes('jump-components'));
  if(file==='replay')assert.equal(r.valid_solution,true);
  console.log(`${file}: ${status}`);
}
console.log('All 8 documented requests and their certificates passed');
