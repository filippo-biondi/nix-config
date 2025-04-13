{
  userConfig,
  ...
}: {
  # System settings
  system = {
    defaults = {

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        PMPrintingExpandedStateForPrint = true;
      };

      LaunchServices = {
        LSQuarantine = false;
      };


      # trackpad = {
      #   Clicking = true;
      #   Dragging = false;
      #   TrackpadThreeFingerDrag = true;
      #   TrackpadRightClick = true;
      # };

      finder = {
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
      };

      dock = {
        autohide = true;
        show-recents = false;
        showhidden = true;
        persistent-apps = [];
      };

      screencapture = {
        location = "/Users/${userConfig.username}/Downloads/temp";
        type = "png";
        disable-shadow = true;
      };

      # controlcenter.BatteryShowPercentage = true;

      spaces.spans-displays = true;

      CustomUserPreferences = {

        # "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        #   Clicking = 0;
        #   DragLock = 0;
        #   Dragging = 0;
        #   TrackpadCornerSecondaryClick = 2;
        #   TrackpadFiveFingerPinchGesture = 2;
        #   TrackpadFourFingerHorizSwipeGesture = 2;
        #   TrackpadFourFingerPinchGesture = 2;
        #   TrackpadFourFingerVertSwipeGesture = 2;
        #   TrackpadHandResting = 1;
        #   TrackpadHorizScroll = 1;
        #   TrackpadMomentumScroll = 1;
        #   TrackpadPinch = 1;
        #   TrackpadRightClick = 1;
        #   TrackpadRotate = 1;
        #   TrackpadScroll = 1;
        #   TrackpadThreeFingerDrag = 1;
        #   TrackpadThreeFingerHorizSwipeGesture = 0;
        #   TrackpadThreeFingerTapGesture = 2;
        #   TrackpadThreeFingerVertSwipeGesture = 0;
        #   TrackpadTwoFingerDoubleTapGesture = 1;
        #   TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
        #   USBMouseStopsTrackpad = 0;
        # };

        # "com.apple.symbolichotkeys" = {
        #   AppleSymbolicHotKeys = {
        #     # Disable 'Cmd + Space' for Spotlight Search
        #     "64" = {
        #       enabled = false;
        #     };
        #   };
        # };

      };
    };
  };
}
