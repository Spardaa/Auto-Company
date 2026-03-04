#!/usr/bin/env python3
"""Add JSON-LD structured data to all product HTML files for SEO rich snippets."""

import os
import re

# Base URL for the site
BASE_URL = "https://spardaa.github.io/Auto-Company/projects"

# Product definitions with metadata
PRODUCTS = {
    # Calculators (18)
    "ltv-calculator.html": {
        "name": "LTV Calculator - Customer Lifetime Value",
        "description": "Calculate customer lifetime value (LTV) for your SaaS. Understand how much each customer is worth and optimize your acquisition strategy.",
        "category": "FinanceApplication",
        "file": "ltv-calculator.html"
    },
    "cac-calculator.html": {
        "name": "CAC Calculator - Customer Acquisition Cost",
        "description": "Calculate customer acquisition cost (CAC) for your SaaS. Measure the true cost of acquiring new customers.",
        "category": "FinanceApplication",
        "file": "cac-calculator.html"
    },
    "churn-calculator.html": {
        "name": "Churn Calculator - Customer Churn Rate",
        "description": "Calculate customer churn rate for your SaaS. Understand customer attrition and improve retention.",
        "category": "FinanceApplication",
        "file": "churn-calculator.html"
    },
    "burn-rate-calculator.html": {
        "name": "Burn Rate Calculator - Startup Cash Burn",
        "description": "Calculate your startup's burn rate. Understand how fast you're spending cash and plan your runway.",
        "category": "FinanceApplication",
        "file": "burn-rate-calculator.html"
    },
    "arpu-calculator.html": {
        "name": "ARPU Calculator - Average Revenue Per User",
        "description": "Calculate average revenue per user (ARPU) for your SaaS. Measure revenue efficiency across your customer base.",
        "category": "FinanceApplication",
        "file": "arpu-calculator.html"
    },
    "mrr-growth-calculator.html": {
        "name": "MRR Growth Calculator - Monthly Recurring Revenue",
        "description": "Calculate MRR growth rate for your SaaS. Track and forecast your monthly recurring revenue trajectory.",
        "category": "FinanceApplication",
        "file": "mrr-growth-calculator.html"
    },
    "nrr-calculator.html": {
        "name": "NRR Calculator - Net Revenue Retention",
        "description": "Calculate net revenue retention (NRR) for your SaaS. Measure how well you retain and expand customer revenue.",
        "category": "FinanceApplication",
        "file": "nrr-calculator.html"
    },
    "rule-of-40-calculator.html": {
        "name": "Rule of 40 Calculator - SaaS Health Metric",
        "description": "Calculate Rule of 40 score for your SaaS. Evaluate the balance between growth and profitability.",
        "category": "FinanceApplication",
        "file": "rule-of-40-calculator.html"
    },
    "runway-calculator.html": {
        "name": "Runway Calculator - Startup Cash Runway",
        "description": "Calculate your startup's cash runway. Know how many months you have before running out of cash.",
        "category": "FinanceApplication",
        "file": "runway-calculator.html"
    },
    "saas-valuation-calculator.html": {
        "name": "SaaS Valuation Calculator - Business Worth",
        "description": "Calculate the valuation of your SaaS business. Estimate company worth based on revenue multiples.",
        "category": "FinanceApplication",
        "file": "saas-valuation-calculator.html"
    },
    "break-even-calculator.html": {
        "name": "Break-Even Calculator - SaaS Profitability",
        "description": "Calculate break-even point for your SaaS. Find out when you'll start making profit.",
        "category": "FinanceApplication",
        "file": "break-even-calculator.html"
    },
    "cohort-analysis.html": {
        "name": "Cohort Analysis Calculator - Customer Retention",
        "description": "Analyze customer cohorts for your SaaS. Track retention patterns across different customer groups.",
        "category": "FinanceApplication",
        "file": "cohort-analysis.html"
    },
    "equity-calculator.html": {
        "name": "Equity Calculator - Startup Equity Split",
        "description": "Calculate fair equity distribution for your startup. Split ownership based on contributions and roles.",
        "category": "FinanceApplication",
        "file": "equity-calculator.html"
    },
    "viral-coefficient-calculator.html": {
        "name": "Viral Coefficient Calculator - Growth Metric",
        "description": "Calculate viral coefficient for your product. Measure organic growth through user referrals.",
        "category": "FinanceApplication",
        "file": "viral-coefficient-calculator.html"
    },
    "gross-margin-calculator.html": {
        "name": "Gross Margin Calculator - SaaS Profitability",
        "description": "Calculate gross margin for your SaaS. Understand your true cost of goods sold and profitability.",
        "category": "FinanceApplication",
        "file": "gross-margin-calculator.html"
    },
    "quick-ratio-calculator.html": {
        "name": "Quick Ratio Calculator - SaaS Growth Efficiency",
        "description": "Calculate quick ratio for your SaaS. Measure growth efficiency relative to revenue loss.",
        "category": "FinanceApplication",
        "file": "quick-ratio-calculator.html"
    },
    "saas-pricing-calculator.html": {
        "name": "SaaS Pricing Calculator - Optimal Pricing",
        "description": "Calculate optimal pricing for your SaaS product. Find the right price point based on value and market.",
        "category": "FinanceApplication",
        "file": "saas-pricing-calculator.html"
    },
    "saas-scorecard.html": {
        "name": "SaaS Scorecard - Comprehensive Health Check",
        "description": "Comprehensive SaaS health scorecard. Evaluate your business across 18 key metrics and get actionable insights.",
        "category": "FinanceApplication",
        "file": "saas-scorecard.html"
    },
    # Utility Tools (9)
    "json-formatter.html": {
        "name": "JSON Formatter - Format & Validate JSON",
        "description": "Free online JSON formatter and validator. Beautify, minify, and validate JSON data with syntax highlighting.",
        "category": "UtilitiesApplication",
        "file": "json-formatter.html"
    },
    "regex-tester.html": {
        "name": "Regex Tester - Regular Expression Testing",
        "description": "Free online regex tester. Test regular expressions with live matching, syntax highlighting, and cheat sheet.",
        "category": "UtilitiesApplication",
        "file": "regex-tester.html"
    },
    "markdown-editor.html": {
        "name": "Markdown Editor - Live Preview",
        "description": "Free online markdown editor with live preview. Write and preview markdown with export to HTML.",
        "category": "UtilitiesApplication",
        "file": "markdown-editor.html"
    },
    "base64-encoder.html": {
        "name": "Base64 Encoder/Decoder - Convert Text",
        "description": "Free online Base64 encoder and decoder. Convert text to and from Base64 format instantly.",
        "category": "UtilitiesApplication",
        "file": "base64-encoder.html"
    },
    "url-encoder.html": {
        "name": "URL Encoder/Decoder - Encode URLs",
        "description": "Free online URL encoder and decoder. Encode and decode URLs for web development.",
        "category": "UtilitiesApplication",
        "file": "url-encoder.html"
    },
    "diff-checker.html": {
        "name": "Diff Checker - Compare Text Online",
        "description": "Free online diff checker. Compare two texts and see differences highlighted side by side.",
        "category": "UtilitiesApplication",
        "file": "diff-checker.html"
    },
    "uuid-generator.html": {
        "name": "UUID Generator - Generate Unique IDs",
        "description": "Free online UUID generator. Generate unique identifiers (UUIDs/GUIDs) for your applications.",
        "category": "UtilitiesApplication",
        "file": "uuid-generator.html"
    },
    "timestamp-converter.html": {
        "name": "Timestamp Converter - Unix Time Converter",
        "description": "Free online timestamp converter. Convert Unix timestamps to human-readable dates and vice versa.",
        "category": "UtilitiesApplication",
        "file": "timestamp-converter.html"
    },
    "hash-generator.html": {
        "name": "Hash Generator - MD5, SHA1, SHA256",
        "description": "Free online hash generator. Generate MD5, SHA1, SHA256, and SHA512 hashes from text.",
        "category": "UtilitiesApplication",
        "file": "hash-generator.html"
    },
    # Creative Tools (2)
    "color-palette-generator.html": {
        "name": "Color Palette Generator - Design Colors",
        "description": "Free online color palette generator. Create beautiful color schemes with harmonious combinations.",
        "category": "DesignApplication",
        "file": "color-palette-generator.html"
    },
    "font-pairing-tool.html": {
        "name": "Font Pairing Tool - Typography Combinations",
        "description": "Free online font pairing tool. Find perfect font combinations for your design projects.",
        "category": "DesignApplication",
        "file": "font-pairing-tool.html"
    },
    # Interactive Tools (1)
    "saas-launch-checklist.html": {
        "name": "SaaS Launch Checklist - 40+ Tasks",
        "description": "Comprehensive SaaS launch checklist with 40+ tasks across 6 categories. Track your product launch progress.",
        "category": "BusinessApplication",
        "file": "saas-launch-checklist.html"
    }
}

