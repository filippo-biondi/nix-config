# My NixOS Configuration (Flakes)

> Fully declarative, reproducible system configuration using [Nix flakes](https://nixos.wiki/wiki/Flakes)
to configure multiple host with multiple users.

---

## Repository Structure
The repository structure can be a bit daunting at first,
but it is designed to provide modular and reusable features across different users and hosts
(supporting NixOS, nix-darwin and home-manager).

The following is a high-level overview of the structure:

```text
.
├── config/
│   ├── darwin/
│   ├── home-manager/
│   └── nixos/
├── features/
│   ├── category1/
│   │   ├── feature1/
│   │   ├── feature2/
│   │   └── default.nix
│   └── category2/
├── hosts/
│   ├── hostname1/
│   │   ├── home/
│   │   │   ├── user1/
│   │   │   └── user2/
│   │   ├── sops/
│   │   └── default.nix
│   ├── hostname2/
│   └── default.nix
├── overlays/
├── secrets/
├── templates/
├── utils/
├── flake.lock
└── flake.nix
```

- `config/`: Contains the common configuration files for NixOS, nix-darwin, and home-manager. 
           These settings should be shared across all hosts.
- `features/`: Contains reusable features organized by category. 
             Each feature can be available for NixOS, nix-darwin, and home-manager (not all features are available for all platforms).
             Including a feature in a host configuration will automatically select the correct implementation 
- `hosts/`: Contains the configuration for each host. 
          The `default.nix` file in the `host/` directory defines the hosts and their users.
          Each host, in addition to its own configuration, can also include a `home/` directory,
          which contains home-manager configurations for one or more users,
          and a `sops/` directory for secrets management.
- `overlays/`: Custom package overlays that can be used in the features.
- `secrets/`: Contains the secrets files encrypted with sops.
- `templates/`: Contains templates for various purposes (yet to extend).
- `utils/`: Here is where the dirty work is done. 
          Contains the functions that are used to generate the configurations to keep the `flake.nix` small.
- `flake.nix`: Main entry point, defines inputs, outputs, and systems.

---

## Setup

Here are the steps to set up different systems

<details>

<summary>NixOS</summary>

### Before Installing NixOS

Prepare the flake configuration for the new host:

1. **Add the NixOS system configuration in `hosts/<hostname>/default.nix`**

2. **Add the secrets specification in `hosts/<hostname>/sops/default.nix` and add the encrypted secrets in the `secrets/` folder**

3. **Add the home-manager configuration in `hosts/<hostname>/home/<user>/default.nix`**

4. **Register the new host and the new user(s) in `host/default.nix`**

5. **Add the host to the flake's `nixosConfigurations`**

---

### Setup Keys and Secrets

Once NixOS is installed and booted:

6. **Generate SSH keys**

   ```bash
   ssh-keygen -t ed25519
   ```

7. **Add the SSH key to your GitHub account:**

   ```bash
   nix-shell -p gh --run "ssh-key add -t <key-title> ~/.ssh/id_ed25519.pub"
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

### Test & Apply Configuration

#### Build the system:

```bash
sudo nixos-rebuild build --flake .
```

#### Test the configuration:

```bash
sudo nixos-rebuild test --flake .
```
After this step you rebooting the host will restore the previous configuration.
Remember to check that all the secrets are correctly decrypted and all the SSH keys are added.

#### Apply the configuration:

After this step the configuration can be reverted only with root privileges (be sure your password is correctly set).
```bash
sudo nixos-rebuild switch --flake .
```
</details>

<details>

<summary>Nix Darwin</summary>

### Before Installing nix-darwin

Follow the steps [1-5](#before-installing-nixos) from the NixOS host setup section, but the host must be placed into `darwinConfigurations` in the flake.

---

### Install nix-darwin on the Host

To install nix-darwin follow the instruction in the [nix-darwin repo](https://github.com/nix-darwin/nix-darwin).

After having install nix-darwin, follow the steps [6-11](#setup-keys-and-secrets) from the NixOS host setup section.

---

### Test & Apply Configuration

#### Build the system:

```bash
sudo darwin-rebuild build --flake .
```


#### Test the configuration:
Unfortunately I'm not aware of a way to test the configuration without applying it.

#### Apply the configuration:

After this step the configuration can be reverted only with root privileges (be sure your password is correctly set).
```bash
sudo darwin-rebuild switch --flake .
```

</details>

<details>
<summary>Home Manager</summary>

### Before Installing home-manager

Prepare the flake configuration for the new host:

1. **Add the home-manager configuration in `hosts/<hostname>/home/<user-name>/default.nix`**

2. **Register the new host and the new user in `host/default.nix`**

3. **Add the host and user to the flake's `homeConfigurations`**

Currently sops secrets are not supported in my home-manager config (but sops-nix provides a home-manage module).
Keep in mind that home-manager standalone is primarly intended for use on a host where root privileges are not held by the user 
and thus installing secrets on those hosts can lead to security issues.

---

### Install Home Manager on the Host

To apply a home-manager configuration you just need to have [Nix](https://nixos.org/download/#nix-install-linux) installed on the host.
Installing Nix requires root privileges. If you don't have root access you can try to use [nix-user-chroot](https://github.com/nix-community/nix-user-chroot) or [nix-portable](https://github.com/DavHau/nix-portable)

Enable nix flakes support (flakes are still experimental):

```bash
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

---

### Test & Apply Configuration

The first time you want to apply the configuration you need to run the following command:
```bash
nix run .#homeConfigurations.$USER.activationPackage
```

#### Build the configuration:

```bash
home-manager build --flake .
```

#### Test the configuration:
Unfortunately I'm not aware of a way to test the configuration without applying it.

####  Apply the configuration:

```bash
home-manager switch --flake .
```

</details>

---

## TODO / Roadmap

- [x] Refactoring of modularization
- [ ] Configure all macOS setting with nix-darwin
- [ ] Create a setup script to automate the installation on new hosts

---

## Inspiration

- [nix-config by AlexNabokikh](https://github.com/AlexNabokikh/nix-config)
- [NixOS WIKI](https://nixos.wiki/wiki/)

---
