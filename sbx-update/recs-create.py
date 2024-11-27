# copy static recommendations from a big catalog to a smaller one
# given a small set of product sin product_file_path, copy
# the static recommendations from catalog_file_path into a
# new file output_file_path
#
# useful for acushnet's club customizer that relies on static
# recommendations for grips and shafts

import os
import xml.etree.ElementTree as ET
from dotenv import load_dotenv

load_dotenv()

# Paths to the XML files
product_file_path = os.getenv('FILE_PATH')
catalog_id = os.getenv('CATALOG_ID')
catalog_file_path = 'data/catalog.xml'
output_file_path = 'output/recommendations_output.xml'

# Parse the product XML file
product_tree = ET.parse(product_file_path)
product_root = product_tree.getroot()

# Define the namespace
namespace = {'ns': 'http://www.demandware.com/xml/impex/catalog/2006-10-31'}

# Extract product-id attribute values
product_ids = [product.get('product-id') for product in product_root.findall('.//ns:product', namespaces=namespace)]

# Parse the catalog XML file
catalog_tree = ET.parse(catalog_file_path)
catalog_root = catalog_tree.getroot()

# Create a new XML tree for the output
output_root = ET.Element('catalog', {
    'xmlns': 'http://www.demandware.com/xml/impex/catalog/2006-10-31',
    'catalog-id': catalog_id
})

# Iterate through product_ids and find matching recommendations
for product_id in product_ids:
    recommendations = catalog_root.findall(f".//ns:recommendation[@source-id='{product_id}']", namespaces=namespace)
    for recommendation in recommendations:
        output_root.append(recommendation)

# Write the collected recommendations to a new XML file
output_tree = ET.ElementTree(output_root)
output_tree.write(output_file_path, encoding='utf-8', xml_declaration=True)

print(f"Recommendations have been written to {output_file_path}")