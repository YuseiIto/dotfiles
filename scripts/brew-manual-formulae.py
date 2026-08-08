#!/usr/bin/env python3
"""Print Homebrew formulae explicitly installed on this host, one full name per line.

Used by audit-packages.sh in place of `brew leaves --installed-on-request`.
That command has to load every formula, and Homebrew refuses to load formulae
from untrusted third-party taps ("Refusing to load formula ... from untrusted
tap"), dropping them from its output without an error. Anything installed from
such a tap was therefore invisible to the audit and could never be reported as
drift.

Install receipts carry the same information without loading anything:
`installed_on_request` marks explicit installs, and `runtime_dependencies`
reproduces the "nothing depends on it" filter that makes a formula a leaf.

Known difference from `brew leaves`: a formula that only a *cask* depends on is
reported here, because cask receipts do not record their formula dependencies
locally. That over-reports rather than under-reports, which is the safe
direction for an audit -- resolve such an entry by declaring it or baselining it.
"""

import glob
import json
import os
import sys


def manual_formulae(cellar):
    on_request = {}
    depended = set()

    for receipt in glob.glob(os.path.join(cellar, "*", "*", "INSTALL_RECEIPT.json")):
        keg = os.path.dirname(os.path.dirname(receipt))
        # Homebrew leaves a symlink at the old name when a formula is renamed
        # (e.g. huggingface-cli -> hf); following it counts one keg twice.
        if os.path.islink(keg):
            continue

        try:
            with open(receipt) as handle:
                data = json.load(handle)
        except (OSError, ValueError):
            continue

        name = os.path.basename(keg)
        tap = (data.get("source") or {}).get("tap") or "homebrew/core"
        full_name = name if tap == "homebrew/core" else f"{tap}/{name}"

        # A keg may have several versions installed; treat the formula as
        # explicitly installed if any of them was.
        on_request[full_name] = on_request.get(full_name, False) or bool(
            data.get("installed_on_request")
        )

        for dep in data.get("runtime_dependencies") or []:
            if dep.get("full_name"):
                depended.add(dep["full_name"])

    return sorted(
        name for name, requested in on_request.items() if requested and name not in depended
    )


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <homebrew-cellar-path>", file=sys.stderr)
        return 2
    for name in manual_formulae(sys.argv[1]):
        print(name)
    return 0


if __name__ == "__main__":
    sys.exit(main())
