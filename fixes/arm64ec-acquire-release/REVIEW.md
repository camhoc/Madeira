# Review: arm64ec-acquire-release-1

Review: pending (laptop compile check + second review, via the build thread).

Checklist for the reviewer:
- Confirm clang (llvm-mingw 20260421) defines `__x86_64__` for the arm64ec target, so today's x86 branch is taken. If it does not, this patch changes nothing and can be dropped.
- Confirm the `#else` branch (`__atomic_load`/`__atomic_store`) compiles for arm64ec.
- No run-time off switch: header macros. Acceptable because the new code is the standard compiler atomic with the ordering the API name promises; risk is only a small speed cost.
- License: LGPL-2.1-or-later (Wine). Credit line in README.md.
