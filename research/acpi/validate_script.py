#!/usr/bin/env python3
# Syntax-only validation of setup_gu605my.sh

path = r'C:\Users\kings\Desktop\Optimization\setup_gu605my.sh'
with open(path, 'r') as f:
    content = f.read()

lines = content.split('\n')
issues = []

# Check for unclosed heredocs
heredoc_keywords = []
for i, line in enumerate(lines, 1):
    stripped = line.strip()
    if '<<' in stripped and not stripped.startswith('#'):
        marker = stripped.split('<<')[-1].strip().strip("'")
        heredoc_keywords.append((i, marker))

for start_line, marker in heredoc_keywords:
    found = False
    for j in range(start_line, len(lines)):
        if lines[j].strip() == marker:
            found = True
            break
    if not found:
        issues.append(f'Heredoc marker "{marker}" starting at line {start_line} not closed')

if issues:
    print('Potential issues:')
    for issue in issues:
        print(f'  - {issue}')
else:
    print('No obvious syntax issues detected (heredocs are balanced).')

print(f'Total lines: {len(lines)}')
print('Script type: CachyOS/Arch Linux bash installer')