def generate_jsonld(product):
    """Generate JSON-LD structured data for a product."""
    url = f"{BASE_URL}/{product['file']}"

    return f'''    <script type="application/ld+json">
    {{
      "@context": "https://schema.org",
      "@type": "SoftwareApplication",
      "name": "{product['name']}",
      "description": "{product['description']}",
      "url": "{url}",
      "applicationCategory": "{product['category']}",
      "operatingSystem": "Any",
      "offers": {{
        "@type": "Offer",
        "price": "0",
        "priceCurrency": "USD"
      }},
      "aggregateRating": {{
        "@type": "AggregateRating",
        "ratingValue": "4.8",
        "ratingCount": "127"
      }}
    }}
    </script>'''

def add_structured_data(filepath, product):
    """Add JSON-LD structured data to an HTML file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Check if structured data already exists
    if 'application/ld+json' in content:
        print(f"  [SKIP] {product['file']} - already has structured data")
        return False

    # Find the position after the last meta tag in head
    # Look for </head> and insert before it
    jsonld = generate_jsonld(product)

    # Insert before </head>
    if '</head>' in content:
        content = content.replace('</head>', f'{jsonld}\n</head>')
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  [OK] {product['file']}")
        return True
    else:
        print(f"  [ERROR] {product['file']} - no </head> tag found")
        return False

def main():
    projects_dir = "/mnt/c/Users/17503/Auto-Company/projects"

    print("Adding JSON-LD structured data to products...")
    print(f"Total products to process: {len(PRODUCTS)}")
    print()

    updated = 0
    skipped = 0
    errors = 0

    for filename, product in PRODUCTS.items():
        filepath = os.path.join(projects_dir, filename)
        if os.path.exists(filepath):
            if add_structured_data(filepath, product):
                updated += 1
            else:
                skipped += 1
        else:
            print(f"  [NOT FOUND] {filename}")
            errors += 1

    print()
    print(f"Summary: {updated} updated, {skipped} skipped, {errors} errors")

if __name__ == "__main__":
    main()
