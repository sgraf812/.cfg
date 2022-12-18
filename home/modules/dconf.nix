{ pkgs, lib, ... }:

let
  mkShortcuts = settings:
    let
      inherit (builtins) length head tail listToAttrs genList;
      range = a: b: if a < b then [a] ++ range (a+1) b else [];
      globalPath = "org/gnome/settings-daemon/plugins/media-keys";
      path = "${globalPath}/custom-keybindings";
      mkPath = id: "${path}/custom${toString id}";
      isEmpty = list: length list == 0;
      checkSettings = { name, command, binding }@this: this;
      aux = i: list:
        if isEmpty list then [] else
          let
            hd = head list;
            tl = tail list;
            name = mkPath i;
          in
            aux (i+1) tl ++ [ {
              name = mkPath i;
              value = checkSettings hd;
            } ];
      settingsList = (aux 0 settings);
    in
      listToAttrs (settingsList ++ [
        {
          name = globalPath;
          value = {
            custom-keybindings = genList (i: "/${mkPath i}/") (length settingsList);
          };
        }
      ]);
in

{
  # Needs the following in the system config:
  # services.dbus.packages = [ pkgs.dconf ];

  imports = [ ];

  home.packages = with pkgs; [
    dconf
  ];

  dconf.settings =
    (let
      nmcli = "${pkgs.networkmanager}/bin/nmcli";
    in
      mkShortcuts [
        {
          name = "Toggle VPN";
          #binding = "XF86AudioMedia"; # can't catch this key for some reason
          binding = "F12";
          command = "sh -c 'if [[ -n $(${nmcli} con show kit | grep \"VPN connected\") ]]; then ${nmcli} con down kit; else ${nmcli} con up kit; fi'";
        }
      ])
    //
    ({
      "org/gnome/mutter" = {
        experimental-features = [ "scale-monitor-framebuffer" ];
      };
    })
    //
    ({
      "org/gnome/desktop/input-sources" = {
        show-all-sources = true;
      };
    });
}
