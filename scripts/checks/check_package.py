#!/usr/bin/env python3
"""Exercise exported desktop PCKs on Linux; this is not native OS acceptance."""
from pathlib import Path
import tempfile
import zipfile
from run_checks import PROJECT, run_process

def main():
    with tempfile.TemporaryDirectory(prefix='omdb-package-smoke-') as directory:
        temporary=Path(directory)
        empty=temporary/'no-source-project'
        empty.mkdir()
        mac_pck=temporary/'macos.pck'
        with zipfile.ZipFile(PROJECT/'builds/macos/over-my-dead-body.zip') as package:
            members=[n for n in package.namelist() if n.endswith('.pck')]
            if len(members) != 1:
                raise RuntimeError('Missing macOS PCK')
            mac_pck.write_bytes(package.read(members[0]))
        for name,pck in [('windows',PROJECT/'builds/windows/over-my-dead-body.pck'),('macos',mac_pck)]:
            status,output=run_process(['godot','--headless','--path',str(empty),'--main-pack',str(pck),'--fixed-fps','60','--script',str(PROJECT/'scripts/checks/package_probe.gd'),'--','--save-root',str(temporary/name)])
            if status or 'OMDB_PACKAGE_RESULT PASS' not in output:
                return 1
            print('PACKAGE_SMOKE',name,'PASS; native launch UNVERIFIED')
    return 0

if __name__=='__main__':
    raise SystemExit(main())
