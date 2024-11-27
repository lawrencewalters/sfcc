# list all the relative image paths given a small catalog file

import os
import xml.etree.ElementTree as ET
from dotenv import load_dotenv

load_dotenv()

# Path to the XML file
file_path = os.getenv('FILE_PATH')
print(file_path)

try:
    # Parse the XML file
    tree = ET.parse(file_path)
    root = tree.getroot()

    # Define the namespace
    namespace = {'ns': 'http://www.demandware.com/xml/impex/catalog/2006-10-31'}

    # Extract path attribute values from <image> elements
    paths = {image.get('path') for image in root.findall('.//ns:image', namespaces=namespace)}

    # Convert the set to a list and print the unique path values
    unique_paths = list(paths)
    print(unique_paths)

except ET.ParseError as e:
    print(f"Error parsing XML: {e}")
except FileNotFoundError:
    print("The specified file was not found.")
except Exception as e:
    print(f"An error occurred: {e}")