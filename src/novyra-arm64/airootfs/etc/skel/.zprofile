# On first TTY login, offer to install the desktop shell (ambxst)
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ] && ! command -v ambxst >/dev/null 2>&1; then
  STAMP="$HOME/.local/state/novyra/.setup-apps-run"
  if [ ! -e "$STAMP" ]; then
    mkdir -p "${STAMP%/*}"
    : > "$STAMP"
    if [ -x /usr/local/bin/novyra-setup-apps ]; then
      /usr/local/bin/novyra-setup-apps
    fi
  fi
  exec zsh
fi
