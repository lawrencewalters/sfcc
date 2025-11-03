#!/usr/bin/env python3
"""
Script to merge multiple catalog.xml files into a single catalog.
The script preserves the catalog and header elements from the first file,
and merges all product, category, category-assignment, and recommendation 
elements from all specified catalog files.

Usage:
  merge_catalogs.py <output_file> <catalog_file1> [catalog_file2] [catalog_file3] ...
  merge_catalogs.py --pattern <base_dir> <output_file>  (legacy mode)
"""

import os
import sys
import glob
import xml.etree.ElementTree as ET
from pathlib import Path

def merge_catalog_files(catalog_files, output_file):
    """
    Merge multiple catalog.xml files into a single catalog.
    
    Args:
        catalog_files (list): List of catalog.xml file paths to merge
        output_file (str): Output file path for merged catalog
    """
    
    if not catalog_files:
        print("No catalog files provided for merging")
        return False
    
    # Filter out non-existent files
    existing_files = []
    for catalog_file in catalog_files:
        if os.path.exists(catalog_file):
            existing_files.append(catalog_file)
        else:
            print(f"Warning: catalog file not found: {catalog_file}")
    
    if not existing_files:
        print("No valid catalog files found for merging")
        return False
    
    print(f"Found {len(existing_files)} catalog files to merge:")
    for file_path in existing_files:
        print(f"  - {file_path}")
    
    # Initialize variables for merged catalog
    merged_root = None
    merged_header = None
    all_products = []
    all_categories = []
    all_category_assignments = []
    all_recommendations = []
    
    # Track unique category IDs to avoid duplicates
    seen_category_ids = set()
    seen_product_ids = set()
    seen_recommendations = set()
    
    # Process each catalog file
    for i, catalog_file in enumerate(existing_files):
        if not os.path.exists(catalog_file):
            print(f"Warning: catalog.xml not found at {catalog_file}")
            continue
            
        print(f"Processing {catalog_file}...")
        
        try:
            # Parse the XML file
            tree = ET.parse(catalog_file)
            root = tree.getroot()
            
            # For the first file, use its catalog root and header
            if i == 0:
                merged_root = ET.Element(root.tag, root.attrib)
                # Copy namespace declarations
                for key, value in root.attrib.items():
                    merged_root.set(key, value)
                
                # Find and copy the header element
                header = root.find('.//{http://www.demandware.com/xml/impex/catalog/2006-10-31}header')
                if header is not None:
                    merged_header = ET.SubElement(merged_root, header.tag, header.attrib)
                    # Copy all header children
                    for child in header:
                        merged_header.append(child)
                else:
                    print(f"Warning: No header found in {catalog_file}")
            
            # Find and collect all element types
            products = root.findall('.//{http://www.demandware.com/xml/impex/catalog/2006-10-31}product')
            categories = root.findall('.//{http://www.demandware.com/xml/impex/catalog/2006-10-31}category')
            category_assignments = root.findall('.//{http://www.demandware.com/xml/impex/catalog/2006-10-31}category-assignment')
            recommendations = root.findall('.//{http://www.demandware.com/xml/impex/catalog/2006-10-31}recommendation')
            
            print(f"  Found {len(products)} products, {len(categories)} categories, {len(category_assignments)} category-assignments, {len(recommendations)} recommendations")
            
            for product in products:
                product_id = product.get('product-id')
                if product_id and product_id not in seen_product_ids:
                    all_products.append(product)
                    seen_product_ids.add(product_id)
            for category in categories:
                category_id = category.get('category-id')
                if category_id and category_id not in seen_category_ids:
                    all_categories.append(category)
                    seen_category_ids.add(category_id)
            for category_assignment in category_assignments:
                all_category_assignments.append(category_assignment)
            for recommendation in recommendations:
                reco_key = recommendation.get('source-id') + '->' + recommendation.get('target-id')
                if reco_key and reco_key not in seen_recommendations:
                    seen_recommendations.add(reco_key)
                    all_recommendations.append(recommendation)
                
        except ET.ParseError as e:
            print(f"Error parsing {catalog_file}: {e}")
            continue
        except Exception as e:
            print(f"Error processing {catalog_file}: {e}")
            continue
    
    if merged_root is None:
        print("Error: No valid catalog files were processed")
        return False
    
    # Add all elements to the merged catalog
    total_elements = len(all_products) + len(all_categories) + len(all_category_assignments) + len(all_recommendations)
    print(f"\nAdding {total_elements} total elements to merged catalog...")
    print(f"  - {len(all_products)} products")
    print(f"  - {len(all_categories)} categories") 
    print(f"  - {len(all_category_assignments)} category-assignments")
    print(f"  - {len(all_recommendations)} recommendations")
    
    for category in all_categories:
        merged_root.append(category)
    for product in all_products:
        merged_root.append(product)
    for category_assignment in all_category_assignments:
        merged_root.append(category_assignment)
    for recommendation in all_recommendations:
        merged_root.append(recommendation)
    
    # Create the merged XML tree
    merged_tree = ET.ElementTree(merged_root)
    
    # Ensure output directory exists
    output_dir = os.path.dirname(output_file)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Write the merged catalog
    try:
        # Register the namespace to avoid ns0 prefixes
        ET.register_namespace('', 'http://www.demandware.com/xml/impex/catalog/2006-10-31')
        
        # Write the merged catalog using ElementTree to ensure proper formatting
        merged_tree = ET.ElementTree(merged_root)
        merged_tree.write(output_file, encoding='utf-8', xml_declaration=True)
        
        print(f"\nMerged catalog written to: {output_file}")
        return True
        
    except Exception as e:
        print(f"Error writing merged catalog to {output_file}: {e}")
        return False

