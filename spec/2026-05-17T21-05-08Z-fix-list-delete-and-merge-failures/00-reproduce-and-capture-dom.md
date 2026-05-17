# 00 - Reproduce failures and capture DOM evidence

Before touching any code in `groceries-client` or `groceries-service`, reproduce all 9 failures locally against current HEAD of `groceries-client` + `groceries-service`, and capture the rendered HTML / a screenshot at the moment `wait_for` times out. This evidence drives the root-cause work in subspecs 01 and 02 and prevents a fix landing against a misdiagnosed symptom.

## Scope

- This subspec produces **diagnostic artifacts only**. No production code changes, no spec changes that ship to master.
- Add a temporary debug hook (e.g. an RSpec `around` block guarded by an env var, or a one-off `before` hook in a scratch file) that on failure calls `save_page` / `Capybara::Page#save_screenshot` and writes to `tmp/capybara/`. Remove the hook before merging the implementation PR.
- Capture artifacts for at least one example from each failing line in `spec/support/shared_examples/lists.rb`: lines 143, 192, 232, 287, 364, 397, 442 (Cluster A) and 516, 646 (Cluster B).
- For Cluster A, capture the DOM **after** the trash/reject click but before the timeout. Confirm whether `data-test-id="confirm-delete"` / `confirm-reject` is absent, present-but-hidden, or present under a different ancestor.
- For Cluster B, capture the DOM **of the merged list page** at the point `find_list_item` is searching. Confirm whether expected item text is in the DOM at all, and if so, what `data-test-class` wraps it.
- Also capture the API response body for the merge endpoint (network tab or a server-side log scrape) for at least the `multiSelect merge successfully merges lists of same type with proper name` case.

## Decisions

- Run against the same Ruby/Node versions CI uses; do not upgrade dependencies as part of repro.
- Use `rspec --no-retry` (or set the retry count to 1) so each failure produces a single artifact set rather than 3.
- Do not extend `Helpers::WaitHelper` timeouts to "get more data" — the goal is to see the state at the exact wait the production CI run sees.

## Tasks

- [ ] Start `groceries-service` and `groceries-client` from their current `master` HEADs locally.
- [ ] Add temporary on-failure DOM/screenshot capture in this repo (do not commit to `master`).
- [ ] Run each of the 9 failing examples individually and collect artifacts.
- [ ] Summarize findings per cluster in a short note attached to the implementation PR (`groceries-client` PR description, or a comment on the spec PR). Identify which subspec's hypothesis the evidence supports or contradicts.
- [ ] Inspect `groceries-client` `git log` since the failing-suite last passed for commits to `src/routes/lists/containers/ListsContainer.tsx`, `src/components/domain/ListCard.tsx`, `src/components/domain/ConfirmDialog.tsx`, and the merge endpoint handler. Note suspect commits in the same summary.

## Acceptance criteria

- [ ] All 9 failing examples have been re-run locally against current `groceries-client` + `groceries-service` HEADs and the failure mode is the same `"full wait time lapsed"` from the original report (i.e. failures are reproducible, not env-specific).
- [ ] DOM snapshot (HTML) and screenshot artifacts exist for at least one example from each `wait_for` site listed in Scope.
- [ ] For Cluster A, written conclusion identifies whether `confirm-delete` / `confirm-reject` is missing from the DOM, hidden by CSS, or mounted under an unexpected ancestor.
- [ ] For Cluster B, written conclusion identifies whether the merged list page contains the expected item text in any form, and (if yes) which `data-test-class` wraps it.
- [ ] Suspect commit list in `groceries-client` (and `groceries-service` if relevant) is recorded for use by subspecs 01 and 02.
- [ ] No diagnostic hooks are merged into `groceries_features` master; the repro changes remain local.
