{ ... }: {
  home.file."Library/KeyBindings/DefaultKeyBinding.Dict" = {
    text = ''
      {
      "\UF729"   = (moveToBeginningOfLine:);                       /* Home         */
      "@\UF729"  = (moveToBeginningOfDocument:);                   /* Cmd  + Home  */
      "$\UF729"  = (moveToBeginningOfLineAndModifySelection:);     /* Shift + Home */
      "$@\UF729" = (moveToBeginningOfDocumentAndModifySelection:); /* Shift + Cmd  + Home */
      "\UF72B"   = (moveToEndOfLine:);                             /* End          */
      "@\UF72B"  = (moveToEndOfDocument:);                         /* Cmd  + End   */
      "$\UF72B"  = (moveToEndOfLineAndModifySelection:);           /* Shift + End  */
      "$@\UF72B" = (moveToEndOfDocumentAndModifySelection:);       /* Shift + Cmd  + End */

      "^\UF702"   = (moveToBeginningOfLine:);                       /* Home         */
      "^\UF703"   = (moveToEndOfLine:);                             /* End          */
      "$^\UF703"  = (moveToEndOfLineAndModifySelection:);           /* Shift + End  */
      "$^\UF702"  = (moveToBeginningOfLineAndModifySelection:);     /* Shift + Home */

      "\UF72C"   = (pageUp:);                                      /* PageUp       */
      "\UF72D"   = (pageDown:);                                    /* PageDown     */
      "@x"  = (cut:);                                         /* Shift + Del  */
      "@v"  = (paste:);                                       /* Shift + Help */
      "@c"  = (copy:);                                        /* Cmd  + Help (Ins) */
      "@\UF702"  = (moveWordBackward:);                            /* Cmd  + LeftArrow */
      "@\UF703"  = (moveWordForward:);                             /* Cmd  + RightArrow */
      "$@\UF702" = (moveWordBackwardAndModifySelection:);   /* Shift + Cmd  + Leftarrow */
      "$@\UF703" = (moveWordForwardAndModifySelection:);   /* Shift + Cmd  + Rightarrow */
      }
    '';
  };
}
