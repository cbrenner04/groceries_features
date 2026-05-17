# 03 - Harden feature specs after client fixes land

Once the client (and any service) fixes from subspecs 01 and 02 are merged, replace the brittle `sleep 1` workarounds in `spec/support/shared_examples/lists.rb` with proper waits, and verify the suite is green without retries. This is the only subspec that touches code in this (`groceries_features`) repo.

**Do not start this subspec until 01 and 02 are merged.** Running it before then either weakens specs to make a real regression pass, or masks the regression with longer waits — both are explicitly out of scope.

## Scope

- Edit `spec/support/shared_examples/lists.rb` only where existing `sleep` (or equivalent unconditional waits) are workarounds for confirm-dialog timing. Candidate sites called out in turn-1: lines 149 and 197. Line numbers are point-in-time — re-grep the file and confirm each sleep is actually a timing workaround (vs. e.g. waiting on an async backend job) before replacing it.
- Replace each sleep with a `wait_for` (or Capybara's built-in waiting matchers) that observes a stable, deterministic property of the just-mounted dialog. Do not use `wait_for { ... rescue false }` patterns that swallow errors.
- Do not extend `Helpers::WaitHelper`'s `original_wait_time` budget.
- Do not delete or skip any of the 9 originally failing examples.

## Decisions

- Prefer waiting on the dialog's confirm button being not just present but interactable (e.g. enabled, visible) before clicking it, since the failure mode under investigation was specifically a dialog that mounted and was then interacted with too quickly.
- If a hardened wait is helpful in more than one shared example block, extract a small helper on `Pages::Home` rather than duplicating the wait inline.

## Tasks

- [ ] Run the full failing-suite locally against the patched `groceries-client` + `groceries-service` to confirm subspecs 01 and 02 actually fix the 9 failures.
- [ ] Identify every `sleep` and unconditional `wait` in `spec/support/shared_examples/lists.rb`. For each, decide whether it is a confirm-dialog timing workaround (in scope) or guarding something else (leave alone, but note why in the PR).
- [ ] Replace each with a deterministic `wait_for` / Capybara waiting matcher on a stable post-mount property.
- [ ] If a new `Pages::Home` helper is warranted, add it under `spec/support/pages/home.rb` with a clear name (e.g. `wait_until_confirm_delete_button_clickable`).
- [ ] Run the failing examples 5 times back-to-back locally and confirm 0 failures and 0 retries.

## Acceptance criteria

- [ ] All 9 originally failing examples pass locally for 5 consecutive runs against the patched stack, with `rspec-retry` set to 1 retry max (i.e. no retries actually consumed).
- [ ] No `sleep` calls remain in `spec/support/shared_examples/lists.rb` for the confirm-dialog code paths exercised by the 9 examples. Any remaining `sleep` is documented in the PR with its justification.
- [ ] `Helpers::WaitHelper` timeouts are unchanged.
- [ ] No example was deleted, skipped, or marked pending.
- [ ] No spec selector was changed unless subspec 01 or 02 documented a deliberate, lockstep rename in `groceries-client`.
