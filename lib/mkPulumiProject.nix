{pkgs, ...}: project: let
  projectOptions = (import ./options.nix).projectOptions;

  filterAttrsRecursive' = pred: any:
    if pkgs.lib.isList any
    then map (v: filterAttrsRecursive' pred v) any
    else if pkgs.lib.isAttrs any
    then let
      set = any;
    in
      pkgs.lib.listToAttrs (
        pkgs.lib.concatMap (
          name: let
            v = set.${name};
          in
            if pred name v
            then [
              (pkgs.lib.nameValuePair name (
                if pkgs.lib.isAttrs v
                then filterAttrsRecursive' pred v
                else if pkgs.lib.isList v
                then map (e: filterAttrsRecursive' pred e) v
                else v
              ))
            ]
            else []
        ) (pkgs.lib.attrNames set)
      )
    else any;

  parsed =
    filterAttrsRecursive' (n: v: v != null)
    (pkgs.lib.modules.evalModules {
      modules = [projectOptions {config = project;}];
    })
    .config;

  projectConfig = parsed.config // {runtime.name = "yaml";};
  projectConfigFile = builtins.toFile "Pulumi.yaml" (builtins.toJSON projectConfig);

  programFile = builtins.toFile "Main.json" (builtins.toJSON parsed.program);

  stackConfigs = builtins.mapAttrs (stackName: stack: builtins.toFile "${stackName}" (builtins.toJSON stack)) parsed.stacks;

  cpString = builtins.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (stackName: configPath: "cp ${configPath} $out/Pulumi.${stackName}.yaml") stackConfigs);
in
  pkgs.runCommand "pulumidir" {} ''
    mkdir -p $out

    cp ${projectConfigFile} $out/Pulumi.yaml
    cp ${programFile} $out/Main.json
    ${cpString}
  ''
