#!/bin/zsh
# ==============================================================================
# MacTech System Triage & Targeted Daemon Fixes Module
# ==============================================================================

fix_google_keystone() {
  section "Triagem: Google Keystone Daemons (Job Missing Label Fix)"
  echo "• Descarregando e higienizando LaunchAgents obsoletos do Google Keystone..."
  sudo launchctl bootout system /Library/LaunchAgents/com.google.keystone.agent.plist 2>/dev/null || true
  sudo launchctl bootout system /Library/LaunchAgents/com.google.keystone.xpcservice.plist 2>/dev/null || true
  sudo rm -f /Library/LaunchAgents/com.google.keystone.* 2>/dev/null || true
  rm -f "$HOME/Library/LaunchAgents/com.google.keystone."* 2>/dev/null || true
  log_success "Resíduos do Google Keystone removidos com sucesso."
}

fix_messages_daemons() {
  section "Triagem: Daemons do Messages / iCloud (imagent / identityservicesd)"
  echo "• Reiniciando subsistema de mensageria e autenticação iCloud..."
  killall imagent identityservicesd messagesd 2>/dev/null || true
  local uid=$(id -u)
  launchctl kickstart -k "gui/${uid}/com.apple.imagent" 2>/dev/null || true
  launchctl kickstart -k "gui/${uid}/com.apple.identityservicesd" 2>/dev/null || true
  launchctl kickstart -k "gui/${uid}/com.apple.messagesd" 2>/dev/null || true
  log_success "Daemons do Messages reiniciados."
}

fix_photos_tcc_daemons() {
  section "Triagem: Daemons do Photos / TCC Permissions (photolibraryd)"
  echo "• Reiniciando serviços de análise e sincronização de fotos..."
  killall photolibraryd photoanalysisd mediaanalysisd mstreamd cloudphotosd iCloudNotificationAgent assetsd 2>/dev/null || true
  local uid=$(id -u)
  launchctl kickstart -k "gui/${uid}/com.apple.photolibraryd" 2>/dev/null || true
  launchctl kickstart -k "gui/${uid}/com.apple.photoanalysisd" 2>/dev/null || true
  
  echo "• Resetando permissões TCC do Photos..."
  tccutil reset Photos 2>/dev/null || true
  log_success "Serviços do Photos e permissões TCC redefinidos."
}

fix_gatekeeper_cache() {
  section "Triagem: Reset do Cache do Gatekeeper (Erro -67018)"
  echo "• Redefinindo regras padrão do Gatekeeper..."
  sudo spctl --reset-default 2>/dev/null || true
  log_success "Gatekeeper restaurado para o perfil padrão seguro."
}

fix_home_permissions_safe() {
  section "Reparação Segura de Permissões da Pasta Home ($HOME)"
  echo "• Corrigindo propriedade de arquivos para ${USER}:staff..."
  sudo chown -R "${USER}:staff" "$HOME" 2>/dev/null || true
  echo "• Removendo permissões perigosas de escrita global (o-w)..."
  chmod -R o-w "$HOME" 2>/dev/null || true
  log_success "Permissões de ${HOME} normalizadas."
}

fix_zshrc_early_exit() {
  section "Sanitização de Shell: Early Exit no .zshrc para IDEs"
  local zshrc="$HOME/.zshrc"
  local backup="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
  
  if [[ -f "$zshrc" ]]; then
    if ! grep -q "Antigravity IDE Fix" "$zshrc"; then
      echo "• Criando backup em $backup..."
      cp "$zshrc" "$backup"
      echo "• Inserindo verificação de shell interativo no topo de $zshrc..."
      sed -i '' '1i\
# --- Antigravity IDE Fix (Start) ---\
[[ $- != *i* ]] && return\
# --- Antigravity IDE Fix (End) ---\
' "$zshrc"
      log_success "Early Exit inserido no .zshrc."
    else
      echo "Regra de Early Exit já presente no .zshrc. Nenhuma alteração necessária."
    fi
  fi
}

apply_ui_speed_tweaks() {
  section "Ajustes de Velocidade e Resposta de Interface (Finder / Dock)"
  echo "• Aplicando redução de tempo de animações de janelas e Dock..."
  defaults write -g NSWindowResizeTime -float 0.001 2>/dev/null || true
  defaults write com.apple.dock autohide-time-modifier -float 0.20 2>/dev/null || true
  defaults write com.apple.dock autohide-delay -float 0 2>/dev/null || true
  defaults write com.apple.dock expose-animation-duration -float 0.1 2>/dev/null || true
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE 2>/dev/null || true
  
  killall Dock 2>/dev/null || true
  killall Finder 2>/dev/null || true
  log_success "Ajustes de UI aplicados."
}
