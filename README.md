# suyash21101/.github

Central home for **reusable CI/CD workflow modules** consumed by my projects, plus (later) shared
community-health defaults. Modules live in `.github/workflows/` and are called via `workflow_call`.

Consumers reference them by the moving major tag `@v1` from a `pipeline.yml` orchestrator that
toggles stages at runtime via the `PIPELINE_CONFIG` Actions variable. See
`docs/PIPELINE_PLAYBOOK.md` §17 and `docs/GITHUB_DOTFILES_REPO_CHECKLIST.md` in the project template.

> This repo is **private**; cross-repo Actions access is enabled (Settings → Actions → General →
> "Accessible from repositories owned by the user account"), so any `suyash21101` repo can `uses:` it.

## Modules

| Module          | Purpose                          | Inputs                              | Secrets |
| --------------- | -------------------------------- | ----------------------------------- | ------- |
| `lint.yml`      | ESLint (`npm run lint`)          | `node_version` (default `"20"`)     | —       |
| `typecheck.yml` | `tsc --noEmit`                   | `node_version`                      | —       |
| `test.yml`      | Vitest + coverage gate           | `node_version`, `coverage_min` (80) | —       |
| `build.yml`     | `prisma generate` + `next build` | `node_version`                      | —       |

`coverage_min` overrides the consumer's `vitest.config.ts` line/statement/function thresholds, so the
`PIPELINE_CONFIG` value governs the gate.

## Usage

```yaml
# in a consumer repo's .github/workflows/pipeline.yml
jobs:
  lint:
    needs: config
    if: ${{ fromJSON(needs.config.outputs.cfg).stages.lint.enabled }}
    uses: suyash21101/.github/.github/workflows/lint.yml@v1

  test:
    needs: config
    if: ${{ fromJSON(needs.config.outputs.cfg).stages.test.enabled }}
    uses: suyash21101/.github/.github/workflows/test.yml@v1
    with:
      coverage_min: ${{ fromJSON(needs.config.outputs.cfg).stages.test.coverage_min }}
```

## Versioning

Semver tags (`v1.0.0`, `v1.1.0`, …) plus a **moving `v1`** tag consumers pin to.
Release: `git tag vX.Y.Z && git tag -f v1 && git push origin vX.Y.Z && git push -f origin v1`.
Bump to `@v2` only on an incompatible input/behavior change.
