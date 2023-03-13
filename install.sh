#!/bin/bash
menu(){
	echo "

**********************************************
	Pick an option:
	1- Install NodeJS
	2- Install Java-11
	
	3- Add Wordpress(XAMPP is required)
	4- Fix issue install/update wordpress pluging
	
	5- Show REACT NATIVE Setup
	6- Show some tips	
	7- Add Android Path files

	8- Generate github SSH key

**********************************************
	"

	read option

	case $option in
		1)
			sudo pacman -Syu nodejs npm
			menu
			;;
			
		2)
			sudo pacman -S jre11-openjdk-headless
			menu
			;;
		
		3)	
			#ADD WORDPRESS
			#check if dir exist
			WORDPRESS_DIR="/opt/lampp/htdocs/wordpress/"
			if [ -d $WORDPRESS_DIR ]; then
				echo '✅ Wordpress already exists'
			else
				echo '✅ Adding Wordpress to /opt/lampp/htdocs...' ; 
				sudo cp -a src/wordpress /opt/lampp/htdocs
				
				echo '✅ Adding CRUD permissions to wordpress dir'
				sudo chmod -R 777 /opt/lampp/htdocs/wordpress
			fi			
			menu
			;;
			
		4)
			#FIX THE ISSUE FOR INSTALLING AND UPDATING WORDPRESS PLUGINS
			TEXT_TO_FILE="define( 'FS_METHOD', 'direct' );"
			FILE="/opt/lampp/htdocs/wordpress/wp-config.php"
			
			#check if file exist
			if [ -f $FILE ]; then
				echo 'Checking file wp-config.php...'
				
				#Check if the paths already added
				if  grep -q "$TEXT_TO_FILE" "$FILE"; then
						echo '✅ line to fix install and update plugings already added' ; 
						menu
				else
					echo '✅ Adding line to fix install and update plugings...' ; 
					echo -e $TEXT_TO_FILE >> $FILE
					menu
				fi
			else 
				echo "❌ You have't setup your wordpress yet"	
			fi
			menu
			;;
		
		5)
			#SHOW THE REACT NATIVE SETUP
			printf '\nREACT NATIVE Setup
https://reactnative.dev/docs/0.60/enviroment-setup

* Install AndroidStudio from software center.
				
* INSTALL additional SDK and Android dev package
* Android SDK Platform 31
* Intel x86 Atom_64 System Image
* Google APIs Intel x86 Atom System Image
* Google Play Intel x86 Atom System Image
					
* OPEN the android VIRTUAL DEVICE MANAGER to the setup the emulator
*Choose a device and install the required API
*Launch the emulator to make sure this works as expected'
			
			menu
			;;
		
		6)
			#GIVE PERMISSIONS TO GRADLEs
			echo "Is recomended to give permissions to GRADLEs in your project"
			echo 'sudo chmod 755 android/gradlew'
			menu
			;; 
		
		7)
			#ADD ANDROID DEV PATHS
			FILE="/home/$USER/.bash_profile"
			echo "FILE LOCATION: $FILE"

			echo "FILE CONTENT:"
			cat $FILE

			if ! grep -q 'ANDROID_HOME' "$FILE"; then
				echo '✅ Adding android paths...'
				echo -e 'export PATH=$PATH:$ANDROID_HOME/emulator' >> "$FILE"
				echo -e 'export PATH=$PATH:$ANDROID_HOME/tools' >> "$FILE"
				echo -e 'export PATH=$PATH:$ANDROID_HOME/tools/bin' >> "$FILE"
				echo -e 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> "$FILE"
			else
				echo '✅ Android paths already added'
			fi

			echo 'You need to restart your pc in order to finish the ANDROID_HOME setup. Restart now? (y/n)'
			read ANSWER
			ANSWER=$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]')
			
			if [ "$ANSWER" = "y" || "$ANSWER" = "yes"]; then
				sudo systemctl reboot
				menu	
			else
				menu
			fi
			menu
			;;
			
		8)
			printf 'What is your github email? '
read EMAIL
printf 'What is your github username? '
read USERNAME

ssh-keygen -t ed25519 -C "$EMAIL"
printf '\nYour SSH key is 👇: \n'
cat /home/$USER/.ssh/id_ed25519.pub

printf "\nWanna add to global, this github email and username? (y/n): "
read ANSWER
ANSWER=$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]')

if [ "$ANSWER" = "y" || "$ANSWER" = "yes"]; then
    git config --global user.email "$EMAIL"
    git config --global user.username "$USERNAME"
		printf "\nNice!. Your email and username where added to global"
    menu    
else
		printf "\n❌ your anwer was $ANSWER, so the email and password you entered was not added"
    menu
fi

			;;
			test)

			menu
			;;		
		
		e)
			exit 1
			;;
		*)
		    echo "Wrong option: $option"
		    menu
		    ;;
	esac
	
}


menu
