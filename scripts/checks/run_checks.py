#!/usr/bin/env python3
"""Strict import/test process wrapper (Python 3.12 standard library only)."""
from __future__ import annotations
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

PROJECT = Path(__file__).resolve().parents[2]
SUITES = ("state", "physics", "recovery")
DIAGNOSTIC = re.compile(r"(?:SCRIPT ERROR:|(?:^|\n)ERROR:|Parse Error:|Failed to load|Error importing|OMDB watchdog timeout)")
TIMEOUT_SECONDS = 60


def run_process(command: list[str], timeout: float = TIMEOUT_SECONDS) -> tuple[int, str]:
    try:
        with tempfile.TemporaryDirectory(prefix="omdb-engine-") as engine_home:
            environment = os.environ.copy()
            for name, leaf in (("XDG_DATA_HOME", "data"), ("XDG_CACHE_HOME", "cache"), ("XDG_CONFIG_HOME", "config")):
                target = Path(engine_home) / leaf
                target.mkdir()
                environment[name] = str(target)
            result = subprocess.run(command, cwd=PROJECT, env=environment, capture_output=True, text=True, timeout=timeout)
        output = result.stdout + result.stderr
        sys.stdout.write(output)
        return (1 if result.returncode or DIAGNOSTIC.search(output) else 0), output
    except subprocess.TimeoutExpired:
        print(f"CHECK FAILED: process timeout after {timeout}s", file=sys.stderr)
        return 1, ""
    except OSError as exc:
        print(f"CHECK FAILED: {exc}", file=sys.stderr)
        return 1, ""


def validate_summary(output: str, requested: str) -> bool:
    lines = [line.removeprefix("OMDB_TEST_RESULT ") for line in output.splitlines() if line.startswith("OMDB_TEST_RESULT ")]
    if len(lines) != 1:
        return False
    try:
        summary = json.loads(lines[0])
        suites = SUITES if requested == "all" else (requested,)
        counts = summary["suites"]
        passed, failed = summary["passed"], summary["failed"]
        if type(passed) is not int or type(failed) is not int or failed != 0 or passed <= 0:
            return False
        if set(counts) != set(suites) or any(type(counts[s]) is not int or counts[s] <= 0 for s in suites):
            return False
        cases = [line.split() for line in output.splitlines() if line.startswith("OMDB_CASE ")]
        if len(cases) != passed or sum(counts.values()) != passed:
            return False
        return all(len(c) == 4 and c[1] in suites and c[3] == "PASS" for c in cases) and all(
            sum(c[1] == suite for c in cases) == counts[suite] for suite in suites
        )
    except (KeyError, TypeError, ValueError):
        return False


def safe_root(value: str) -> str:
    path = Path(value)
    temp = Path(tempfile.gettempdir()).resolve()
    if not path.is_absolute() or path.resolve() == temp or temp not in path.resolve().parents:
        raise argparse.ArgumentTypeError("save root must be a child of the OS temporary directory")
    for ancestor in (path, *path.parents):
        if ancestor.is_symlink():
            raise argparse.ArgumentTypeError("save root cannot contain symlink ancestors")
    return str(path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    parser.add_argument("--suite", choices=(*SUITES, "all"), default="all")
    parser.add_argument("--save-root", type=safe_root, required=True)
    args = parser.parse_args()
    command = [args.godot, "--headless", "--path", str(PROJECT)]
    status, _ = run_process(command + ["--editor", "--import"])
    if status:
        return 1
    status, _ = run_process(command + ["--script", "res://scripts/checks/import_check.gd"])
    if status:
        return 1
    status, output = run_process(command + ["--fixed-fps", "60", "--script", "res://tests/run_tests.gd", "--", "--suite", args.suite, "--save-root", args.save_root])
    if status or not validate_summary(output, args.suite):
        print("CHECK FAILED: engine failure or missing/invalid/nonempty passing summary", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
