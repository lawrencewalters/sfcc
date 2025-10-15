# copy static recommendations from a big catalog (source_storefront_catalog_file_path)
# to a smaller one (output_file_path) given a small set of products 
# in an XML catalog file (source_master_catalog)
#
# useful for acushnet's club customizer that relies on static
# recommendations for grips and shafts

import os
import sys
import xml.etree.ElementTree as ET
from dotenv import load_dotenv

load_dotenv()

# Check if command line arguments are provided
if len(sys.argv) == 7:
    # Use command line arguments with variations output directory
    source_master_catalog = sys.argv[1]
    storefront_catalog_id = sys.argv[2]
    source_storefront_catalog_file_path = sys.argv[3]
    output_file_path = sys.argv[4]
    limit_recommendations = sys.argv[5].lower() == 'true'
    rec_targets_output_dir = sys.argv[6]
elif len(sys.argv) == 6:
    # Use command line arguments
    source_master_catalog = sys.argv[1]
    storefront_catalog_id = sys.argv[2]
    source_storefront_catalog_file_path = sys.argv[3]
    output_file_path = sys.argv[4]
    limit_recommendations = sys.argv[5].lower() == 'true'
    rec_targets_output_dir = None
elif len(sys.argv) == 5:
    # Backward compatibility - no limit flag provided
    source_master_catalog = sys.argv[1]
    storefront_catalog_id = sys.argv[2]
    source_storefront_catalog_file_path = sys.argv[3]
    output_file_path = sys.argv[4]
    limit_recommendations = False
    rec_targets_output_dir = None
else:
    # Use default values (for backward compatibility)
    source_master_catalog = '/home/lwalters/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/wedges/catalogs/titleist-clubs-master/catalog.xml'
    storefront_catalog_id = 'titleist-storefront'
    source_storefront_catalog_file_path = '/home/lwalters/bitbucket.org/lyonsconsultinggroup/acushnet/tmp/staging/catalogs/titleist-storefront/catalog.xml'
    output_file_path = 'output/recommendations_output.xml'
    limit_recommendations = False
    rec_targets_output_dir = None

# Parse the product XML file
product_tree = ET.parse(source_master_catalog)
product_root = product_tree.getroot()

# Define the namespace
namespace = {'ns': 'http://www.demandware.com/xml/impex/catalog/2006-10-31'}

# Extract product-id attribute values
product_ids = [product.get('product-id') for product in product_root.findall('.//ns:product', namespaces=namespace)]

# Parse the catalog XML file
storefront_catalog_tree = ET.parse(source_storefront_catalog_file_path)
storefront_catalog_root = storefront_catalog_tree.getroot()

# Create a new XML tree for the output
output_root = ET.Element('catalog', {
    'xmlns': 'http://www.demandware.com/xml/impex/catalog/2006-10-31',
    'catalog-id': storefront_catalog_id
})

# Set to collect unique target-id values
unique_target_ids = set()

# Iterate through product_ids and find matching recommendations
for product_id in product_ids:
    # Break early if we have enough unique target IDs
    if limit_recommendations and len(unique_target_ids) >= 20:
        break
        
    recommendations = storefront_catalog_root.findall(f".//ns:recommendation[@source-id='{product_id}']", namespaces=namespace)
    
    if limit_recommendations:
        # Track recommendation types for this product to limit to 3 per type
        type_counts = {}
        
    for recommendation in recommendations:
        if limit_recommendations:
            # Check if we've reached the global limit
            if len(unique_target_ids) >= 20:
                break
                
            # Get recommendation type and limit to 3 per type
            rec_type = recommendation.get('type', 'unknown')
            type_counts[rec_type] = type_counts.get(rec_type, 0)
            if type_counts[rec_type] >= 3:
                continue
            type_counts[rec_type] += 1
        
        output_root.append(recommendation)
        # Extract and collect unique target-id values
        target_id = recommendation.get('target-id')
        if target_id:
            unique_target_ids.add(target_id)

# Write the collected recommendations to a new XML file
output_tree = ET.ElementTree(output_root)
output_tree.write(output_file_path, encoding='utf-8', xml_declaration=True)

print(f"Recommendations have been written to {output_file_path}")

# Write unique target-id values to recs-targets file
if rec_targets_output_dir:
    rec_targets_file_path = f"{rec_targets_output_dir}/recs-targets.txt"
else:
    rec_targets_file_path = 'recs-targets.txt'

with open(rec_targets_file_path, 'w') as f:
    f.write('|'.join(sorted(unique_target_ids)))

print(f"Found {len(unique_target_ids)} unique target-id values written to {rec_targets_file_path}")