#!/bin/bash
# Made By Rulzx
# This is free, change this is not cool

set -e 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 

echo -e "${GREEN}Starting Instalation...${NC}"

PTERODACTYL_DIRECTORY=${PTERODACTYL_DIRECTORY:-/var/www/pterodactyl}
export PTERODACTYL_DIRECTORY

echo -e "${YELLOW}Pterodactyl Directory: ${PTERODACTYL_DIRECTORY}${NC}"

if [ ! -d "$PTERODACTYL_DIRECTORY" ]; then
    echo -e "${RED}Directory $PTERODACTYL_DIRECTORY Not found.${NC}"
    exit 1
fi

echo -e "${GREEN}Installing curl, wget, unzip...${NC}"
sudo apt update
sudo apt install -y curl wget unzip

cd "$PTERODACTYL_DIRECTORY"

echo -e "${GREEN}Downloading Latest Blueprint...${NC}"
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | grep 'release.zip' | cut -d '"' -f 4)
if [ -z "$DOWNLOAD_URL" ]; then
    echo -e "${RED}GaFailed.${NC}"
    exit 1
fi

wget "$DOWNLOAD_URL" -O "$PTERODACTYL_DIRECTORY/release.zip"
unzip -o release.zip
rm release.zip  

sudo apt install -y ca-certificates curl git gnupg unzip wget zip

echo -e "${GREEN}Installing${NC}"
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
sudo apt install -y nodejs
cd "$PTERODACTYL_DIRECTORY"
sudo npm i -g yarn
yarn install
cat > "$PTERODACTYL_DIRECTORY/.blueprintrc" << EOF
WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";
EOF

chmod +x "$PTERODACTYL_DIRECTORY/blueprint.sh"

echo -e "${GREEN}Running blueprint.sh...${NC}"
bash "$PTERODACTYL_DIRECTORY/blueprint.sh"

read -p "Add autocompletion Blueprint To .bashrc? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo 'source /var/www/pterodactyl/blueprint.sh' >> ~/.bashrc
    echo -e "${GREEN}Autocompletion Added. run 'source ~/.bashrc' or open new terminal.${NC}"
fi

echo -e "${GREEN}Blueprint installation Done${NC}"
