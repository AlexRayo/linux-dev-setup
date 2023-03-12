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
	6- Give gradles access(AndroidStudio is required)	
	7- Add Android Path files

	8- Generate github SSH key

**********************************************
	"

	read option

	case $option in
		1)
			sudo pacman -S nodejs npm
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
			echo "
				REACT NATIVE Setup
	
				* Install AndroidStudio from software center.
				
				* INSTALL additional SDK and Android dev package
					* Android SDK Platform 31
					* Intel x86 Atom_64 System Image
					* Google APIs Intel x86 Atom System Image
					* Google Play Intel x86 Atom System Image
					
				* OPEN the android VIRTUAL DEVICE MANAGER to the setup the emulator
					*Choose a device and install the required API
					*Launch the emulator to make sure this works as expected
			"
			menu
			;;
		
		6)
			#GIVE PERMISSIONS TO GRADLEs
			echo "✅ Giving permissions to GRADLEs"
			sudo chmod 755 android/gradlew
			menu
			;; 
		
		7)
			#ADD ANDROID DEV PATHS
			FILE="/home/$USER/.bash_profile"
			echo "FILE LOCATION: $FILE"

			echo "FILE CONTENT:"
			cat $FILE

			TEXT_TO_FILE='export ANDROID_HOME=$HOME/Android/Sdk export PATH=$PATH:$ANDROID_HOME/emulator export PATH=$PATH:$ANDROID_HOME/platform-tools'

			if ! grep -qxF "$TEXT_TO_FILE" "$FILE"; then
				echo '✅ Adding android paths...'
				echo -e "$TEXT_TO_FILE" >> "$FILE"
			else
				echo '✅ Android paths already added'
			fi

			menu
			;;
			
		8)
			echo 'What is your github email?'
				read EMAIL
			echo 'What is your github username?'
				read USERNAME					

			ssh-keygen -t ed25519 -C "$EMAIL"
			echo 'Your SSH key is 👇:'
			cat /home/$USER/.ssh/id_ed25519.pub

			echo "Wanna add to global, github email: $EMAIL and username: $USERNAME? (y/n)"
			read ANSWER
			
			if [$ANSWER == "yes" || $ANSWER ==  "y" || $ANSWER ==  "Y"]; then
				git config --global user.email "$EMAIL"
				git config --global user.username "$USERNAME"
				menu	
			else
				menu
			fi
			#eval "$(ssh-agent -s)"
			#ssh-add ~/.ssh/id_ed25519
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
