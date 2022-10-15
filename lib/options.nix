{
  projectOptions = {lib, ...}: let
    inherit (lib) types;
    namePathVersionType = types.submodule {
      options = {
        name = lib.mkOption {
          type = types.str;
          description = "Name of the plugin.";
        };
        path = lib.mkOption {
          type = types.nullOr types.str;
          description = "Path to the plugin folder.";
          default = null;
        };
        version = lib.mkOption {
          type = types.nullOr types.str;
          description = "Version of the plugin, if not set, will match any version the engine requests.";
          default = null;
        };
      };
    };

    optionType = types.submodule {
      options = {
        refresh = lib.mkOption {
          default = null;
          description = "Set to `always` to refresh the state before performing a Pulumi operation.";
          type = types.nullOr types.str;
        };
      };
    };

    pluginType = types.submodule {
      options = {
        providers = lib.mkOption {
          description = "Plugin for the provider.";
          type = types.listOf namePathVersionType;
          default = [];
        };
        analyzers = lib.mkOption {
          description = "Plugin for the policy.";
          type = types.listOf namePathVersionType;
          default = [];
        };
        languages = lib.mkOption {
          description = "Plugin in for the language.";
          type = types.listOf namePathVersionType;
          default = [];
        };
      };
    };

    backendType = types.submodule {
      options = {
        url = lib.mkOption {
          default = null;
          description = "URL is optional field to explicitly set backend url.";
          type = types.nullOr types.str;
        };
      };
    };

    configType = types.submodule {
      options = {
        name = lib.mkOption {
          description = "Name of the project containing alphanumeric characters, hyphens, underscores, and periods.";
          type = types.str;
        };
        description = lib.mkOption {
          default = null;
          description = "Description of the project.";
          type = types.nullOr types.str;
        };
        backend = lib.mkOption {
          default = null;
          description = "Backend of the project.";
          type = types.nullOr backendType;
        };
        options = lib.mkOption {
          default = null;
          description = "Additional project options.";
          type = types.nullOr optionType;
        };
        plugins = lib.mkOption {
          default = null;
          description = "Override for the plugin selection. Intended for use in developing pulumi plugins.";
          type = types.nullOr pluginType;
        };

        # TODO runtime, main, stackConfigDir, template see https://www.pulumi.com/docs/reference/pulumi-yaml/
      };
    };
  in {
    options = {
      config = lib.mkOption {
        description = "The project configuration.";
        type = configType;
      };
      program = lib.mkOption {
        description = "The program to run";
        type = types.attrs;
      };
      stacks = lib.mkOption {
        description = "The stack configurations";
        type = types.attrs;
      };
    };
  };
}
