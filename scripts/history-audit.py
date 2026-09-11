#!/usr/bin/env python3
"""Audit actual Git commits against successful development check records; output outside Git."""
import argparse, datetime, json, pathlib, re, subprocess
ROOT = pathlib.Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument('--evidence', type=pathlib.Path, required=True)
p.add_argument('--output', type=pathlib.Path, required=True)
a = p.parse_args()
if ROOT == a.output.resolve() or ROOT in a.output.resolve().parents:
    p.error('audit output must stay outside the repository (self-referential SHA avoidance)')
def git(*args):
    return subprocess.check_output(['git', *args], cwd=str(ROOT), encoding='utf-8').strip()
records = {r['sha']: r for r in map(json.loads, a.evidence.read_text(encoding='utf-8').splitlines())}
shas = git('rev-list','--reverse','HEAD').splitlines()
items, valid = [], 0
for index, sha in enumerate(shas):
    subject = git('show','-s','--format=%s',sha)
    author = git('show','-s','--format=%an <%ae>',sha)
    date = git('show','-s','--format=%aI',sha)
    paths = git('diff-tree','--root','--no-commit-id','--name-only','-r',sha).splitlines()
    stats = git('show','--format=','--numstat',sha)
    record = records.get(sha)
    required = {('moon','fmt'),('moon','check','--deny-warn'),('moon','test')}
    checks = record.get('checks',[]) if record else []
    commands = {tuple(c['command']) for c in checks}
    test = next((c['output'].strip() for c in checks if c['command']==['moon','test']), '')
    success = bool(re.search(r'Total tests: (\d+), passed: \1, failed: 0',test))
    reason = 'valid: coherent implementation/test/engineering milestone with recorded checks'
    counted = bool(paths and stats and record and record['subject']==subject and required<=commands and success)
    if author != 'kekeshuo <327806699+kekeshuo@users.noreply.github.com>':
        counted = False; reason = 'excluded: unexpected author identity'
    elif not counted:
        reason = 'excluded: missing nonempty change or successful evidence'
    elif index == 0:
        counted = False; reason = 'excluded conservatively: foundation/design/license rather than implementation'
    valid += int(counted)
    items += [f'## {index+1}. {sha}', '', f'- Subject/purpose: {subject}', f'- Author: {author}',
              f'- Actual author timestamp: {date}', f'- Assessment: {reason}',
              '- Changed paths: '+', '.join(paths), '- Validation: moon fmt; moon check --deny-warn; '+test,
              '', 'Change statistics (added/deleted/path):', '```text',stats,'```','']
header = ['# MoonPeg actual commit audit', '', 'Generated: '+datetime.datetime.now().astimezone().isoformat(),
          'HEAD: '+git('rev-parse','HEAD'), f'Raw nonempty-history count: {len(shas)}',
          f'Conservative valid count: {valid} (required: 20)',
          'GitHub contribution attribution: NOT YET VERIFIED; these are local authors only.',
          '', 'Evidence source: per-commit records appended only after successful commands by the development helper.',
          'The foundation is deliberately excluded; failed/unrecorded checks cannot contribute to the threshold.',
          'No empty commits or history rewriting is used to meet the count.', '']
a.output.parent.mkdir(parents=True,exist_ok=True)
a.output.write_text('\n'.join(header+items)+'\n',encoding='utf-8')
print(f'raw={len(shas)}, conservative_valid={valid}, report={a.output}')
raise SystemExit(0 if valid>=20 else 1)
