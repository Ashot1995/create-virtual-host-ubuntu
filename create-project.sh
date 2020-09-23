#!/bin/bash

# This script creates a new project (or site) under /var/www and creates
# new virtual host for that site. With the options a site can also
# install the latest version of Laravel directly.
# Ashot Gharakeshishyan

# Display the usage information of the command.
create-project-usage() {
cat <<"USAGE"
Usage: create-project [OPTIONS] <name>

	-h, --help        Show this help screen
	-u, --url         Specify a local address, default is http://name.loc
	-e, --email       Email of the administrator in the virtual host file
	--list            List the current virtual host
	-l, --laravel     Create a new Laravel project

Examples:

	create-project foo
	create-project --laravel foo
	create-project --remove foo
USAGE
exit 0
}

# Remove a project and its Virtual Host.
project-remove() {
	sudo -v
	echo "Removing $url from /etc/hosts."
	sudo sed -i '/'$url'/d' /etc/hosts

	echo "Disabling and deleting the $name virtual host."
	sudo a2dissite $name.conf
	sudo rm /etc/apache2/sites-available/$name.conf
	sudo service apache2 reload

	echo "Project has been removed. The document root still exists."
	exit 0
}

# List the available and enabled virtual hosts.
project-list() {
	echo "Available virtual hosts:"
	ls -l /etc/apache2/sites-available/
	echo "Enabled virtual hosts:"
	ls -l /etc/apache2/sites-enabled/
	exit 0
}

# Define and create default values.
name="${!#}"
email="webmaster@localhost"
url="$name.loc"
docroot="/var/www/$name"
laravel=0

# Loop to read options and arguments.
while [ $1 ]; do
	case "$1" in
		'--list')
			project-list;;
		'--help'|'-h')
			create-project-usage;;
		'--remove'|'-r')
			url="$2"
			project-remove;;
		'--url'|'-u')
			url="$2";;
		'--email'|'-e')
			email="$2";;
		'--laravel'|'-l')
			laravel=1
	esac
	shift
done

# If we are not creating a Laravel project then the document root will be
# htdocs, otherwise it will be public.
if [ "$laravel" = 0 ]; then
	docroot="$docroot/htdocs"
fi

# Check if the docroot exists, if it does not exist then we'll create it.
if [ ! -d "$docroot" ]; then
	echo "Creating $docroot directory..."
	mkdir -p $docroot
fi

# If creating a Laravel project then we'll use composer to create the
# new project in the document root.
if [ "$laravel" = 1 ]; then
	echo -e "Installing latest version of Laravel...\n"
	composer create-project --keep-vcs laravel/laravel $docroot
	docroot="$docroot/public"
fi

echo -e "\nCreating the new $name Virtual Host with DocumentRoot: $docroot"

sudo cp /etc/apache2/sites-available/template /etc/apache2/sites-available/$name.conf
sudo sed -i 's/template.email/'$email'/g' /etc/apache2/sites-available/$name.conf
sudo sed -i 's/template.url/'$url'/g' /etc/apache2/sites-available/$name.conf
sudo sed -i 's#template.docroot#'$docroot'#g' /etc/apache2/sites-available/$name.conf

echo "Adding $url to the /etc/hosts file..."

sudo sed -i '1s/^/127.0.0.1       '$url'\n/' /etc/hosts
sudo a2ensite $name.conf
sudo service apache2 reload
sudo systemctl restart apache2.service
echo -e "\nYou can now browse to your Virtual Host at http://$url"

exit 0
