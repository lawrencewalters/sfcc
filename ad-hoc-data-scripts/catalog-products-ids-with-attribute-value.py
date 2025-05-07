from lxml import etree
import os
from dotenv import load_dotenv

# Load environment variables from paths.env
load_dotenv('../sandbox-dataset-builder/paths.env')

# Get the base directory from the environment variable
BASE_DIR = os.getenv('TMP_DIR')

# Ensure the base directory is set
if not BASE_DIR:
    raise ValueError("BASE_DIR is not set in paths.env")

# Load the XML from a file
file_path = os.path.join(BASE_DIR, '2025-0416-junior-grip-data/TLST_Clubs_Master_2025-04-17_03-52-59_www.xml')
tree = etree.parse(file_path)

# Define the namespace
namespace = {'ns': 'http://www.demandware.com/xml/impex/catalog/2006-10-31'}

# Find all <product> elements with the specified attribute-id
products = tree.xpath("//ns:product[ns:custom-attributes/ns:custom-attribute[@attribute-id='junior-grip']]", namespaces=namespace)

# Create a set to store unique values of source-id and target-id
unique_ids = set()

# Add source-id and target-id to the set
for product in products:
    product_id = product.get("product-id")
    if product_id:
        unique_ids.add(product_id)

# Convert the set to a sorted list and print it
unique_list = sorted(unique_ids)
print("|".join(unique_list))