import os
import subprocess
import shutil

# Define project paths (as before)
iac_dir = os.path.dirname(os.path.abspath(__file__))
shared_dependencies_dir = os.path.join(iac_dir, "shared_dependencies")

# --- Create Langchain Layer ZIP ---
print("Creating Langchain Layer ZIP...")
langchain_layer_dir = os.path.join(shared_dependencies_dir, "langchain_layer")
langchain_layer_python_dir = os.path.join(langchain_layer_dir, "python")
langchain_layer_site_packages_dir = os.path.join(langchain_layer_python_dir, "lib", "python3.11", "site-packages")  # Assuming Python 3.11
langchain_layer_zip_file = os.path.join(shared_dependencies_dir, "langchain_layer_payload.zip")
requirements_langchain_file = os.path.join(shared_dependencies_dir, "requirements-langchain.txt")

# Create the necessary directories
os.makedirs(langchain_layer_site_packages_dir, exist_ok=True)

# Install dependencies into the site-packages directory
if os.path.exists(requirements_langchain_file):
    subprocess.run(f"pip install -r {requirements_langchain_file} -t {langchain_layer_site_packages_dir}", shell=True, check=True, cwd=shared_dependencies_dir)
else:
    print(f"Warning: {requirements_langchain_file} not found.")

# Create the ZIP file with the correct structure
os.chdir(langchain_layer_dir)
subprocess.run(f"zip -r {langchain_layer_zip_file} python/*", shell=True, check=True)
os.chdir(iac_dir)
print(f"Langchain Layer ZIP created at: {langchain_layer_zip_file}")

# --- Create FAISS-CPU Layer ZIP ---
print("Creating FAISS-CPU Layer ZIP...")
faiss_layer_dir = os.path.join(shared_dependencies_dir, "faiss_layer")
faiss_layer_python_dir = os.path.join(faiss_layer_dir, "python")
faiss_layer_site_packages_dir = os.path.join(faiss_layer_python_dir, "lib", "python3.11", "site-packages")  # Assuming Python 3.11
faiss_layer_zip_file = os.path.join(shared_dependencies_dir, "faiss_layer_payload.zip")
requirements_faiss_file = os.path.join(shared_dependencies_dir, "requirements-faiss.txt")

# Create the necessary directories
os.makedirs(faiss_layer_site_packages_dir, exist_ok=True)

# Install dependencies into the site-packages directory
if os.path.exists(requirements_faiss_file):
    subprocess.run(f"pip install -r {requirements_faiss_file} -t {faiss_layer_site_packages_dir}", shell=True, check=True, cwd=shared_dependencies_dir)
else:
    print(f"Warning: {requirements_faiss_file} not found.")

# Create the ZIP file with the correct structure
os.chdir(faiss_layer_dir)
subprocess.run(f"zip -r {faiss_layer_zip_file} python/*", shell=True, check=True)
os.chdir(iac_dir)
print(f"FAISS-CPU Layer ZIP created at: {faiss_layer_zip_file}")

# --- Create Boto3 Layer ZIP ---
print("Creating Boto3 Layer ZIP...")
boto3_layer_dir = os.path.join(shared_dependencies_dir, "boto3_layer")
boto3_layer_python_dir = os.path.join(boto3_layer_dir, "python")
boto3_layer_site_packages_dir = os.path.join(boto3_layer_python_dir, "lib", "python3.11", "site-packages")  # Assuming Python 3.11
boto3_layer_zip_file = os.path.join(shared_dependencies_dir, "boto3_layer_payload.zip")
requirements_boto3_file = os.path.join(shared_dependencies_dir, "requirements-boto3.txt")

# Create the necessary directories
os.makedirs(boto3_layer_site_packages_dir, exist_ok=True)

# Install dependencies into the site-packages directory
if os.path.exists(requirements_boto3_file):
    subprocess.run(f"pip install -r {requirements_boto3_file} -t {boto3_layer_site_packages_dir}", shell=True, check=True, cwd=shared_dependencies_dir)
else:
    print(f"Warning: {requirements_boto3_file} not found.")

# Create the ZIP file with the correct structure
os.chdir(boto3_layer_dir)
subprocess.run(f"zip -r {boto3_layer_zip_file} python/*", shell=True, check=True)
os.chdir(iac_dir)
print(f"Boto3 Layer ZIP created at: {boto3_layer_zip_file}")

# --- Create PDF Processing Layer ZIP ---
print("Creating PDF Processing Layer ZIP...")
pdf_layer_dir = os.path.join(shared_dependencies_dir, "pdf_layer")
pdf_layer_python_dir = os.path.join(pdf_layer_dir, "python")
pdf_layer_site_packages_dir = os.path.join(pdf_layer_python_dir, "lib", "python3.11", "site-packages")  # Assuming Python 3.11
pdf_layer_zip_file = os.path.join(shared_dependencies_dir, "pdf_layer_payload.zip")
requirements_pdf_file = os.path.join(shared_dependencies_dir, "requirements-pdf.txt")

# Create the necessary directories
os.makedirs(pdf_layer_site_packages_dir, exist_ok=True)

# Install dependencies into the site-packages directory
if os.path.exists(requirements_pdf_file):
    subprocess.run(f"pip install -r {requirements_pdf_file} -t {pdf_layer_site_packages_dir}", shell=True, check=True, cwd=shared_dependencies_dir)
else:
    print(f"Warning: {requirements_pdf_file} not found.")

# Create the ZIP file with the correct structure
os.chdir(pdf_layer_dir)
subprocess.run(f"zip -r {pdf_layer_zip_file} python/*", shell=True, check=True)
os.chdir(iac_dir)
print(f"PDF Processing Layer ZIP created at: {pdf_layer_zip_file}")

# --- Create Data Ingestion Lambda ZIP (as before) ---
# --- Create Bedrock Proxy Lambda ZIP (as before) ---

print("\nAll Lambda ZIP files created successfully!")