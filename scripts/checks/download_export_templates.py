#!/usr/bin/env python3
"""Fetch only the pinned desktop members of the official standard template archive."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import re
import urllib.request
import zipfile

URL = 'https://godot-releases.nbg1.your-objectstorage.com/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz'
MEMBERS = ['version.txt', 'windows_release_x86_64.exe', 'windows_release_x86_64_console.exe', 'macos.zip']

class RemoteArchive:
    def __init__(self):
        request = urllib.request.Request(URL, headers={'Range': 'bytes=-65536'})
        with urllib.request.urlopen(request, timeout=180) as response:
            if response.status != 206:
                raise RuntimeError('Official archive does not support range downloads')
            match = re.fullmatch(r'bytes (\d+)-(\d+)/(\d+)', response.headers['Content-Range'])
            self.tail_start, _, self.size = map(int, match.groups())
            self.tail = response.read()
        self.position = 0
    def seek(self, offset, whence=io.SEEK_SET):
        self.position = offset if whence == io.SEEK_SET else self.position + offset if whence == io.SEEK_CUR else self.size + offset
        return self.position
    def tell(self):
        return self.position
    def seekable(self):
        return True
    def read(self, size=-1):
        size = self.size-self.position if size < 0 else min(size, self.size-self.position)
        if size <= 0:
            return b''
        start = self.position
        if start >= self.tail_start:
            data = self.tail[start-self.tail_start:start-self.tail_start+size]
        else:
            request = urllib.request.Request(URL, headers={'Range': f'bytes={start}-{start+size-1}'})
            with urllib.request.urlopen(request, timeout=180) as response:
                if response.status != 206 or response.headers['Content-Range'] != f'bytes {start}-{start+size-1}/{self.size}':
                    raise RuntimeError('Unexpected archive range response')
                data = response.read()
        if len(data) != size:
            raise RuntimeError('Incomplete template download')
        self.position += size
        return data

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args=parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    records={}
    with zipfile.ZipFile(RemoteArchive()) as archive:
        version=archive.read('templates/version.txt').decode().strip()
        if version != '4.7.2.stable':
            raise RuntimeError('Template version mismatch: '+version)
        for leaf in MEMBERS:
            payload=archive.read('templates/'+leaf)  # ZipFile checks member CRC.
            destination=args.output/leaf
            destination.write_bytes(payload)
            records[leaf]={'bytes':len(payload),'sha256':hashlib.sha256(payload).hexdigest()}
            print('Downloaded',leaf,len(payload),flush=True)
    (args.output/'SOURCE.json').write_text(json.dumps({'url':URL,'version':version,'members':records},indent=2)+'\n')

if __name__=='__main__':
    main()
