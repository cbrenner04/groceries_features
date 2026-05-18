# 01 - Fix Cluster A: restore single-row delete/reject confirm dialog (groceries-client)

Seven of the nine failures (#1, #2 reject, #3, #4, #5, #6, #7) wait for `data-test-id="confirm-delete"` or `confirm-reject` to appear after clicking the trash/reject icon on a list row, and time out. The selector contract is intact in the client as of intent capture: `src/components/domain/ConfirmDialog.tsx` still emits `data-test-id={\`confirm-${title}\`}`, and `src/routes/lists/containers/ListsContainer.tsx` still mounts the dialog with `title="delete"` and `title="reject"`. Line numbers in the intent are point-in-time and may drift — re-grep on the current `groceries-client` HEAD before editing. The bug is that single-row trash/reject clicks no longer flip the dialog state to `true`.

**This subspec is delivered as a PR against `groceries-client`, not this repo.** This file documents the change so it can be tracked and verified from the spec.

## Likely root cause

`src/components/domain/ListCard.tsx` wraps the entire card in `onClick={handleClick}` / `role="button"` / `tabIndex=0`. `handleClick` does a `closest('button')` lookup and dispatches by `dataset.testId`. The inner trash `IconButton` uses `onClick={(e) => { e.stopPropagation(); onDelete(listId); }}`. Either:

1. The Card's outer `handleClick` and the inner button handler interact in a way that swallows or misroutes the click, **or**
2. `onDelete` / `onReject` in `ListsContainer.tsx` no longer calls `setShowDeleteConfirm(true)` / `setShowRejectConfirm(true)` for the single-row path — perhaps because the lists-page redesign (`e881657`, `0a519c0`, `e05ac67`) routed single-row deletion through the bulk multi-select flow and the single-row branch was dropped, **or**
3. Pending list rejection follows a similar regression on a different handler.

The fix should restore the single-row path: clicking the row's trash button must end with `showDeleteConfirm === true` and the target list captured in the container's selection state; clicking the row's reject button must end with `showRejectConfirm === true`.

## Scope

- Touch only what is needed to restore the single-row open-confirm flow. Do not redesign the lists page, do not rename test ids, do not change `ConfirmDialog`.
- Apply the same fix shape to both delete and reject, since they share the row-click dispatch pattern.
- Preserve the bulk multi-select delete flow — it should still open the same `ConfirmDialog` for `>= 1` selected list.

## Decisions

- If the regression is in `ListCard.tsx`'s outer `handleClick`, prefer making the inner trash/reject `IconButton` the source of truth and removing or narrowing the outer handler's responsibility for those buttons rather than removing `stopPropagation` from the inner handler.
- Do not introduce a new test id; reuse `confirm-delete` / `confirm-reject` since the spec contract depends on them.
- Confirm-button test ids consumed by `Pages::Home` (`confirm-delete-button`, `confirm-reject-button`) must continue to exist on the dialog's confirm action.

## Tasks

- [ ] Review `evidence.md` from subspec 00. If it contains user-run diagnostics, explicitly account for them before editing; if it says `intent.md` plus code inspection was sufficient, proceed from that recorded conclusion.
- [ ] Fix `ListsContainer.tsx` and/or `ListCard.tsx` so that a single trash click on an incomplete, complete, or shared (write/read) list row opens the delete confirm dialog with that list as the target.
- [ ] Fix the equivalent path so that a single reject click on a pending shared list opens the reject confirm dialog with that list as the target.
- [ ] Add a `groceries-client` unit/component test asserting: after clicking the row trash button, `data-test-id="confirm-delete"` is present in the DOM. Add the equivalent test for `confirm-reject`.
- [ ] Verify the bulk multi-select delete flow still works (manual smoke or existing tests).
- [ ] Before claiming feature-suite verification, add a `## Blocker` asking the user to run the 7 Cluster A examples against the patched `groceries-client`, record the commands/output in `evidence.md`, and remove the blocker.
- [ ] After the user removes the blocker, review the recorded Cluster A output and account for any failures, retries, or changed symptoms.
- [ ] Open a PR against `groceries-client` referencing this subspec.

## Acceptance criteria

- [x] Agent review in `evidence.md` says Cluster A evidence is sufficient and identifies which hypothesis was pursued.
- [ ] Fix applied in `groceries-client/src/components/domain/ListCard.tsx`: removed `handleActionClickCapture` function and `onClickCapture={handleActionClickCapture}` from wrapper div to restore single-row delete/reject click handling.
- [ ] User-recorded verification in `evidence.md` shows all 7 Cluster A failures (`lists_spec.rb[1:1:2:6]`, `[1:1:2:7:1:3]`, `[1:1:2:7:2:1:2]`, `[1:1:2:7:2:2:2]`, `[1:1:3:3]`, `[1:1:3:4:1:2]`, `[1:1:3:4:2:2]`) pass against the patched `groceries-client` without retries, and the agent review confirms the output is sufficient.
- [ ] No test selector in `groceries_features` was changed to make these pass.
- [ ] `Helpers::WaitHelper#wait_for` timeouts were not extended.
- [ ] A new `groceries-client` component test asserts that clicking a list row's trash button mounts `data-test-id="confirm-delete"`, and the parallel test exists for `confirm-reject`.
- [ ] Bulk multi-select delete still opens the same `ConfirmDialog` and completes successfully.
- [ ] PR description links this subspec and lists the suspect commits identified in subspec 00 that introduced the regression.

## Blocker

Agent cannot write to `groceries-client` repo due to sandbox restrictions (only allowed in `groceries_features`). The root cause and fix are identified in `evidence.md`:

**Fix required in `groceries-client/src/components/domain/ListCard.tsx`:**
1. Remove the `handleActionClickCapture` function (lines ~81-110)
2. Remove `onClickCapture={handleActionClickCapture}` from the action buttons wrapper div (line ~224)

This restores the working state where single-row trash/reject clicks invoke their direct `onClick` handlers without capture-phase event interception.

**Next steps:**
1. Apply the fix in groceries-client
2. Add a unit/component test that asserts `data-test-id="confirm-delete"` appears after clicking the trash button (and parallel for `confirm-reject`)
3. Create a PR against groceries-client
4. Verify the 7 Cluster A tests pass against the patched client
5. Record the user-run verification in `evidence.md` and remove this blocker
