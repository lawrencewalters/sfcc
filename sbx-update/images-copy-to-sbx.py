# copy images from Staging to a sandbox for a given set of products

import os
import requests
import xml.etree.ElementTree as ET
from dotenv import load_dotenv

load_dotenv()

# Paths and URLs
file_path = os.getenv('FILE_PATH')
base_download_url = os.getenv('BASE_DOWNLOAD_URL')
base_upload_url = os.getenv('BASE_UPLOAD_URL')
output_dir = os.getenv('OUTPUT_DIR')

# WebDAV credentials (replace with actual credentials)
download_username = os.getenv('DOWNLOAD_USERNAME')
download_password = os.getenv('DOWNLOAD_PASSWORD')
upload_username = os.getenv('UPLOAD_USERNAME')
upload_password = os.getenv('UPLOAD_PASSWORD')

# List to track successfully downloaded files
downloaded_files = []

try:
    # Parse the XML file
    tree = ET.parse(file_path)
    root = tree.getroot()

    # Define the namespace
    namespace = {'ns': 'http://www.demandware.com/xml/impex/catalog/2006-10-31'}

    # Extract unique path attribute values from <image> elements
    paths = {image.get('path') for image in root.findall('.//ns:image', namespaces=namespace)}

    # Create the output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Download each file and save it locally
    for path in paths:
        if path:
            # Construct the full URL
            file_url = f"{base_download_url}{path}"
            # Construct the local file path
            local_file_path = os.path.join(output_dir, path.lstrip('/'))

            # Create directories if they don't exist
            os.makedirs(os.path.dirname(local_file_path), exist_ok=True)

            # Make the WebDAV request, ignoring SSL certificate errors
            response = requests.get(file_url, auth=(download_username, download_password), verify=False)

            # Check if the request was successful
            if response.status_code == 200:
                # Save the file locally
                with open(local_file_path, 'wb') as file:
                    file.write(response.content)
                print(f"Downloaded: {file_url} to {local_file_path}")
                downloaded_files.append(local_file_path)
            else:
                print(f"Failed to download: {file_url} (Status code: {response.status_code})")

    # Upload the successfully downloaded files
    for local_file_path in downloaded_files:
        # Construct the relative path for the upload URL
        relative_path = os.path.relpath(local_file_path, output_dir).replace('\\', '/')
        upload_url = f"{base_upload_url}/{relative_path}"

        # Read the file content
        with open(local_file_path, 'rb') as file:
            file_content = file.read()

        # Make the WebDAV request to upload the file
        response = requests.put(upload_url, auth=(upload_username, upload_password), data=file_content, verify=False)

        # Check if the request was successful
        if response.status_code == 201:
            print(f"Uploaded: {local_file_path} to {upload_url}")
        else:
            print(f"Failed to upload: {local_file_path} to {upload_url} (Status code: {response.status_code})")

except ET.ParseError as e:
    print(f"Error parsing XML: {e}")
except FileNotFoundError:
    print("The specified file was not found.")
except Exception as e:
    print(f"An error occurred: {e}")