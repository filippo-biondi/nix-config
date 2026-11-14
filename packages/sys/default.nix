{pkgs, ...}:
pkgs.buildGoModule {
  pname = "sys";
  version = "0.0.1";

  # Use the current directory as the source
  src = ./.;

  # This is the checksum of your Go modules.
  # Set it to lib.fakeHash or a dummy string initially.
  # When you run the build, Nix will error out and tell you the actual hash.
  vendorHash = "sha256-zZdqPkNuWs4n3LejxRPqArv+SnLKJsgasQNEkZfy0hk=";

  # We need this utility to install completions to the correct system paths
  nativeBuildInputs = [pkgs.installShellFiles pkgs.makeWrapper];

  # 1. The binary is built and placed in $out/bin/toy
  # 2. We execute that binary to generate the completion scripts
  # 3. installShellCompletion places them in $out/share/...
  postInstall = ''
    installShellCompletion --cmd sys \
      --bash <($out/bin/sys completion bash) \
      --zsh <($out/bin/sys completion zsh) \
      --fish <($out/bin/sys completion fish)
  '';

  # secrets-sync and add-host run these
  postFixup = ''
    wrapProgram $out/bin/sys --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [age-plugin-se mkpasswd sops ssh-to-age])}
  '';
}
