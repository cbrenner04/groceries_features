# Evidence - fix list delete and merge failures

Use this file for the evidence that unblocks subspecs 01, 02, and final verification in 03. Start with the failures already captured in `intent.md`; only add new runtime test results if the agent requested a targeted user-run diagnostic pass from `00-reproduce-and-capture-dom.md` or a post-fix verification pass from `03-harden-feature-specs.md`.

## Baseline

- Source: `intent.md`
- Failure set: 9 examples in `spec/features/lists/lists_spec.rb`
- Shared failure mode: `Helpers::WaitHelper#wait_for` throws `"full wait time lapsed"`

## User-run Diagnostics

A targeted diagnostic run has been requested to capture DOM state at failure points (see `## Blocker` section at end of this file). Record the run details below once you have executed it.

```text
Date: [run this after removing the blocker]
Repos and branches:
Command(s):
Temporary diagnostics enabled: CAPTURE_WAIT_DIAGNOSTICS=1
Artifact paths:
Result summary:
```

## Code inspection findings

### Suspect commits in groceries-client (from git log):
- `e05ac67` UI Redesign Phase 4 (#702) - most recent lists redesign
- `0a519c0` Phase 3B carryover: remove react-bootstrap from list routes (#687)
- `e881657` Phase 3A: Redesign lists page with unified view, filter chips, and BottomInputBar (#674)
- `7b32a26` Fix pending and merge workflows

### Cluster A Hypothesis
The `ConfirmDialog` component still exists and generates correct `data-test-id="confirm-delete"` / `"confirm-reject"` elements, but the state flip (`showDeleteConfirm`/`showRejectConfirm`) is not triggered when the trash/reject icon is clicked. Likely regression in the redesigned `ListCard.tsx` / `ListsContainer.tsx` delete/reject event handlers, possibly due to interaction between the card's inner button `stopPropagation()` and outer `handleClick` dispatcher.

### Cluster B Hypothesis
The merge endpoint either (a) does not return items in the merged list, or (b) items are rendered under different `data-test-class` than expected (e.g., grouped by category in unified view rather than flat list). The first merge-related assertion passes (list appears in home_page), but the subsequent item iteration fails at `Pages::List#find_list_item`.

## Blocker

A targeted user-run diagnostic test is needed to capture the actual DOM state at each failure point.

**Repos and branches required:**
- `groceries-client` master (or HEAD as of 2026-05-17)
- `groceries-service` master (or HEAD as of 2026-05-17)
- `groceries_features` branch: `fix-list-delete-and-merge-failures` (current)

**Setup:**
1. Ensure both client and service are running locally (see their README files)
2. The spec suite will authenticate against the running app

**Commands to run:**
```bash
# From the groceries_features repo root
# Run one representative test from each cluster with diagnostic capture enabled
CAPTURE_WAIT_DIAGNOSTICS=1 rspec --no-retry \
  ./spec/features/lists/lists_spec.rb[1:1:2:6] \
  ./spec/features/lists/lists_spec.rb[1:1:4:2:7]
```

This runs:
- Test [1:1:2:6]: "A list behaves like a list that is incomplete is deleted" (Cluster A - delete confirm)
- Test [1:1:4:2:7]: "A list behaves like a list multiSelect merge successfully merges lists of same type with proper name" (Cluster B - merge result items)

**Expected artifact locations:**
The tests will create diagnostic captures in `spec/diagnostics/`:
- `wait_failure_TIMESTAMP.html` — full DOM at failure point
- `wait_failure_TIMESTAMP.png` — screenshot at failure point  
- `wait_failure_TIMESTAMP.txt` — note with exception details

**After the run, review the diagnostics:**

For **Cluster A** failure: open the HTML dump and search for `confirm-delete`. Note whether:
- [ ] Element is completely absent from DOM
- [ ] Element is present but has `display: none` or similar CSS hiding
- [ ] Element exists but mounted under an unexpected parent (e.g., body or portal div instead of home page card)

For **Cluster B** failure: open the HTML dump and search for the expected item text (from the test, e.g., item names like "Buy milk", etc.). Note whether:
- [ ] Item text is completely absent
- [ ] Item text is present but wrapped in a different `data-test-class` (e.g., `category-group` or `filter-result`)
- [ ] Item text is present under expected `data-test-class="non-completed-item"`

Then record the findings below in the **Cluster A/B Conclusion** sections and remove this blocker.

---

## Cluster A Conclusion

Record whether `confirm-delete` / `confirm-reject` is missing, hidden, mounted somewhere unexpected, or sufficiently explained by code inspection.

## Cluster B Conclusion

Record whether the merged list page contains the expected item text, what `data-test-class` wraps it if present, and whether the merge endpoint returned the expected items.

## Agent Review

The agent must fill this in after reviewing any user-run diagnostics.

```text
Reviewed by:
Evidence sufficient for 01:
Evidence sufficient for 02:
Follow-up actions:
Suspect commits:
```
