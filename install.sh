#!/usr/bin/env bash
set -uo pipefail

append_if_missing() {
  # usage: append_if_missing "file" "line to append"
  local file="$1"
  local line="$2"
  if [ ! -f "$file" ]; then
    touch "$file"
  fi
  if ! grep -Fxq "$line" "$file"; then
    printf '%s\n' "$line" >> "$file"
    return 0
  fi
  return 1
}

menu(){
  cat <<'EOF'

**********************************************
  Pick an option:
  1- Install NodeJS on ArchLinux dists
  2- Install Java-11 on ArchLinux dists

  3- Add Wordpress (XAMPP is required)
  4- Fix issue install/update wordpress plugin(s)

  5- Show REACT NATIVE Setup
  6- Show some tips
  7- Add Android Path files to ~/.bashrc

  8- Generate github SSH key

  9- Fix Wordpress/Git permissions for development

  10- Install NodeJS for Ubuntu/Debian dists
  11- Install Java-11 for Ubuntu/Debian dists

  e- Exit
**********************************************

EOF

  read -rp "Option: " option

  case $option in
    1)
      sudo pacman -Syu --noconfirm nodejs npm
      ;;
    2)
      sudo pacman -S --noconfirm jre11-openjdk-headless
      ;;
    3)
      # ADD WORDPRESS
      WORDPRESS_SRC="./src/wordpress"
      WORDPRESS_DIR="/opt/lampp/htdocs/wordpress"
      if [ -d "$WORDPRESS_DIR" ]; then
        echo '✅ Wordpress already exists'
      else
        if [ -d "$WORDPRESS_SRC" ]; then
          echo '✅ Adding Wordpress to /opt/lampp/htdocs...'
          sudo cp -a "$WORDPRESS_SRC" /opt/lampp/htdocs/
          # It's safer to chown to apache/www-data/daemon depending XAMPP distro.
          echo "You may want to chown to the webserver user (e.g. daemon/www-data)."
          echo "Example: sudo chown -R daemon:daemon $WORDPRESS_DIR"
          # If you must, uncomment next line (not recommended long-term):
          # sudo chmod -R 775 "$WORDPRESS_DIR"
        else
          echo "❌ Source folder $WORDPRESS_SRC not found. Place your wordpress files there."
        fi
      fi
      ;;
    4)
      # FIX THE ISSUE FOR INSTALLING AND UPDATING WORDPRESS PLUGINS
      TEXT_TO_FILE="define( 'FS_METHOD', 'direct' );"
      FILE="/opt/lampp/htdocs/wordpress/wp-config.php"

      if [ -f "$FILE" ]; then
        echo 'Checking file wp-config.php...'
        if grep -Fq "$TEXT_TO_FILE" "$FILE"; then
          echo '✅ line to fix install and update plugins already added'
        else
          echo '✅ Adding line to fix install and update plugins...'
          printf '%s\n' "$TEXT_TO_FILE" | sudo tee -a "$FILE" >/dev/null
        fi
      else
        echo "❌ You haven't setup your wordpress yet (wp-config.php not found in /opt/lampp/htdocs/wordpress)."
      fi
      ;;
    5)
      cat <<'RN'

REACT NATIVE Setup
https://reactnative.dev/docs/environment-setup

* Install Android Studio from software center.
* INSTALL additional SDK and Android dev package:
  - Android SDK Platform (recommended API e.g. 31 or latest stable)
  - Intel x86 Atom_64 System Image (or ARM images if needed)
  - Google APIs / Google Play system images as required

* OPEN the Android VIRTUAL DEVICE MANAGER and setup emulator
* Choose a device and install the required API
* Launch the emulator to make sure this works as expected

