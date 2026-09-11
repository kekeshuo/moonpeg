#!/usr/bin/env python3
"""Reproducible local/CI acceptance. Never silently skips a failed check."""
import argparse, json, pathlib, subprocess, sys, time
ROOT = pathlib.Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument('--target', action='append', choices=['wasm-gc','wasm','js','native'])
p.add_argument('--skip-native-runtime', action='store_true', help='Still typecheck native; record build/test/demo as unverified')
p.add_argument('--report', type=pathlib.Path)
a = p.parse_args()
records = []
def run(*command):
    begin = time.monotonic()
    r = subprocess.run(command, cwd=str(ROOT), stdout=subprocess.PIPE, stderr=subprocess.STDOUT, encoding='utf-8', errors='replace')
    records.append(dict(command=list(command), exit=r.returncode, seconds=round(time.monotonic()-begin,3), output=r.stdout))
    print('$ ' + ' '.join(command), flush=True)
    print(r.stdout, end='', flush=True)
    if r.returncode: raise RuntimeError('check failed')
try:
    run('moon','version','--all')
    run('moon','fmt','--check')
    run('moon','info')
    run('git','diff','--exit-code','--','*.mbti')
    for target in a.target or ['wasm-gc','wasm','js','native']:
        run('moon','check','--target',target,'--deny-warn')
        if target == 'native' and a.skip_native_runtime:
            records.append(dict(target=target,status='UNVERIFIED',reason='native build/test/example explicitly skipped; C compiler unavailable locally'))
            print('UNVERIFIED: native build/test/example (explicit flag)')
            continue
        run('moon','build','--target',target,'--release','--deny-warn')
        run('moon','test','--target',target,'--deny-warn')
        run('moon','run','examples/solve','--target',target)
        if target == 'js':
            for script in ['cli-test.cjs','examples.cjs','oracle.cjs']:
                run('node','scripts/'+script)
except (RuntimeError, OSError) as e:
    print(str(e), file=sys.stderr)
    sys.exitcode = 1
else:
    sys.exitcode = 0
finally:
    if a.report:
        a.report.parent.mkdir(parents=True,exist_ok=True)
        a.report.write_text(json.dumps(dict(exit=sys.exitcode,records=records),indent=2),encoding='utf-8')
sys.exit(sys.exitcode)
