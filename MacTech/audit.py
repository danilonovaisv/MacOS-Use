"""Read-only collection of legacy apps; writes evidence only to this project."""
import hashlib
import json
import pathlib
import plistlib
import subprocess
from datetime import datetime

ROOT = pathlib.Path(__file__).resolve().parent
OUT = ROOT / 'Audit'
OUT.mkdir(exist_ok=True)
apps = [pathlib.Path.home() / 'Otimizador MacTech.app', pathlib.Path.home() / 'macos_maintenance.app']

def command(args):
    result = subprocess.run(args, capture_output=True, text=True, timeout=30)
    return dict(command=args, status=result.returncode, stdout=result.stdout, stderr=result.stderr)

inventory = []
for label, app in zip(['A', 'B'], apps):
    info = plistlib.loads((app / 'Contents/Info.plist').read_bytes())
    workflow = plistlib.loads((app / 'Contents/document.wflow').read_bytes())
    files = []
    for file in sorted(app.rglob('*')):
        if file.is_file():
            files.append(dict(path=str(file.relative_to(app)), size=file.stat().st_size,
                              sha256=hashlib.sha256(file.read_bytes()).hexdigest()))
    manifest = json.dumps(files, sort_keys=True, separators=(',', ':')).encode()
    actions = []
    for index, item in enumerate(workflow['actions']):
        action = item['action']
        params = action['ActionParameters']
        source = params.get('COMMAND_STRING') or params.get('source')
        entry = dict(index=index, name=action['ActionName'], parameters=params)
        if source:
            suffix = 'applescript' if 'AppleScript' in action['ActionName'] else 'sh'
            sourcefile = OUT / f'{label}-action-{index}.{suffix}'
            sourcefile.write_text(source)
            if suffix == 'sh':
                entry['syntax'] = command([params.get('shell', '/bin/bash'), '-n', str(sourcefile)])
        actions.append(entry)
    inventory.append(dict(label=label, path=str(app), info=info,
        modified=datetime.fromtimestamp(app.stat().st_mtime).isoformat(),
        manifest_sha256=hashlib.sha256(manifest).hexdigest(), files=files, actions=actions,
        signature=command(['/usr/bin/codesign', '-dv', '--verbose=4', str(app)]),
        validation=command(['/usr/bin/codesign', '--verify', '--deep', '--strict', str(app)]),
        entitlements=command(['/usr/bin/codesign', '-d', '--entitlements', ':-', str(app)]),
        dependencies=command(['/usr/bin/otool', '-L', str(app/'Contents/MacOS'/info['CFBundleExecutable'])])))
(OUT / 'inventory.json').write_text(json.dumps(inventory, indent=2, ensure_ascii=False))
btm = command(['/usr/bin/sfltool', 'dumpbtm'])
blocks = btm['stdout'].split('\n #')
(OUT / 'startup-before.txt').write_text('\n #'.join(b for b in blocks if any(s in b.lower() for s in ['mactech', 'macos-maintenance', 'macos_maintenance'])))
print(json.dumps([dict(label=i['label'], path=i['path'], hash=i['manifest_sha256'],
    syntax=[a.get('syntax', {}).get('status') for a in i['actions']]) for i in inventory], indent=2))
