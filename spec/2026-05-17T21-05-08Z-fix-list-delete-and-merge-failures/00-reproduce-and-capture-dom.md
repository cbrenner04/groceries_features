# 00 - Prepare evidence capture and wait for user-run test results

Before touching any code in `groceries-client` or `groceries-service`, use the failures already captured in `intent.md` as the baseline diagnosis. Do not require an agent-run reproduction as the first step. Agents have not been reliable at running this feature suite end-to-end, so the agent should first inspect code and, if more runtime evidence is still needed, add targeted logging or temporary diagnostic capture and then explicitly hand the test run to the user.

This subspec is an **investigation prerequisite**, not a production deliverable. Its output is a written evidence note in `spec/2026-05-17T21-05-08Z-fix-list-delete-and-merge-failures/evidence.md`, plus any temporary local diagnostics needed to produce that note. Mark this index entry complete when the agent has reviewed the user-provided evidence and recorded the conclusions needed by subspecs 01 and 02.

## User-run handoff

When the agent determines another runtime test run is necessary, it must add a new `## Blocker` section with the exact tasks the user needs to complete. Do not leave a generic `## Blocker` heading in the spec. The blocker should be added only when the agent is ready for the user-run step, and it must be specific:

- the exact command(s) to run;
- which repos/branches must be running (`groceries-client`, `groceries-service`, and this repo);
- any temporary logging, env var, or diagnostic hook that was added;
- where the generated artifacts are expected to be written;
- what summary the user should paste into `evidence.md`.

The user will run the requested tests, record the results in `evidence.md`, and remove the concrete blocker section before the agent continues. After the blocker is removed, the agent must review `evidence.md` before making or finalizing fixes in subspecs 01 or 02.

## Scope

- Start from `intent.md`; do not spend time proving the already-recorded 9 failures exist unless new evidence is needed to choose the implementation fix.
- Diagnostic artifacts only. No production code changes from this subspec, and no spec changes that ship to master solely for diagnostics.
- If runtime evidence is needed, prefer targeted logging or a guarded temporary debug hook (for example, an RSpec `around` block guarded by an env var, or a one-off local hook that on failure calls `save_page` / `Capybara::Page#save_screenshot` and writes to `tmp/capybara/`). Keep the hook on a throwaway local branch or remove it before opening a PR.
- Ask the user to capture the minimum evidence needed to disambiguate the root cause. Prefer one representative example per cluster unless the first run contradicts `intent.md` or exposes a new symptom.
- For Cluster A, requested evidence should capture the DOM **after** the trash/reject click but before the timeout. Confirm whether `data-test-id="confirm-delete"` / `confirm-reject` is absent, present-but-hidden, or present under a different ancestor.
- For Cluster B, requested evidence should capture the DOM **of the merged list page** at the point `find_list_item` is searching. Confirm whether expected item text is in the DOM at all, and if so, what `data-test-class` wraps it.
- If the merge layer remains ambiguous, request the API response body for the merge endpoint (network tab or a server-side log scrape) for at least the `multiSelect merge successfully merges lists of same type with proper name` case.

## Decisions

- The user, not the agent, owns any required feature-suite run. The agent owns making the requested run precise, adding/removing any temporary diagnostics it controls, and reviewing the user's evidence.
- Run against the same Ruby/Node versions CI uses; do not upgrade dependencies as part of evidence capture.
- Use `rspec --no-retry` (or set the retry count to 1) so each failure produces a single artifact set rather than 3.
- Do not extend `Helpers::WaitHelper` timeouts to "get more data" — the goal is to see the state at the exact wait the production CI run sees.

## Tasks

- [ ] Inspect the relevant `groceries_features`, `groceries-client`, and `groceries-service` code paths using the failures in `intent.md` as the starting point.
- [ ] Decide whether the existing failure output is enough to implement subspecs 01 and 02. If yes, record that conclusion in `evidence.md` and skip the user-run blocker.
- [ ] If more runtime evidence is needed, add the smallest targeted diagnostic hook/logging needed, add a new `## Blocker` with exact user-run instructions, and pause until the user records results in `evidence.md` and removes the blocker.
- [ ] After the user run, review `evidence.md`, artifact paths, and any pasted logs/screenshots. Decide whether the evidence supports or contradicts each cluster hypothesis.
- [ ] Inspect `groceries-client` `git log` since the failing-suite last passed for commits to `src/routes/lists/containers/ListsContainer.tsx`, `src/components/domain/ListCard.tsx`, `src/components/domain/ConfirmDialog.tsx`, and the merge endpoint handler. Note suspect commits in `evidence.md`.
- [ ] Remove any temporary diagnostic hook/logging before opening implementation PRs unless the diagnostics are intentionally part of a committed regression test.

## Acceptance criteria

- [ ] `evidence.md` exists and states whether `intent.md` alone was sufficient or whether a user-run diagnostic test was requested.
- [ ] If a user-run diagnostic test was requested, a concrete `## Blocker` was added with exact commands/artifact expectations, the user recorded results in `evidence.md`, and the agent reviewed those results after the blocker was removed.
- [ ] For Cluster A, `evidence.md` identifies whether `confirm-delete` / `confirm-reject` is missing from the DOM, hidden by CSS, mounted under an unexpected ancestor, or already clear enough from code inspection to proceed without another run.
- [ ] For Cluster B, `evidence.md` identifies whether the merged list page contains the expected item text in any form, and (if yes) which `data-test-class` wraps it, or explains why code/API inspection was sufficient without another run.
- [ ] Suspect commit list in `groceries-client` (and `groceries-service` if relevant) is recorded for use by subspecs 01 and 02.
- [ ] No diagnostic hooks are merged into `groceries_features` master; temporary diagnostics are removed or confined to throwaway local work.