def main():
    """Main function to handle command line arguments and execute merge."""
    
    if len(sys.argv) < 3:
        print("Usage: merge_catalogs.py <output_file> <catalog_file1> [catalog_file2] [catalog_file3] ...")
        print("   or: merge_catalogs.py --pattern <base_dir> <output_file>")
        print("")
        print("Examples:")
        print("  # Merge specific catalog files:")
        print("  merge_catalogs.py merged.xml catalog1.xml catalog2.xml")
        print("")
        print("  # Use original pattern matching (legacy mode):")
        print("  merge_catalogs.py --pattern /path/to/base/dir merged.xml")
        sys.exit(1)
    
    # Check if using legacy pattern mode
    if sys.argv[1] == "--pattern":
        if len(sys.argv) != 4:
            print("Error: --pattern mode requires exactly 3 arguments: --pattern <base_dir> <output_file>")
            sys.exit(1)
        
        base_dir = sys.argv[2]
        output_file = sys.argv[3]
        
        # Legacy mode: find all directories matching the pattern
        pattern = os.path.join(base_dir, "titleist-clubs-master*")
        matching_dirs = glob.glob(pattern)
        
        if not matching_dirs:
            print(f"No directories matching 'titleist-clubs-master*' found in {base_dir}")
            sys.exit(1)
        
        catalog_files = []
        for dir_path in sorted(matching_dirs):
            catalog_file = os.path.join(dir_path, "catalog.xml")
            if os.path.exists(catalog_file):
                catalog_files.append(catalog_file)
        
        print("Catalog XML Merger (Pattern Mode)")
        print("=================================")
        print(f"Base directory: {base_dir}")
        
    else:
        # New mode: explicit catalog file list
        output_file = sys.argv[1]
        catalog_files = sys.argv[2:]
        
        print("Catalog XML Merger")
        print("==================")
    
    print(f"Output file: {output_file}")
    print()
    
    # Execute the merge
    success = merge_catalog_files(catalog_files, output_file)
    
    if success:
        print("\nMerge completed successfully!")
        sys.exit(0)
    else:
        print("\nMerge failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()