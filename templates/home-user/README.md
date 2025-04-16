# 🏠 Home-Manager Flake Template for Users

Welcome! This is a **Home-Manager + Flakes** template to manage your dotfiles, installed packages, shell setup, and more — all from a single config.

---

## 🚀 Getting Started

1. **Initialize your config** with this template:

   ```bash
   nix flake init --template github:filippo-biondi/nix-config#home-user
   ```

2. **Edit the `flake.nix`** file and replace `"REPLACE_ME"` with **your actual username**:

   ```nix
   username = "your-username";
   ```

3. (Optional) Customize the `home.nix` file to tweak your packages, shell, and preferences.

---

## ⚙️ Apply the Configuration

The first time you want to apply the configuration, you need to run:
```bash
nix run .#homeConfigurations.$USER.activationPackage
home-manager switch --flake .
```
After the first time you run the above command, you can simply run:
```bash
home-manager switch --flake .
```
---

## 🧠 Bonus Knowledge

- You can add files using `home.file.<target>.text` or `home.file.<target>.source`
- Add environment variables with `home.sessionVariables`
- You can search for packages on [search.nixos.org](https://search.nixos.org/packages)
- You can find more documentation about options on [mynixos.com](https://mynixos.com) (check that the option you're looking for does belong to `home-manager`)

---

## 🛠️ Troubleshooting

- Make sure you're using **Nix 2.4+**
- Enable flakes with:

  ```bash
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
  ```

- If you get errors, try running:

  ```bash
  nix flake update
  ```

---

## 🧙‍♂️ Credits

This template was crafted with ❤️ and Nix by your local dotfiles wizard.  
Ask them if anything breaks. They probably know what a `derivation` is (spoiler they don't).

---

Happy hacking! 🐧
