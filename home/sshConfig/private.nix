{ pkgs ? (import <nixpkgs> {}), lib ? pkgs.lib, ... }:

let
  keys = {
    idRsa = ../../keys/private/id_rsa;
  };
  hasIdRsa = lib.pathExists keys.idRsa;
in [] ++
  (lib.optional (hasIdRsa) {
    host = "hassio.local";
    hostname = "hassio.local";
    identityFile = toString keys.idRsa;
    user = "root";
  })
  ++ (lib.optional (hasIdRsa) {
    host = "gitlab";
    hostname = "gitlab.com";
    identityFile = toString keys.idRsa;
    user = "git";
  })
  ++ (lib.optional (hasIdRsa) {
    host = "github";
    hostname = "github.com";
    identityFile = toString keys.idRsa;
    user = "git";
  })
  ++ (lib.optional (hasIdRsa) {
    host = "remote_gollum";
    hostname = "home.nocoolnametom.com";
    identityFile = toString keys.idRsa;
    user = "pi";
    port = 22223;
  })
  ++ (lib.optional (hasIdRsa) {
    host = "remote_gimli";
    hostname = "home.nocoolnametom.com";
    identityFile = toString keys.idRsa;
    user = "tdoggett";
    port = 22224;
  })
  ++ (lib.optional (hasIdRsa) {
    host = "linode";
    hostname = "nocoolnametom.com";
    identityFile = toString keys.idRsa;
    user = "doggetto";
    port = 2222;
  })
  ++ (lib.optional (hasIdRsa) {
    host = "elrond";
    hostname = "45.33.53.132";
    identityFile = toString keys.idRsa;
    user = "root";
    port = 2222;
  })
  ++ (lib.optional (hasIdRsa) {
    host = "frodo";
    hostname = "frodo";
    identityFile = toString keys.idRsa;
    user = "pi";
  })
  ++ (lib.optional (hasIdRsa) {
    host = "gimli";
    hostname = "gimli";
    identityFile = toString keys.idRsa;
    user = "tdoggett";
  })
  ++ (lib.optional (hasIdRsa) {
    host = "gollum";
    hostname = "gollum";
    identityFile = toString keys.idRsa;
    user = "pi";
})