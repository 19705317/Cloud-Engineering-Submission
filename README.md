# Manual Deployment of a Two-Tier Website Using Nginx, Nodejs and MongoDB

This documentation provides step-by-step instructions for manually deploying a website using Nginx as the web server and MongoDB as the database on a virtual machine (VM) within Azure. The deployment uses an SSH public-private key pair connection and the public address of a Virtual Network (VNet) to allow external access.

---

## Prerequisites

Before proceeding with the deployment, the following is required:
- An Azure VM is set up and accessible via SSH.
- Public-private key pair configured for secure access.
- A zip file containing the application code is ready for transfer.

---
# Deployment of the online App
# Step 1: Update and Upgrade the VM

The first step ensures that the VM's software packages are up-to-date.

    sudo apt update -y

    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

## What the Commands Do:
sudo apt update -y: Updates the local list of available packages and their versions.

sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y: Upgrades all outdated packages without prompting for user input.

# Step 2: Install Nginx

    sudo DEBIAN_FRONTEND=noninteractive apt-get install nginx -y

Note: Nginx will serve as the reverse proxy for the application.

## What the Commands Do:
sudo DEBIAN_FRONTEND=noninteractive apt-get install nginx -y: Installs the Nginx web server in non-interactive mode to avoid prompts.

# Step 3: Install Node.js

    curl -fsSL https://deb.nodesource.com/setup_20.x -o setup_nodejs.sh

    sudo DEBIAN_FRONTEND=noninteractive bash setup_nodejs.sh

    sudo DEBIAN_FRONTEND=noninteractive apt-get install nodejs -y

    node -v

## What the Commands Do:
curl -fsSL ... -o setup_nodejs.sh: Downloads the setup script for the specified Node.js version.

sudo bash setup_nodejs.sh: Executes the setup script to configure the repository for Node.js installation.

sudo apt-get install nodejs -y: Installs Node.js and npm.

node -v: Checks the installed Node.js version to verify successful installation.

# Step 4: Transfer Application Code to VM

    scp -i (private-key) (path-to-zip-file) adminuser@(VM-Public-IP):~

## What the Commands Do:
scp -i ...: Securely copies the zip file to the home directory of the VM using the SSH private key for authentication.

# Step 5: Prepare Application Code

    sudo apt-get update

    sudo DEBIAN_FRONTEND=noninteractive apt-get install unzip -y

    unzip (zip-file-name)

## What the Commands Do:
sudo apt-get update: Updates the package list to ensure the latest software is available.

sudo apt-get install unzip -y: Installs the unzip utility to extract compressed files.

unzip (zip-file-name): Extracts the application zip file into the home directory.

# Step 6: Install and add App Dependencies

    cd (application-directory)

    export DB_HOST=mongodb://10.0.3.4:27017/posts

    npm install

## What the Commands Do:
cd (application-directory): Changes the current directory to the application folder.

export DB_HOST: creates environment variable used to connect the application to the database VM through its private address and port

npm install: Downloads and installs the dependencies specified in the package.json file.

# Step 7: Start the App

    node app.js &

## What the Commands Do:
node app.js &: Runs the Node.js application in the background. The & ensures the terminal remains available for other tasks.

# Deployment of the Database for the App

---

## Prerequisites

Ensure the following before proceeding:
- A new Azure VM is provisioned within the same private network as the application VM.
- SSH access to the VM is configured.
- The private network between VMs is properly configured to allow communication.

---

# Step 1: Update and Upgrade VM Packages

    sudo apt update -y

    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

## What the Commands Do:
sudo apt update -y: Updates the local package index.

sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y: Upgrades all installed packages without user interaction.

# Step 2: Import MongoDB Public Key

    curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
        sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
        --dearmor

## What the Commands Do:

curl -fsSL ...: Downloads the public key required to verify the authenticity of the MongoDB packages and saves it in a secure format that apt can use.

# Step 3: Create MongoDB List File

    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

## What the Commands Do:

echo "deb ...: Adds the MongoDB repository to the system's list of sources, enabling apt to find and download MongoDB packages.

# Step 4: Update MongoDB Package List

    sudo apt-get update

## What the Commands Do:

sudo apt-get update: Refreshes the package list to include the newly added MongoDB repository.

