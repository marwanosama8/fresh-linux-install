#!/bin/bash
# Linux environment setup script for Laravel development with PHP 8.3

# Check if running as root, if not restart with sudo
if [ "$(id -u)" -ne 0 ]; then
    exec sudo bash "$0" "$@"
fi

# Update system and install basic dependencies
echo "Updating system and installing basic dependencies..."
apt-get update
apt-get upgrade -y
apt-get install -y network-manager libnss3-tools jq xsel software-properties-common curl git unzip

# Add required repositories
echo "Adding repositories..."
add-apt-repository -y ppa:nginx/stable
add-apt-repository -y ppa:ondrej/php
apt-get update

# Install PHP 8.3 and extensions
echo "Installing PHP 8.3 and extensions..."
apt-get install -y php8.3 php8.3-fpm php8.3-cli php8.3-common \
    php8.3-curl php8.3-mbstring php8.3-opcache php8.3-readline \
    php8.3-xml php8.3-zip php8.3-mysql php8.3-gd php8.3-bcmath \
    php8.3-imagick php8.3-intl php8.3-redis php8.3-soap php8.3-sqlite3 \
    php8.3-pgsql php8.3-ldap php8.3-ssh2 php8.3-xdebug

# Configure PHP
echo "Configuring PHP..."
sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php/8.3/cli/php.ini
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 128M/' /etc/php/8.3/cli/php.ini
sed -i 's/post_max_size = .*/post_max_size = 128M/' /etc/php/8.3/cli/php.ini
sed -i 's/max_execution_time = .*/max_execution_time = 300/' /etc/php/8.3/cli/php.ini

# Install MySQL
echo "Installing MySQL..."
apt-get install -y mysql-server
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '12345678';"
mysql -e "CREATE USER 'laravel'@'localhost' IDENTIFIED BY 'laravel';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'laravel'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# Install Composer
echo "Installing Composer..."
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
composer --version

# Install Laravel Valet
echo "Installing Laravel Valet..."
composer global require genesisweb/valet-linux-plus
export PATH="$PATH:$HOME/.config/composer/vendor/bin"
valet install

# Install Node.js and NPM (using nvm)
echo "Installing Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install --lts
nvm use --lts

# Install additional tools via apt
echo "Installing additional tools..."
apt-get install -y nginx redis-server

# Install snap packages
echo "Installing snap packages..."
if ! command -v snap &> /dev/null; then
    rm -f /etc/apt/preferences.d/nosnap.pref
    apt update
    apt install -y snapd
fi
snap install code --classic
snap install postman
snap install dbeaver-ce

# Install Google Chrome
echo "Installing Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
apt-get install -y /tmp/chrome.deb
rm /tmp/chrome.deb

# Fix common permission issues
echo "Fixing common permission issues..."
chown -R $SUDO_USER:$SUDO_USER ~/.composer/
chown -R $SUDO_USER:$SUDO_USER ~/.config/

echo "Setup completed successfully!"
echo "Please log out and log back in for all changes to take effect."
