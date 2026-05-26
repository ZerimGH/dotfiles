#!/bin/bash

read -p "Do you want to confirm each command? (Y/n): " input

if [[ "$input" =~ ^[nN]$ ]]; then
  CONFIRM_ALL="false"
else
  CONFIRM_ALL="true"
fi

confirm_run() {
  local cmd="$*"

  echo "Command: $cmd"
  if [[ "$CONFIRM_ALL" == "false" ]]; then
    "$@"
    return
  fi
  echo "  Execute? (y/N): "
  read -r input

  case "$input" in 
    [yY][eE][sS]|[yY]) 
      "$@"
      echo -e "───────────────────────────────────────"
      ;;
    *)
      echo -e "Skipped."
      ;;
  esac
}

wait_next() {
  if [[ "$CONFIRM_ALL" == "false" ]]; then
    return
  fi
  echo "Press enter to continue..." 
  read -r input
  clear
}

clear

# Get AUR Helper
read -p "Which AUR helper? (default: yay): " input
AUR_HELPER=${input:-yay}

# Get sudo 
read -p "Which privilege escalation tool? (default: sudo): " input
SUDO=${input:-sudo}

echo "Using $AUR_HELPER for AUR packages"
echo "Using $SUDO for privilege escalation"
wait_next

# Install packages 

echo "Installing swayfx window manager..."
confirm_run $AUR_HELPER -S --needed --noconfirm swayfx # Window manager (sway with transparency support)
wait_next

echo "Installing waybar..."
confirm_run $SUDO pacman -S --needed --noconfirm waybar # Bar application 
wait_next

echo "Installing fonts..."
confirm_run $SUDO pacman -S --needed --noconfirm terminus-font # Waybar text font
confirm_run $AUR_HELPER -S --needed --noconfirm siji-ttf otf-apple-sf-mono # Waybar icons and terminal font
wait_next

echo "Installing gtk theme..."
confirm_run $SUDO pacman -S --needed --noconfirm gnome-themes-extra # Installs the adwaita-dark theme
wait_next

echo "Installing scripts and utils..."
confirm_run $SUDO pacman -S --needed --noconfirm sway-contrib swaybg # For screenshot tools
confirm_run $SUDO pacman -S --needed --noconfirm zenity # For file save dialogue with screenshot
confirm_run $SUDO pacman -S --needed --noconfirm libpulse brightnessctl playerctl # For controlling audio, brightness, music / videos
confirm_run $AUR_HELPER -S --needed --noconfirm wl-clip-persist # For persistent clipboard
confirm_run $AUR_HELPER -S --needed --noconfirm autotiling # For autotiling 
wait_next

echo "Installing environment applications..."
confirm_run $SUDO pacman -S --needed --noconfirm rofi # For running applications by name search 
confirm_run $SUDO pacman -S --needed --noconfirm swaync # For notifications
confirm_run $AUR_HELPER -S --needed --noconfirm veila-bin # For lockscreen
confirm_run systemctl --user enable swaync # Automatically start notification daemon on login 
confirm_run systemctl --user enable veilad # Automatically start lockscreen daemon on login 
wait_next

echo "Installing optional applications..."
confirm_run $SUDO pacman -S --needed --noconfirm alacritty firefox vim # General applications
confirm_run $SUDO pacman -S --needed --noconfirm ncmpcpp mpd # For playing local music
confirm_run $AUR_HELPER -S --needed --noconfirm mpDris2 mprisence # For music info in mpris and discord status
confirm_run systemctl --user enable mpd mpDris2 mprisence # Automatically start music stuff on login
wait_next

# Copy configs
echo "Copying configs..."
backup_dir=./backup$(date +"%d_%m_%y_%H_%M_%S")
echo "Backup of old configs will be at $backup_dir"
mkdir -p $backup_dir

for file in config/*; do
  target_name=$(basename "$file")
  target_dir=$HOME/.config/$target_name
  if [[ -e "$target_dir" ]]; then
    mv $target_dir $backup_dir/$target_name
    echo "Backed up $target_dir"
  fi
  confirm_run cp -r $file $target_dir
done
