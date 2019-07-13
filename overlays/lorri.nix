self: super: {
  lorri =
    let src =
      (super.fetchFromGitHub {
        owner = "target";
        repo = "lorri";
        rev = "8224dfb57e508ec87d38a4ce7b9ce27bbf7c2a81";
        sha256 = "0qk4lqgqx312v2knzjcj52bvf1kh4bxcpmbb8n45fg3hqviicbrl";
      });
    in super.callPackage src { inherit src; };
}
