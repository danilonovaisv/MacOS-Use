sudo pkill -f Wacom; sudo pkill -f Tablet; sudo pkill -f PenTablet; sudo pkill -f ConsumerTouch; \
sudo rm -rf /Applications/Wacom\ Tablet/ /Applications/Wacom\ Center.app /Applications/Wacom\ Desktop\ Center.app 2>/dev/null; \
sudo rm -rf /Library/Frameworks/WacomMultiTouch.framework /Library/Frameworks/Wacom.framework 2>/dev/null; \
sudo rm -rf /Library/Application\ Support/Tablet/ /Library/Application\ Support/Wacom/ 2>/dev/null; \
sudo rm -f /Library/LaunchAgents/com.wacom.* /Library/LaunchDaemons/com.wacom.*; \
sudo rm -rf /Library/PreferencePanes/WacomTablet.prefpane /Library/PreferencePanes/WacomCenter.prefpane; \
sudo rm -rf /Library/Preferences/Tablet/; \
sudo rm -f /Library/Preferences/com.wacom.* /Library/Preferences/com.tablet.*; \
sudo rm -f /Library/PrivilegedHelperTools/com.wacom.*; \
sudo rm -f /Library/Receipts/com.wacom.* /Library/Receipts/Wacom*.pkg; \
sudo rm -rf /Library/Caches/com.wacom.* /System/Library/Extensions/TabletDriver.kext /Library/Extensions/TabletDriver.kext /Library/StartupItems/TabletStartup 2>/dev/null; \
sudo rm -f /Library/LaunchDaemons/com.wacom.DataStoreManager.plist /Library/LaunchAgents/com.wacom.DataStoreManager.plist 2>/dev/null; \
rm -rf ~/Library/Preferences/com.wacom.* ~/Library/Preferences/com.tablet.* ~/Library/Preferences/Tablet/; \
rm -rf ~/Library/Caches/com.wacom.* ~/Library/Caches/Wacom/; \
rm -rf ~/Library/Containers/com.wacom.* ~/Library/Group\ Containers/com.wacom.*; \
rm -rf ~/Library/Application\ Support/Wacom/ ~/Library/Application\ Support/Tablet/ 2>/dev/null; \
rm -f ~/Library/Receipts/com.wacom.*; \
sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "DELETE FROM access WHERE client LIKE '%wacom%' OR client LIKE '%Wacom%' OR client LIKE '%Tablet%';" 2>/dev/null; \
sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db "DELETE FROM access WHERE client LIKE '%wacom%' OR client LIKE '%Wacom%' OR client LIKE '%Tablet%';" 2>/dev/null; \
sudo rm -rf /private/var/log/Wacom* 2>/dev/null; \
echo "Limpeza concluída!" && echo "Reinicie com: sudo shutdown -r now"
