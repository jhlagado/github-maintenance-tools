# github-maintenance-tools

Small helpers for tending a GitHub account or organization: inventories, taxonomy via topics, and room to grow (archival workflows, stale-repo reports, scripted topic edits).

## Requirements

- [GitHub CLI](https://cli.github.com/) (`gh`) with `gh auth login`
- [jq](https://stedolan.github.io/jq/)

## Repo inventory (`github-repo-inventory`)

Exports everything `gh repo list` can expose for triage JSON/CSV snapshots.

From the repo root:

```bash
bash scripts/github-repo-inventory.sh
```

Useful environment variables:

| Variable | Purpose |
|----------|---------|
| `OWNER` | User or organization (if unset, uses `gh api user`, then see fallback below) |
| `GITHUB_REPO_AUDIT_OWNER` | Fallback login/org when `gh api user` fails (common with narrow integration tokens) |
| `LIMIT` | Max repos (default `9999`) |
| `INCLUDE_FORKS` | Set to any value to include forks |
| `GITHUB_REPO_AUDIT_OUT` | Output directory (default `./github-repo-audit`) |
| `ENRICH_JQ` | Override path to the scoring/filter jq program |

If `gh api user` is blocked (some integration tokens), set **`OWNER`** or **`GITHUB_REPO_AUDIT_OWNER`** to your login or org.

Output files are dated: `repos-<OWNER>-<timestamp>.{json,-enriched.json,-triage.csv}`.

Tune the heuristic **`audit_score_triage`** in `scripts/github-repo-inventory-enrich.jq`.

## Bulk archive (run with your own `gh` auth)

Automation tokens often cannot call GitHub’s archive API. With `gh auth login` as a user who can manage the repos:

```bash
OWNER=jhlagado bash scripts/github-repo-archive-batch.sh \
  json-data x zedforth stack-programming zeforth jh-lagado.com start-workshop \
  vite-23a vanilla tig vite-23 siena scan ts-loCal react-vs-svelte loCal \
  form-recoil menta text stc-forth SerMon fedit tailwind-parcel forth-memory \
  webforth-cli fstackbags fbags obags nodets Joy-Programming ts-forth Counter1 \
  hardware basic-ce working-with-custom-elements expr1 angry-redux-starter phample
```

You can also pipe one repo name per line on stdin. Each run uses `gh repo archive OWNER/NAME -y`.

## Suggested repo topics

Use GitHub topics as a taxonomy, for example:

- `lifecycle:active`, `lifecycle:experiment`, `lifecycle:paused`, …
- `priority:must-keep`, `priority:candidate-delete`, …
- `maturity:sketch`, `maturity:maintained`, …

Topics recognized by the scorer are documented in comments at the top of `scripts/github-repo-inventory-enrich.jq`.

## License

Unlicensed; add a `LICENSE` if you publish publicly.