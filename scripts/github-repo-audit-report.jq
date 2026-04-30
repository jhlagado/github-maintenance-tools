# Input: enriched JSON array from github-repo-inventory (audit_* fields).
# Output: Markdown to stdout. Use -r for literal newlines:
#   jq -r --arg owner LOGIN -f scripts/github-repo-audit-report.jq enriched.json > report.md

def row: "| `\(.nameWithOwner)` | \(.audit_score_triage) | \(.stargazerCount) | \(if (.pushedAt | type) == "string" then .pushedAt[0:10] else "—" end) | \(if ((.audit_days_since_push | type) == "number") then "\(.audit_days_since_push)d" else "—" end) |";

def table_head: "| Repo | Triage score | Stars | Last push | Days since push |\n|------|-------------:|------:|-----------|----------------:|\n";

def section(title; rows):
  if (rows | length) == 0 then
    "## \(title)\n\n_(none)_\n\n"
  else
    "## \(title)\n\n" + table_head + (rows | map(row) | join("\n")) + "\n\n"
  end;

def now_utc: (now | strftime("%Y-%m-%d %H:%M UTC"));

  (length) as $total
| ([.[] | select(.isArchived)] | length) as $arch
| (sort_by(-.audit_score_triage) | .[0:30]) as $top
| ([.[] | select(.isArchived | not)
    | select(.audit_score_triage <= -5)
    | select((.audit_days_since_push // 0) > 730)
    | select(.stargazerCount <= 2)
    ] | sort_by(.audit_score_triage)) as $archive_q
| ([.[] | select(.isArchived | not)
    | select(.audit_score_triage <= -5)
    | select(.stargazerCount > 3)
    ] | sort_by(-.stargazerCount)) as $star_review
| [
    "# GitHub repo audit report\n\n",
    "**Owner:** `\($owner)`  \n",
    "**Generated:** \(now_utc)\n\n",
    "## Summary\n\n",
    "- **Total repos in snapshot:** \($total)\n",
    "- **Already archived:** \($arch)\n",
    "- **Archive review queue** (not archived, score ≤ −5, no push in ~2y, ≤2 stars): **\($archive_q | length)**\n\n",
    "Suggested topic vocabulary: `lifecycle:*`, `priority:*`, `maturity:*` (see toolkit README).\n\n",
    "### Quick labeling\n\n",
    "- **Active / important:** `lifecycle:active`, `priority:must-keep`, `maturity:maintained`\n",
    "- **Experiment / sandbox:** `lifecycle:experiment`, `maturity:sketch`\n",
    "- **Ready to archive:** `lifecycle:archive-ready`, `priority:candidate-archive`, then GitHub **Archive**\n\n",
    section("Strongest candidates for archival review (lowest scores in queue, first 20)"; ($archive_q | .[0:20])),
    section("All archive-queue repos (\($archive_q | length) total)"; $archive_q),
    section("Low triage score but higher stars — review before archiving"; $star_review),
    section("Highest triage scores — likely keep / label active"; $top)
  ]
| add
