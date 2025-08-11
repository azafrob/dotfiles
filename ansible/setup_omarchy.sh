#!/bin/bash

set -e

# Install Ansible if needed
if ! command -v ansible-playbook &>/dev/null; then
  echo "Installing Ansible..."
  sudo pacman -S --needed --noconfirm ansible
fi

# Run the playbook
echo "Installing ansible requirements"
ansible-galaxy collection install -r ~/dotfiles/ansible/requirements.yml

# Run the playbook
echo "Running setup playbook..."
ansible-playbook ~/dotfiles/ansible/setup_omarchy.yml --ask-become-pass

echo "Setup complete! Please reboot."
