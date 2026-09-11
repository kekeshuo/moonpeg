#!/usr/bin/env python3
"""Verify this unpublished library from a separate local consumer module."""
import json, pathlib, subprocess
root = pathlib.Path(__file__).resolve().parents[1]
consumer = (root / '_build' / 'consumer').resolve()
consumer.relative_to(root)  # Keep all generated files inside this project.
consumer.mkdir(parents=True, exist_ok=True)
(consumer/'moon.mod.json').write_text(json.dumps({'name':'local/moonpeg_smoke','deps':{'kekeshuo/moonpeg':{'path':str(root)}}}),encoding='utf-8')
(consumer/'moon.pkg.json').write_text(json.dumps({'import':[{'path':'kekeshuo/moonpeg','alias':'peg'},{'path':'kekeshuo/moonpeg/protocol','alias':'protocol'}]}),encoding='utf-8')
(consumer/'consumer.mbt').write_text('''pub fn smoke() -> Unit raise {
  let (board, start) = @peg.parse_board("oo.")
  match board.solve(start, AnySingle, 100).outcome {
    Solved(moves) => assert_true(board.verify_solution(start, moves, AnySingle))
    _ => fail("expected certificate")
  }
  assert_true(@protocol.handle("{}").length() > 0)
}
''',encoding='utf-8')
(consumer/'consumer_test.mbt').write_text('test "external API consumer" { smoke() }\n',encoding='utf-8')
for command in [['moon','check','--deny-warn'],['moon','test']]:
    subprocess.run(command,cwd=str(consumer),check=True)
print('Separate unpublished path-dependency consumer passed')
