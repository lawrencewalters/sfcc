import os
import sys
import argparse
import xml.etree.ElementTree as ET
from dotenv import load_dotenv

load_dotenv()

# limits used when --limit-recs flag is set
MAX_RECOMMENDATIONS_PER_TYPE = 5
MAX_UNIQUE_TARGET_IDS = 20

# Parse command line arguments
parser = argparse.ArgumentParser(
    description='Copy static recommendations from a big catalog to a smaller one given a small set of products',
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog='''
Examples:
  # Basic usage
  python3 generate-static-recs.py --master-catalog master.xml --catalog-id storefront-id --source-catalog source.xml --output output.xml

  # With recommendation limits
  python3 generate-static-recs.py --master-catalog master.xml --catalog-id storefront-id --source-catalog source.xml --output output.xml --limit-recs

  # With limits and custom output directory
  python3 generate-static-recs.py --master-catalog master.xml --catalog-id storefront-id --source-catalog source.xml --output output.xml --limit-recs --targets-dir /path/to/output
    '''
)

parser.add_argument('--master-catalog', '-m',
                    required=True,
                    help='Path to the master catalog XML file containing source products')

parser.add_argument('--catalog-id', '-c',
                    required=True,
                    help='ID of the storefront catalog for the output XML')

parser.add_argument('--source-catalog', '-s',
                    required=True,
                    help='Path to the source storefront catalog XML file containing recommendations')

parser.add_argument('--output', '-o',
                    required=True,
                    help='Path where the filtered recommendations XML will be written')

parser.add_argument('--limit-recs', '-l',
                    action='store_true',
                    help=f'Limit recommendations (20 max target IDs, {MAX_RECOMMENDATIONS_PER_TYPE} per type)')

parser.add_argument('--targets-dir', '-t',
                    help='Directory where recs-targets.txt will be written (defaults to current directory)')

args = parser.parse_args()

# Assign parsed arguments to variables
source_master_catalog = args.master_catalog
storefront_catalog_id = args.catalog_id
source_storefront_catalog_file_path = args.source_catalog
output_file_path = args.output
limit_recommendations = args.limit_recs
rec_targets_output_dir = args.targets_dir

# Parse the product XML file
product_tree = ET.parse(source_master_catalog)
product_root = product_tree.getroot()

# Define the namespace
namespace = {'ns': 'http://www.demandware.com/xml/impex/catalog/2006-10-31'}

# Register namespace to avoid ns0: prefix in output
ET.register_namespace('', 'http://www.demandware.com/xml/impex/catalog/2006-10-31')

# Extract product-id attribute values
product_ids = [product.get('product-id') for product in product_root.findall('.//ns:product', namespaces=namespace)]

# Parse the catalog XML file
storefront_catalog_tree = ET.parse(source_storefront_catalog_file_path)
storefront_catalog_root = storefront_catalog_tree.getroot()

# Create a new XML tree for the output
output_root = ET.Element('{http://www.demandware.com/xml/impex/catalog/2006-10-31}catalog', {
    'catalog-id': storefront_catalog_id
})

# Set to collect unique target-id values
unique_target_ids = set()

# Iterate through product_ids and find matching recommendations
for product_id in product_ids:
    # print(f"{product_id}: finding static recs for product-id {product_id}...")
    # Break early if we have enough unique target IDs
    if limit_recommendations and len(unique_target_ids) >= 20:
        break

    recommendations = storefront_catalog_root.findall(f".//ns:recommendation[@source-id='{product_id}']", namespaces=namespace)

    if limit_recommendations:
        # Track recommendation types for this product to limit to 3 per type
        type_counts = {}

    for recommendation in recommendations:
        # Extract and collect unique target-id values
        target_id = recommendation.get('target-id')
        if target_id:

            # skip if there are no category assignments for this recommended product
            category_assignments = storefront_catalog_root.findall(f".//ns:category-assignment[@product-id='{target_id}']", namespaces=namespace)
            if len(category_assignments) == 0:
                # print(f"{product_id}: {target_id}: Skipping recommended target {target_id} because it has no category assignments in the storefront catalog")
                continue
            # else:
                # print(f"{product_id}: {target_id}: found recommended target {target_id} category assignment {category_assignments[0].get('category-id')} in storefront catalog,")

            if limit_recommendations:
                # Check if we've reached the global limit
                if len(unique_target_ids) >= MAX_UNIQUE_TARGET_IDS:
                    print(f"{product_id}: {target_id}: reached {len(unique_target_ids)} unique target IDs, stopping recommendation collection")
                    break

                # Get recommendation type and limit per type
                rec_type = recommendation.get('type', 'unknown')
                type_counts[rec_type] = type_counts.get(rec_type, 0)
                if type_counts[rec_type] >= MAX_RECOMMENDATIONS_PER_TYPE:
                    if type_counts.get("4", 0) >= MAX_RECOMMENDATIONS_PER_TYPE and type_counts.get("5", 0) >= MAX_RECOMMENDATIONS_PER_TYPE:
                        # print(f"{product_id}: {target_id}: reached {MAX_RECOMMENDATIONS_PER_TYPE} recommendations for types 4 and 5, stopping recommendation collection")
                        break
                    else:
                        # print(f"{product_id}: {target_id}: type_counts[{rec_type}] is greater >= {MAX_RECOMMENDATIONS_PER_TYPE}, not adding this target id")
                        continue
                type_counts[rec_type] += 1
                # print(f"{product_id}: {target_id}: type_counts[{rec_type}] is now {type_counts[rec_type]}")

            print(f"{product_id} -> type [{rec_type}] target {target_id} added")
            output_root.append(recommendation)
            unique_target_ids.add(target_id)

# Write the collected recommendations to a new XML file
output_tree = ET.ElementTree(output_root)
output_tree.write(output_file_path, encoding='utf-8', xml_declaration=True)


# Write unique target-id values to recs-targets file
if rec_targets_output_dir:
    rec_targets_file_path = f"{rec_targets_output_dir}/recs-targets.txt"
else:
    rec_targets_file_path = 'recs-targets.txt'

with open(rec_targets_file_path, 'w') as f:
    f.write('|'.join(sorted(unique_target_ids)))

print(f"Club recommendations for {len(unique_target_ids)} shaft/grip products XML written to {output_file_path}, master product ids written to {rec_targets_file_path}")