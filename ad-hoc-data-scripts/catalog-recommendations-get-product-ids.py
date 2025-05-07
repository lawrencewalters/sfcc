from lxml import etree

# Load the XML from a file
tree = etree.parse('titleist-clubs-storefront-CA-2025-04-17_03-55-00.xml')  # Replace with your file path

# Define the namespace
namespace = {'ns': 'http://www.demandware.com/xml/impex/catalog/2006-10-31'}

# Find all <recommendation> elements with the specified attribute-id
recommendations = tree.xpath("//ns:recommendation[ns:custom-attributes/ns:custom-attribute[@attribute-id='junior-grip']]", namespaces=namespace)

# Create a set to store unique values of source-id and target-id
unique_ids = set()

# Add source-id and target-id to the set
for recommendation in recommendations:
    source_id = recommendation.get("source-id")
    target_id = recommendation.get("target-id")
    if source_id:
        unique_ids.add(source_id)
    if target_id:
        unique_ids.add(target_id)

# Convert the set to a sorted list and print it
unique_list = sorted(unique_ids)
print(unique_list)