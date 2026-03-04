#!/usr/bin/env python3
"""Add breadcrumbs navigation to all product HTML files for SEO."""

import os
import re

# Product to category mapping
PRODUCT_CATEGORIES = {
    # Calculators (18)
    "ltv-calculator.html": ("Calculators", "LTV Calculator"),
    "cac-calculator.html": ("Calculators", "CAC Calculator"),
    "churn-calculator.html": ("Calculators", "Churn Calculator"),
    "burn-rate-calculator.html": ("Calculators", "Burn Rate Calculator"),
    "arpu-calculator.html": ("Calculators", "ARPU Calculator"),
    "mrr-growth-calculator.html": ("Calculators", "MRR Growth Calculator"),
    "nrr-calculator.html": ("Calculators", "NRR Calculator"),
    "rule-of-40-calculator.html": ("Calculators", "Rule of 40 Calculator"),
    "runway-calculator.html": ("Calculators", "Runway Calculator"),
    "saas-valuation-calculator.html": ("Calculators", "SaaS Valuation Calculator"),
    "break-even-calculator.html": ("Calculators", "Break-Even Calculator"),
    "cohort-analysis.html": ("Calculators", "Cohort Analysis"),
    "equity-calculator.html": ("Calculators", "Equity Calculator"),
    "viral-coefficient-calculator.html": ("Calculators", "Viral Coefficient Calculator"),
    "gross-margin-calculator.html": ("Calculators", "Gross Margin Calculator"),
    "quick-ratio-calculator.html": ("Calculators", "Quick Ratio Calculator"),
    "saas-pricing-calculator.html": ("Calculators", "SaaS Pricing Calculator"),
    "saas-scorecard.html": ("Calculators", "SaaS Scorecard"),
    # Utility Tools (9)
    "json-formatter.html": ("Utilities", "JSON Formatter"),
    "regex-tester.html": ("Utilities", "Regex Tester"),
    "markdown-editor.html": ("Utilities", "Markdown Editor"),
    "base64-encoder.html": ("Utilities", "Base64 Encoder"),
    "url-encoder.html": ("Utilities", "URL Encoder"),
    "diff-checker.html": ("Utilities", "Diff Checker"),
    "uuid-generator.html": ("Utilities", "UUID Generator"),
    "timestamp-converter.html": ("Utilities", "Timestamp Converter"),
    "hash-generator.html": ("Utilities", "Hash Generator"),
    # Creative Tools (2)
    "color-palette-generator.html": ("Creative", "Color Palette Generator"),
    "font-pairing-tool.html": ("Creative", "Font Pairing Tool"),
    # Interactive Tools (1)
    "saas-launch-checklist.html": ("Interactive", "SaaS Launch Checklist"),
}

def generate_breadcrumbs(category, product_name):
    """Generate breadcrumb HTML and JSON-LD."""
    breadcrumb_html = f'''    <nav class="breadcrumbs" aria-label="Breadcrumb">
        <ol itemscope itemtype="https://schema.org/BreadcrumbList">
            <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
                <a itemprop="item" href="index.html"><span itemprop="name">Home</span></a>
                <meta itemprop="position" content="1" />
            </li>
            <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
                <a itemprop="item" href="index.html#{category.lower()}"><span itemprop="name">{category}</span></a>
                <meta itemprop="position" content="2" />
            </li>
            <li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
                <span itemprop="name">{product_name}</span>
                <meta itemprop="position" content="3" />
            </li>
        </ol>
    </nav>'''

    return breadcrumb_html

def generate_breadcrumb_css():
    """Generate CSS for breadcrumbs."""
    return '''    .breadcrumbs { margin-bottom: 20px; font-size: 0.85rem; }
    .breadcrumbs ol { display: flex; align-items: center; gap: 8px; list-style: none; padding: 0; margin: 0; flex-wrap: wrap; }
    .breadcrumbs li { display: flex; align-items: center; gap: 8px; }
    .breadcrumbs li:not(:last-child)::after { content: "›"; color: var(--muted); margin-left: 4px; }
    .breadcrumbs a { color: var(--muted); text-decoration: none; }
    .breadcrumbs a:hover { color: var(--accent); }
    .breadcrumbs li:last-child { color: var(--fg); }
'''

def add_breadcrumbs(filepath, category, product_name):
    """Add breadcrumbs to an HTML file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Check if breadcrumbs already exist
    if 'class="breadcrumbs"' in content:
        print(f"  [SKIP] {os.path.basename(filepath)} - already has breadcrumbs")
        return False

    # Add breadcrumb CSS (before </style>)
    breadcrumb_css = generate_breadcrumb_css()
    if '</style>' in content:
        content = content.replace('</style>', f'{breadcrumb_css}\n    </style>')

    # Add breadcrumb HTML (after container div starts, before header)
    breadcrumb_html = generate_breadcrumbs(category, product_name)

    # Find the container div and add breadcrumbs after it
    # Look for patterns like <div class="container"> or <main class="container">
    patterns = [
        (r'(<div class="container">)', r'\1\n{breadcrumb_html}'),
        (r'(<main class="container">)', r'\1\n{breadcrumb_html}'),
        (r'(<div class="container[^"]*">)', r'\1\n{breadcrumb_html}'),
    ]

    inserted = False
    for pattern, replacement in patterns:
        if re.search(pattern, content):
            content = re.sub(pattern, replacement.format(breadcrumb_html=breadcrumb_html), content, count=1)
            inserted = True
            break

    if not inserted:
        # Try to add after the opening body tag's first div
        match = re.search(r'<body[^>]*>\s*<div', content)
        if match:
            # Find the end of that first div tag
            pos = match.end()
            # Find where the container starts
            container_match = re.search(r'<div[^>]*class="container[^"]*"[^>]*>', content[pos-100:pos+500])
            if container_match:
                insert_pos = pos - 100 + container_match.end()
                content = content[:insert_pos] + '\n' + breadcrumb_html + content[insert_pos:]
                inserted = True

    if inserted:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  [OK] {os.path.basename(filepath)}")
        return True
    else:
        print(f"  [ERROR] {os.path.basename(filepath)} - could not find insertion point")
        return False

def main():
    projects_dir = "/mnt/c/Users/17503/Auto-Company/projects"

    print("Adding breadcrumbs to products...")
    print(f"Total products to process: {len(PRODUCT_CATEGORIES)}")
    print()

    updated = 0
    skipped = 0
    errors = 0

    for filename, (category, product_name) in PRODUCT_CATEGORIES.items():
        filepath = os.path.join(projects_dir, filename)
        if os.path.exists(filepath):
            if add_breadcrumbs(filepath, category, product_name):
                updated += 1
            else:
                result = "skipped" if 'class="breadcrumbs"' in open(filepath).read() else "error"
                if result == "skipped":
                    skipped += 1
                else:
                    errors += 1
        else:
            print(f"  [NOT FOUND] {filename}")
            errors += 1

    print()
    print(f"Summary: {updated} updated, {skipped} skipped, {errors} errors")

if __name__ == "__main__":
    main()
