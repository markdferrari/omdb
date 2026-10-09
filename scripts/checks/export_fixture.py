#!/usr/bin/env python3
"""Export the authored game or representative fixture, restoring temporary configuration."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import zipfile

PROJECT = Path(__file__).resolve().parents[2]
ERROR = re.compile(r'(?:SCRIPT ERROR:|(?:^|\n)ERROR:|Parse Error:|Failed to load|Error importing)')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--template-dir',type=Path,required=True)
    parser.add_argument('--godot',default='godot')
    parser.add_argument('--production', action='store_true', help='Export the connected six-room main scene instead of the fixture')
    args=parser.parse_args()
    if (args.template_dir/'version.txt').read_text().strip() != '4.7.2.stable':
        raise RuntimeError('Matching 4.7.2.stable templates are required')
    version=subprocess.check_output([args.godot,'--version'],text=True).strip()
    if version != '4.7.2.stable.official.ed1daf0bf':
        raise RuntimeError('Unexpected engine '+version)
    project=PROJECT/'project.godot'
    original=project.read_text()
    pattern=r'(?m)^run/main_scene=.*$'
    saved_line=re.search(pattern,original).group()
    fixture_line='run/main_scene="res://tests/scenes/flow_validation.tscn"'
    presets=PROJECT/'export_presets.cfg'
    original_presets=presets.read_text()
    records=[]
    with tempfile.TemporaryDirectory(prefix='omdb-export-engine-') as temporary:
        environment=os.environ.copy()
        for name,leaf in [('XDG_DATA_HOME','data'),('XDG_CACHE_HOME','cache'),('XDG_CONFIG_HOME','config')]:
            environment[name]=str(Path(temporary)/leaf)
            Path(environment[name]).mkdir()
        destination=Path(environment['XDG_DATA_HOME'])/'godot/export_templates/4.7.2.stable'
        shutil.copytree(args.template_dir,destination)
        try:
            if not args.production:
                project.write_text(re.sub(pattern,fixture_line,original))
                presets.write_text(re.sub(r'(?m)^exclude_filter=.*$', 'exclude_filter="art/*,tests/state/*,tests/physics/*,tests/recovery/*,tests/run_tests.gd,scripts/checks/import_check.gd,scripts/checks/package_probe.gd"', original_presets))
            else:
                if saved_line != 'run/main_scene="res://scenes/main.tscn"':
                    raise RuntimeError('Production exports require the authored main scene')
                presets.write_text(re.sub(r'(?m)^exclude_filter=.*$', 'exclude_filter="art/*,tests/*,scripts/checks/*"', original_presets))
            for preset,path in [('Windows Desktop','builds/windows/over-my-dead-body.exe'),('macOS','builds/macos/over-my-dead-body.zip')]:
                output=PROJECT/path
                output.parent.mkdir(parents=True,exist_ok=True)
                result=subprocess.run([args.godot,'--headless','--path',str(PROJECT),'--export-release',preset,str(output)],env=environment,cwd=PROJECT,capture_output=True,text=True,timeout=180)
                log=result.stdout+result.stderr
                (output.parent/'export.log').write_text(log)
                if result.returncode or ERROR.search(log) or not output.is_file():
                    print(log)
                    raise RuntimeError('Export failed for '+preset)
                records.append({'preset':preset,'file':path,'bytes':output.stat().st_size,'sha256':hashlib.sha256(output.read_bytes()).hexdigest(),'native_launch':'UNVERIFIED'})
                print('Exported',path,output.stat().st_size,flush=True)
        finally:
            # Retain unrelated edits that may have happened during export.
            current=project.read_text()
            if fixture_line in current:
                project.write_text(current.replace(fixture_line,saved_line,1))
            presets.write_text(original_presets)
    exe=PROJECT/'builds/windows/over-my-dead-body.exe'
    data=exe.read_bytes()
    offset=int.from_bytes(data[60:64],'little')
    if data[:2] != b'MZ' or data[offset:offset+4] != b'PE\0\0' or int.from_bytes(data[offset+4:offset+6],'little') != 0x8664:
        raise RuntimeError('Windows package is not x86_64 PE')
    pck=exe.with_suffix('.pck')
    if not pck.is_file() or pck.read_bytes()[:4] != b'GDPC':
        raise RuntimeError('Required Windows PCK missing/invalid')
    records[0]['pck']={'file':str(pck.relative_to(PROJECT)), 'bytes':pck.stat().st_size, 'sha256':hashlib.sha256(pck.read_bytes()).hexdigest()}
    with zipfile.ZipFile(PROJECT/'builds/macos/over-my-dead-body.zip') as package:
        binaries=[n for n in package.namelist() if '/Contents/MacOS/' in n and not n.endswith('/')]
        if len(binaries) != 1:
            raise RuntimeError('macOS application binary missing')
        binary=package.read(binaries[0])
        if binary[:4] != b'\xca\xfe\xba\xbe':
            raise RuntimeError('macOS binary is not Universal 2')
        count=int.from_bytes(binary[4:8],'big')
        types={int.from_bytes(binary[8+i*20:12+i*20],'big') for i in range(count)}
        if not {0x1000007,0x100000c}.issubset(types):
            raise RuntimeError('macOS x86_64/arm64 architecture missing')
    if args.production:
        windows_zip=PROJECT/'builds/windows/over-my-dead-body.zip'
        with zipfile.ZipFile(windows_zip, 'w', compression=zipfile.ZIP_DEFLATED) as package:
            for member in (exe, pck):
                package.write(member, member.name)
        records.append({'preset':'Windows distribution', 'file':str(windows_zip.relative_to(PROJECT)), 'bytes':windows_zip.stat().st_size, 'sha256':hashlib.sha256(windows_zip.read_bytes()).hexdigest(), 'native_launch':'UNVERIFIED'})
    scene='res://scenes/main.tscn' if args.production else 'res://tests/scenes/flow_validation.tscn'
    manifest='game-manifest.json' if args.production else 'fixture-manifest.json'
    (PROJECT/'builds'/manifest).write_text(json.dumps({'engine':version,'scene':scene,'save_root':'optional temporary override' if args.production else 'required absolute temporary directory','exports':records},indent=2)+'\n')
    return 0

if __name__=='__main__':
    raise SystemExit(main())
