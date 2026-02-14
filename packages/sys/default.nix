{
  writeShellScriptBin,
  nixos-rebuild,
  openssh,
  ssh-to-age,
  sops,
  git,
  ...
}:
writeShellScriptBin "sys" ''
  set -e

  # --- Helpers ---
  log() { echo -e "\033[1;34m:: $1\033[0m"; }
  warn() { echo -e "\033[1;33m:: $1\033[0m"; }
  confirm() {
      read -p "$1 [y/N] " response
      case "$response" in
          [yY][eE][sS]|[yY]) return 0 ;;
          *) return 1 ;;
      esac
  }

  # --- Commands ---

  cmd_rebuild() {
      if [[ "$OSTYPE" == "linux"* ]]; then
          echo "🔨 Rebuilding NixOS configuration..."
          sudo nixos-rebuild switch --flake .#
      elif [[ "$OSTYPE" == "darwin"* ]]; then
          echo "🍎 Rebuilding Darwin configuration..."
          darwin-rebuild switch --flake .#
      else
          echo "❌ Unsupported OS: $OSTYPE"
          exit 1
      fi
  }

  cmd_test() {
       if [[ "$OSTYPE" == "linux"* ]]; then
          echo "🏗️ Testing NixOS configuration..."
          sudo nixos-rebuild test --flake .#
      elif [[ "$OSTYPE" == "darwin"* ]]; then
          echo "🍎 Checking Darwin configuration..."
          darwin-rebuild check --flake .#
      fi
  }

  cmd_update() {
      echo "🔒 Updating flake.lock..."
      nix flake update
  }

  cmd_clean() {
      echo "🗑️ Cleaning and optimizing the Nix store..."
      nix store optimise --verbose
      nix store gc --verbose
  }

  cmd_deploy() {
      HOST="$1"
      USER="''${2:-filippo}"

      if [ -z "$HOST" ]; then
          echo "Usage: sys deploy <hostname> [user]"
          exit 1
      fi

      TARGET="$USER@$HOST"
      echo "🚀 Deploying flake .#$HOST to $TARGET..."

      # We use nixos-rebuild for remote deployment even from Darwin
      ${nixos-rebuild}/bin/nixos-rebuild switch \
        --flake ".#$HOST" \
        --target-host "$TARGET" \
        --use-remote-sudo \
        --ask-sudo-password
  }

  cmd_add_host() {
      # 1. Inputs
      HOST_NAME="$1"
      TARGET_HOST="$2"

      if [ -z "$HOST_NAME" ]; then
          read -p "Enter Hostname (e.g. server-new): " HOST_NAME
      fi

      if [ -z "$TARGET_HOST" ]; then
          read -p "Enter Target Host (e.g. root@192.168.1.100): " TARGET_HOST
      fi

      read -p "Target System Architecture [x86_64-linux]: " TARGET_ARCH
      TARGET_ARCH=''${TARGET_ARCH:-x86_64-linux}

      FLAKE_URI=".#$HOST_NAME"
      HW_CONFIG_PATH="./systems/$TARGET_ARCH/$HOST_NAME/hardware-configuration.nix"

      # 2. Key Generation
      TEMP_DIR=$(mktemp -d)
      trap "rm -rf $TEMP_DIR" EXIT

      KEY_DIR="$TEMP_DIR/etc/ssh"
      mkdir -p "$KEY_DIR"
      KEY_PATH="$KEY_DIR/ssh_host_ed25519_key"

      log "Generating SSH keys in temporary directory..."
      ${openssh}/bin/ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "root@$HOST_NAME"

      log "Generating Age key..."
      AGE_KEY=$(${ssh-to-age}/bin/ssh-to-age -i "$KEY_PATH.pub")
      log "Age Public Key: $AGE_KEY"

      # 3. SOPS Configuration
      SOPS_FILE="secrets/.sops.yaml"

      if [ ! -f "$SOPS_FILE" ]; then
          echo "Error: $SOPS_FILE not found. Are you in the flake root?"
          exit 1
      fi

      log "Preparing to edit $SOPS_FILE..."
      echo "" >> "$SOPS_FILE"
      echo "# New key for $HOST_NAME (Uncomment and rename anchor as needed):" >> "$SOPS_FILE"
      echo "# - &$HOST_NAME $AGE_KEY" >> "$SOPS_FILE"

      echo "I have appended the new key to the bottom of $SOPS_FILE."
      echo "Please:"
      echo "1. Define the anchor name (e.g. &$HOST_NAME)."
      echo "2. Add the anchor to the relevant creation_rules."
      echo "Press Enter to open your editor (''${EDITOR:-nano})..."
      read

      ''${EDITOR:-nano} "$SOPS_FILE"

      # 4. Update Secrets
      log "Updating secrets..."
      SECRETS=$(find secrets -name "*.yaml" -not -name ".sops.yaml")

      for secret in $SECRETS; do
          log "Updating keys for $secret..."
          ${sops}/bin/sops updatekeys "$secret"
      done

      # 5. Git Operations (Secrets)
      log "Checking git status in secrets/..."
      pushd secrets > /dev/null
      ${git}/bin/git status
      if confirm "Commit and push changes to secrets submodule?"; then
          ${git}/bin/git add .
          ${git}/bin/git commit -m "feat: add secrets for $HOST_NAME"
          ${git}/bin/git push
      fi
      popd > /dev/null

      # 6. Provisioning
      HW_CONFIG_DIR=$(dirname "$HW_CONFIG_PATH")
      if [ ! -d "$HW_CONFIG_DIR" ]; then
          if confirm "Directory $HW_CONFIG_DIR does not exist. Create it?"; then
              mkdir -p "$HW_CONFIG_DIR"
          else
              warn "Skipping directory creation."
          fi
      fi

      log "Ready to provision $HOST_NAME on $TARGET_HOST."

      if confirm "Run nixos-anywhere now?"; then
          nix run github:nix-community/nixos-anywhere -- \
              --generate-hardware-config nixos-generate-config "$HW_CONFIG_PATH" \
              --flake "$FLAKE_URI" \
              --target-host "$TARGET_HOST" \
              --extra-files "$TEMP_DIR"
      fi

      log "Done."
  }

  cmd_usage() {
      cat <<-_EOF
  Usage:
      sys rebuild
          Rebuild the system (auto-detects OS).
      sys test
          Test configuration (NixOS test / Darwin check).
      sys update [input]
          Update flake inputs.
      sys clean
          Garbage collect and optimise Nix Store.
      sys deploy <host> [user]
          Deploy to a remote NixOS host.
      sys add-host [host] [target]
          Interactive script to bootstrap a new host (keys, secrets, provisioning).
      sys help
          Show this text.
  _EOF
  }

  # --- Main ---

  PROGRAM=sys
  COMMAND="$1"
  case "$1" in
      rebuild|r) shift;       cmd_rebuild ;;
      test|t)    shift;       cmd_test ;;
      update|u)  shift;       cmd_update "$@" ;;
      clean|c)   shift;       cmd_clean ;;
      deploy|d)  shift;       cmd_deploy "$@" ;;
      add-host)  shift;       cmd_add_host "$@" ;;
      help|--help) shift;     cmd_usage "$@" ;;
      *)
          if [ -z "$1" ]; then
              cmd_usage
          else
              echo "Unknown command: $1"
              cmd_usage
          fi
          ;;
  esac
  exit 0
''
