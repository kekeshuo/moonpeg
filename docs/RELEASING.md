# Release verification and source distribution

## Observed public acceptance

The repository is [kekeshuo/moonpeg](https://github.com/kekeshuo/moonpeg), public with
`kekeshuo` as owner. On 2026-09-11, GitHub REST resolved both author and committer
of all 22 initial commits to that account (not merely matching local author text).
The authenticated operation had ADMIN access. Credentials were scoped to the child
process; neither global Git identity nor another window's active GitHub account changed.
Anonymous REST reads hit a shared-IP rate limit; authenticated reads of the public
repository provided the commit-attribution evidence.

[Initial hosted run 34613980106](https://github.com/kekeshuo/moonpeg/actions/runs/34613980106)
passed at source commit `a21ac9b03da1c92f0eeb5aad9965d07f8f267a94`:

- Ubuntu 24.04: wasm-gc, wasm, js and native strict checks, release builds,
  43 tests per target and the real tutorial.
- JS job additionally exercises 11 CLI process cases, eight request fixtures,
  the separate consumer smoke test and 20096 independent oracle cases.
- Oracle results: 1164 solutions replayed and 15606 necessary obstructions checked.
- Native execution is hosted evidence only: the local Windows machine has no C compiler.

This document records an earlier immutable run rather than predicting a future run's
result. Release acceptance additionally requires the final default-branch SHA to pass
its own four-target run before a tag is created. Consult the Release target and matching
[Actions run](https://github.com/kekeshuo/moonpeg/actions) for the final source SHA.

## Reproduce the release

After the non-draft v0.1.0 GitHub Release exists:

```sh
git clone --branch v0.1.0 https://github.com/kekeshuo/moonpeg.git
cd moonpeg
python scripts/verify.py
```

Use the compiler/core version in the workflow. Native requires a C compiler. On a
machine without one, `--skip-native-runtime` explicitly records that omission instead
of claiming all-target acceptance. The Node/Python entrypoints use standard libraries.
The tag distributes source, not precompiled binaries or an installed MoonCakes package.

## Maintainer checklist

1. Keep participant contact details and submission files outside the Git tree.
2. Confirm the child process's `gh api user` login, repository owner/push permission,
   exact push URL and repository-local author identity before each push.
3. Run local verification; commit coherent changes with evidence, not empty count padding.
4. Push the intended default-branch SHA. Require success for every matrix job at that SHA.
5. Create an annotated version tag at that same SHA and a non-draft, non-prerelease
   GitHub Release. Do not move or overwrite an existing public version tag.
6. Re-read default branch, tag object/peeled commit, Release state, CI result and public
   commit-author mapping. Keep the final SHA-bearing audit outside Git to avoid a
   self-referential document that changes the commit it describes.
7. Run the strict application checker after the participant supplies name/contact.
   Final competition submission remains a participant action.

No MoonCakes publication is part of this release procedure. It is a separate manual
participant step, or a separately and explicitly requested assistance task.
