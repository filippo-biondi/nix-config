# 🧊 My NixOS Configuration (Flakes)

> Fully declarative, reproducible system configuration using [Nix flakes](https://nixos.wiki/wiki/Flakes).

---

## 📁 Repository Structure

```text
.
├── flake.nix
├── flake.lock
├── hosts/
│   ├── hostname1/
│   └── hostname2/
├── modules/
│   ├── darwin/
│   ├── home-manager/
│   └── nixos/
├── home/
│   ├── user1/
│   └── user2/
└── overlays/
```

- `flake.nix`: Main entry point, defines inputs, outputs, and systems.
- `hosts/`: Per-host NixOS or nix-darwin configurations.
- `home/`: Home Manager configurations for each user.
- `modules/`: Custom reusable modules divided by platform (nix-darwin, NixOS, home-manager)
- `overlays/`: Custom package overlays.
- `templates/`: Flakes templates for various purposes.

---

## 🛠️ Setup

Here are the steps to set up different systems

### Adding a new NixOS host

#### Before Installing NixOS

Prepare the flake configuration for the new host:

1. **Add the NixOS system configuration in `host/<hostname>/<main-user-name>/default.nix`**

2. **Add the secrets specification in `host/<hostname>/sops/default.nix`**

3. **Add the home-manager configuration in `home/<hostname>/<main-user-name>/default.nix`**

4. **Register the new host and the new user(s) in `host/default.nix`**

5. **Add the host to the flake's `nixosConfigurations`**

---

#### Install NixOS on the Host

Once NixOS is installed and booted:

6. **Generate SSH keys and store them in Bitwarden:**

   ```bash
   ssh-keygen -t ed25519
   ```

7. **Add the SSH key to your GitHub account:**

   ```bash
   gh ssh-key add -t <key-title> ~/.ssh/id_ed25519.pub
   ```

8. **Generate the age keys from the SSH key:**

   ```bash
   mkdir -p ~/.config/sops/age
   nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
   nix-shell -p ssh-to-age --run 'cat ~/.ssh/id_ed25519.pub | ssh-to-age'
   ```

9. **Clone your configuration repository:**

   ```bash
   cd ~/.config
   git clone git@github.com:filippo-biondi/nix-config.git
   cd nix-config
   ```

10. **Add the age public key to `.sops.yaml` and specify new creation rules:**

   ```yaml
   keys:
     - &<key-name> <key-value>
   creation_rules:
     - path_regex: secrets/<hostname>/secrets.yaml
       key_groups:
         - age: 
           - *<key-name>
   ```

11. **Create the secrets file with `sops`:**

   If you're on the host:

   ```bash
   nix-shell -p sops --run "sops secrets/<hostname>/secrets.yaml"
   ```
   If you need to edit a secret file, use:

   ```bash
   nix-shell -p sops --run "sops edit secrets/<hostname>/secrets.yaml"
   ```

   If secrets are available on a remote host:

   - First push the repo (with updated `.sops.yaml`)
   - On the remote host create the encrypted file (remember to add the age public key to `.sops.yaml`) and push it
   - On the new host pull the repo to get the encrypted secrets

   If the host need to access secrets already encrypted for another host, you need to update the encryption on the sops file with:
   
   ```bash
   sops updatekeys secrets/common.yaml
   ```
   Of course this can be performed only on the host that has access to the private key used to encrypt the file.

---

#### Test & Apply Configuration

##### Build the system:

```bash
sudo nixos-rebuild build --flake .
```

##### Test the configuration (verify secrets, SSH keys, etc.):

```bash
sudo nixos-rebuild test --flake .
```
After this step you rebooting the host will restore the previous configuration.
Remember to check that all the secrets are correctly decrypted and all the SSH keys are added.

##### Apply the configuration:

After this step the configuration can be reverted only with root privileges (be sure your password is correctly set).
```bash
sudo nixos-rebuild switch --flake .
```

---

### Adding a new nix-darwin host

#### Before Installing nix-darwin

Follow the steps [1-5](#before-installing-nixos) from the NixOS host setup section, but the host must be placed into `darwinConfigurations` in the flake.

---

#### Install nix-darwin on the Host

To install nix-darwin follow the instruction in the [nix-darwin repo](https://github.com/nix-darwin/nix-darwin).

After having install nix-darwin, follow the steps [6-11](#install-nixos-on-the-host) from the NixOS host setup section.

---

#### ✅ Test & Apply Configuration

##### 🔧 Build the system:

```bash
sudo darwin-rebuild build --flake .
```

Unfortunately I'm not aware of a way to test the configuration without applying it.

##### 🚀 Apply the configuration:

After this step the configuration can be reverted only with root privileges (be sure your password is correctly set).
```bash
sudo darwin-rebuild switch --flake .
```

---

### Adding a Home Manager configuration

#### 🛠️ Before Installing home-manager

Prepare the flake configuration for the new host:

1. **Add the home-manager configuration in `home/<hostname>/<user-name>/default.nix`**

2. **Register the new host and the new user in `host/default.nix`**

3. **Add the host and user to the flake's `homeConfigurations`**

Currently sops secrets are not supported in my home-manager config (but sops-nix provides a home-manage module)

---

#### 💽 Install Home Manager on the Host

To apply a home-manager configuration you just need to have [Nix](https://nixos.org/download/#nix-install-linux) installed on the host.
Installing Nix requires root privileges. If you don't have root access you can try to use [nix-user-chroot](https://github.com/nix-community/nix-user-chroot) or [nix-portable](https://github.com/DavHau/nix-portable)

Enable nix flakes support (flakes are still experimental):

```bash
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

Follow the steps [6-11](#install-nixos-on-the-host) from the NixOS host setup section (skipping the age keys generation and the sops secrets creation since they are not supported yet).

---

#### ✅ Test & Apply Configuration

##### 🔧 Build the configuration:

```bash
home-manager build --flake .
```

Unfortunately I'm not aware of a way to test the configuration without applying it.

##### 🚀 Apply the configuration:

```bash
home-manager switch --flake .
```
---

## 📋 TODO / Roadmap

- [ ] Refactor of modularization
- [ ] Add secrets management with sops-nix for home-manager

---

## 🧠 Inspiration

- [nix-config by AlexNabokikh](https://github.com/AlexNabokikh/nix-config)
- [NixOS WIKI](https://nixos.wiki/wiki/)

---
