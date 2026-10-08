#!/usr/bin/env python3
"""T011: inject faults only into temporary project copies; never the working game."""
from pathlib import Path
import json
import os
import re
import shutil
import subprocess
import tempfile

PROJECT = Path(__file__).resolve().parents[2]
FAULTS = {
    "empty_suite": ('tests/run_tests.gd', '"state": ["res://tests/state/test_foundation.gd"]', '"state": []'),
    "missing_case": ('tests/run_tests.gd', 'res://tests/state/test_foundation.gd', 'res://tests/state/missing.gd'),
    "assertion_failure": ('tests/state/test_foundation.gd', 'state.phase == RoomState.Phase.INITIALIZING', 'false'),
    "no_assertions": ('tests/state/test_foundation.gd', None, 'extends RefCounted\nfunc run(_h):\n\tpass\n'),
    "parse_error": ('scripts/state/room_state.gd', None, 'extends RefCounted\nfunc broken(\n'),
    "runtime_error": ('tests/state/test_foundation.gd', None, 'extends RefCounted\nfunc run(_h):\n\tvar nothing = null\n\tnothing.invalid_method()\n'),
    "missing_summary": ('tests/run_tests.gd', 'print("OMDB_TEST_RESULT ",', 'print("REMOVED_SUMMARY ",'),
    "watchdog": ('tests/state/test_foundation.gd', None, 'extends RefCounted\nfunc run(h):\n\tawait h.frames(100000)\n'),
    "missing_fixture": ('tests/physics/test_foundation.gd', 'res://tests/scenes/physics_fixture.tscn', 'res://tests/scenes/missing.tscn'),
}


def main():
    records = []
    with tempfile.TemporaryDirectory(prefix='omdb-harness-') as location:
        base = Path(location)
        for name, (relative, old, new) in FAULTS.items():
            target = base / name
            shutil.copytree(PROJECT, target, ignore=shutil.ignore_patterns('.git', '.godot', 'art', '.agents', '.codex', '.aws', '.specify', 'specs', '__pycache__'))
            path = target / relative
            if name == 'empty_suite':
                path.write_text(re.sub(r'"state": \[[^\n]*\]', '"state": []', path.read_text()))
                shutil.rmtree(target / 'tests/state')
                (target / 'tests/state').mkdir()
            else:
                path.write_text(new if old is None else path.read_text().replace(old, new))
            if name == 'watchdog':
                runner = target / 'tests/run_tests.gd'
                runner.write_text(runner.read_text().replace('Time.get_ticks_msec() + 45000', 'Time.get_ticks_msec() + 100'))
            suite = 'physics' if name == 'missing_fixture' else 'state'
            command = ['python3', str(target / 'scripts/checks/run_checks.py'), '--suite', suite, '--save-root', str(base / 'saves' / name)]
            result = subprocess.run(command, capture_output=True, text=True, timeout=90)
            output = result.stdout + result.stderr
            (base / f'{name}.log').write_text(output)
            # Each failure must have an observable reason and a nonzero wrapper status.
            records.append({'fault': name, 'exit_code': result.returncode, 'rejected': result.returncode != 0, 'diagnostic': output.splitlines()[-1] if output else 'NO OUTPUT'})
        # Runner must itself reject invalid suite names and the production save path.
        environment = os.environ.copy()
        for key, leaf in [('XDG_DATA_HOME', 'data'), ('XDG_CACHE_HOME', 'cache'), ('XDG_CONFIG_HOME', 'config')]:
            environment[key] = str(base / leaf)
        for name, suite, root in [('unknown_suite', 'missing', str(base / 'saves')), ('unsafe_save_root', 'state', 'user://')]:
            command = ['godot', '--headless', '--path', str(PROJECT), '--script', 'res://tests/run_tests.gd', '--', '--suite', suite, '--save-root', root]
            result = subprocess.run(command, env=environment, capture_output=True, text=True, timeout=60)
            records.append({'fault': name, 'exit_code': result.returncode, 'rejected': result.returncode != 0})
        # A caller timeout must fail even if an executable emits no errors.
        from run_checks import run_process
        status, _ = run_process(['python3', '-c', 'import time; time.sleep(5)'], timeout=0.1)
        records.append({'fault': 'process_timeout', 'exit_code': status, 'rejected': status != 0})
    print(json.dumps(records, indent=2))
    return 0 if all(row['rejected'] for row in records) else 1

if __name__ == '__main__':
    raise SystemExit(main())