# Step 5: Install MongoDB

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org=7.0.6 mongodb-org-database=7.0.6 mongodb-org-server=7.0.6 mongodb-mongosh mongodb-org-mongos=7.0.6 mongodb-org-tools=7.0.6


## What the Commands Do:

sudo install: Installs MongoDB version 7.0.6, including the database, server, shell, routing service, and additional tools.

# Step 6: Configure MongoDB to Listen on All IPs

    sudo sed -i.bak 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf

## What the Commands Do:

sudo sed -i ...: Updates MongoDB's configuration file to allow connections from all IP addresses. This is necessary for the application server to connect to the database.

# Step 7: Restart MongoDB

    sudo systemctl restart mongod

## What the Commands Do:

sudo systemctl restart mongod: Restarts the MongoDB service to apply changes made to the configuration file.

# Step 8: Remove MongoDB Socket File

    sudo rm -rf /tmp/mongodb-27017.sock

## What the Commands Do:
sudo rm -rf: Deletes the temporary socket file if not already done so by potential permission issues.

# Step 9: Enable MongoDB on Boot

    sudo systemctl enable mongod

## What the Commands Do:

sudo systemctl enable mongod: Configures MongoDB to start automatically whenever the VM is restarted.

# Automated Code for App creation

    #!/bin/bash

    # update
    sudo apt update -y

    # upgrade (completely noninteractive)
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

    # install nginx
    sudo DEBIAN_FRONTEND=noninteractive apt-get install nginx -y

    # install pm2
    sudo npm install -g pm2

    # download noadjs shell script
    curl -fsSL https://deb.nodesource.com/setup_20.x -o setup_nodejs.sh

    # run setup_nodejs.sh (bash is used to run the file) (this readies all the files)
    sudo DEBIAN_FRONTEND=noninteractive bash setup_nodejs.sh

    # sudo apt-get install nodejs (use "node -v" to get version)
    sudo DEBIAN_FRONTEND=noninteractive apt-get install nodejs -y

    # export DB connection
    export DB_HOST=mongodb://10.0.3.4:27017/posts

    # setup reverse proxy
    sudo sed -i 's|try_files.*;|proxy_pass http://localhost:3000/;|' /etc/nginx/sites-available/default

    # restart nginx
    sudo systemctl restart nginx

    # clone app repo
    git clone https://github.com/daraymonsta/tech201-sparta-app /repo

    # install npm
    cd /repo/app
    npm install

    #run app
    pm2 start app.js

# Automated code for Database creation

    !#/bin/bash

    # update vm packages
    sudo apt update -y

    # upgrade packages
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

    # import mongodb public key
    curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
        sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
        --dearmor

    # create mongoDB list file
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

    # update the mongoDB package
    sudo apt-get update

    # download specific version of mongoDB
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org=7.0.6 mongodb-org-database=7.0.6 mongodb-org-server=7.0.6 mongodb-mongosh mongodb-org-mongos=7.0.6 mongodb-org-tools=7.0.6

    # change config of mongod local ip to default gateway
    sudo sed -i.bak 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf 

    # restart mongoDB to change configuration
    sudo systemctl restart mongod

    # manually delete 27017 from sock file due to permission issues
    sudo rm -rf /tmp/mongodb-27017.sock

    # enable mongodb
    sudo systemctl enable mongod

# Creating Generalised Images for Automated Deployment

This guide outlines the steps to create reusable generalised images of two VMs (App VM and Database VM) in Azure, simplifying provisioning for future deployments.

---

## Steps to Create Generalised VM Images

### Step 1: Navigate to the VM Overview
1. Log in to the Azure portal.
2. Go to the **Virtual Machines** section and select the completed VM.
3. Navigate to the **Overview** tab.

---

### Step 2: Capture the Image
1. Click on the **Capture** button.
2. In the image creation panel:
   - Deselect the option to share the image to the Azure gallery (for private use).
   - Provide a meaningful name for the image (e.g., `App-VM-Image`, `DB-VM-Image`).
3. Confirm and create the image.

---

### Step 3: Customization for App VM

- Add the following **user data script** to the App VM during deployment to configure it dynamically:

```bash
#!/bin/bash
echo "export DB_HOST=mongodb://10.0.3.4:27017/posts" >> ~/.bashrc
export DB_HOST=mongodb://10.0.3.4:27017/posts

cd /repo/app
npm install
pm2 stop all
pm2 start app.js

