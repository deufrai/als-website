#!/bin/bash

# Check if STAGING_DIR environment variable is set
if [ -z "$STAGING_DIR" ]; then
  echo "Error: STAGING_DIR environment variable is not set."
  exit 1
fi

# Check if NODE_PATH environment variable is set
if [ -z "$NODE_PATH" ]; then
  echo "Error: NODE_PATH environment variable is not set."
  exit 1
fi

# Set the PATH to include Node.js binaries
export PATH=$PATH:$NODE_PATH

# Print the current status
echo "Starting the deployment process..."

# Navigate to the repository's working copy root (assuming the script is run from there)
REPO_ROOT=$(pwd)
echo "Repository root: $REPO_ROOT"

echo "Installing Project deps..."
npm install
if [ $? -ne 0 ]; then
  echo "Error: PostCSS install failed."
  exit 1
fi

# Initialize and update the Docsy submodule to v0.11.0
echo "Initializing and updating Docsy submodule..."
git submodule update --init --recursive
cd themes/docsy || { echo "Docsy directory not found"; exit 1; }
git checkout v0.11.0
if [ $? -ne 0 ]; then
  echo "Error: Failed to checkout Docsy version v0.11.0."
  exit 1
fi
echo "Docsy submodule updated to v0.11.0 successfully."

# Install Node.js dependencies if not already cached
if [ ! -d "node_modules" ]; then
  echo "Installing Node.js dependencies..."
  npm install
  if [ $? -ne 0 ]; then
    echo "Error: npm install failed."
    exit 1
  else
    echo "Node.js dependencies installed successfully."
  fi
else
  echo "Node.js dependencies already installed."
fi

cd "$REPO_ROOT" || { echo "failed to climb back to repo root"; exit 1; }

echo "updating footer with current commit hash"
sed -i "s/@@COMMIT_ID@@/${CI_COMMIT_SHORT_SHA:-UNDEFINED}/g" layouts/partials/footer.html

# Clean the public directory and build the Hugo site
echo "Building the Hugo site..."
hugo --cleanDestinationDir

# Check if the build was successful
if [ $? -ne 0 ]; then
  echo "Error: Hugo build failed."
  exit 1
fi
echo "Hugo build completed successfully."

# Empty the target folder using a safe method
echo "Emptying the target folder: ${STAGING_DIR:?}"
rm -rf "${STAGING_DIR:?}"/*
if [ $? -ne 0 ]; then
  echo "Error: Failed to empty the target folder."
  exit 1
fi

# Copy the generated files to the target folder
echo "Copying generated files to the target folder..."
cp -R public/* "${STAGING_DIR:?}"
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy files to the target folder."
  exit 1
fi
echo "Files copied successfully to the target folder."

# Set permissions to ensure files are accessible to the web server
echo "Setting permissions for the target folder..."
find "${STAGING_DIR:?}" -exec chmod -R u=rwX,go=rX {} +
if [ $? -ne 0 ]; then
  echo "Error: Failed to set permissions for the target folder."
  exit 1
fi
echo "Permissions set successfully."

# Print the completion message
echo "Deployment process completed successfully."