RN
      ;;
    6)
      echo "Tips:"
      echo "- Give executable permission to gradlew: sudo chmod +x android/gradlew"
      echo "- If adb not found: ensure \$ANDROID_HOME/platform-tools is in PATH and run: adb version"
      ;;
    7)
      # ADD ANDROID DEV PATHS (to ~/.bashrc)
      TARGET="$HOME/.bashrc"
      echo "FILE LOCATION: $TARGET"
      echo "Current content preview (last 15 lines):"
      tail -n 15 "$TARGET" 2>/dev/null || true

      ANDROID_LINE="export ANDROID_HOME=\$HOME/Android/Sdk"
      PATH_LINE='export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin'

      appended=0
      if append_if_missing "$TARGET" "$ANDROID_LINE"; then
        echo "✅ ANDROID_HOME added to $TARGET"
        appended=1
      else
        echo "✅ ANDROID_HOME already present in $TARGET"
      fi

      if append_if_missing "$TARGET" "$PATH_LINE"; then
        echo "✅ Android PATH added to $TARGET"
        appended=1
      else
        echo "✅ Android PATH already present in $TARGET"
      fi

      if [ $appended -eq 1 ]; then
        echo "Reloading $TARGET..."
        # shellcheck disable=SC1090
        source "$TARGET"
      fi

      echo 'You may need to open a new terminal session for PATH to take effect.'
      ;;
    8)
      read -rp 'What is your github email? ' EMAIL
      read -rp 'What is your github username? ' USERNAME

      ssh-keygen -t ed25519 -C "$EMAIL"
      echo
      echo 'Your SSH public key:'
      cat "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || echo "(no key found)"

      read -rp "Wanna add to global, this github email and username? (y/n): " ANSWER
      ANSWER="${ANSWER,,}"
      if [ "$ANSWER" = "y" ] || [ "$ANSWER" = "yes" ]; then
        git config --global user.email "$EMAIL"
        git config --global user.name "$USERNAME"
        echo "Nice!. Your email and username were added to git global config"
      else
        echo "Skipped adding git global config"
      fi
      ;;
        9)
      WORDPRESS_DIR="/opt/lampp/htdocs/wordpress"
      THEMES_DIR="$WORDPRESS_DIR/wp-content/themes"
      PLUGINS_DIR="$WORDPRESS_DIR/wp-content/plugins"
      CURRENT_USER="$(whoami)"

      if [ ! -d "$WORDPRESS_DIR" ]; then
        echo "❌ Wordpress not found in $WORDPRESS_DIR"
      else
        echo "Configuring Wordpress for development..."

        sudo chown -R "$CURRENT_USER:$CURRENT_USER" "$WORDPRESS_DIR"

        sudo find "$WORDPRESS_DIR" -type d -exec chmod 755 {} \;
        sudo find "$WORDPRESS_DIR" -type f -exec chmod 644 {} \;

        if [ -f "$WORDPRESS_DIR/wp-config.php" ]; then
          sudo chmod 664 "$WORDPRESS_DIR/wp-config.php"
        fi

        echo
        echo "✅ Permissions fixed"
        echo "Owner: $CURRENT_USER"
        echo "Themes directory:"
        ls -ld "$THEMES_DIR" 2>/dev/null

        echo
        echo "Testing GitHub SSH..."
        ssh -T git@github.com || true

        echo
        echo "You should now be able to:"
        echo "  cd $THEMES_DIR"
        echo "  git clone git@github.com:AlexRayo/your-theme.git"
      fi
      ;;
    10)
      echo "Instalando Node.js en tu distribución Debian/Ubuntu..."
      sudo apt-get update -y
      sudo apt-get install -y curl
      curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
      sudo apt-get install -y nodejs
      echo "Node.js instalado correctamente."
      ;;
    11)
      echo "Instalando Java 11 (OpenJDK) en Linux Mint / Debian..."
      sudo apt update -y
      sudo apt install -y openjdk-11-jdk
      java -version || true
      echo "Java 11 instalado correctamente."
      ;;
    e|E)
      echo "Bye."
      exit 0
      ;;
    *)
      echo "Wrong option: $option"
      ;;
  esac

  # show menu again
  menu
}

menu

