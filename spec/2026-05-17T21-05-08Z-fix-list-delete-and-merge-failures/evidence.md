# Evidence - fix list delete and merge failures

Use this file for the evidence that unblocks subspecs 01, 02, and final verification in 03. Start with the failures already captured in `intent.md`; only add new runtime test results if the agent requested a targeted user-run diagnostic pass from `00-reproduce-and-capture-dom.md` or a post-fix verification pass from `03-harden-feature-specs.md`.

## Baseline

- Source: `intent.md`
- Failure set: 9 examples in `spec/features/lists/lists_spec.rb`
- Shared failure mode: `Helpers::WaitHelper#wait_for` throws `"full wait time lapsed"`

## User-run Diagnostics

Record any requested run here.

```text
Date:
Repos and branches:
Command(s):
Temporary diagnostics enabled:
Artifact paths:
Result summary:
```

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
