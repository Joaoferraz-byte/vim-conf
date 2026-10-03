{ lib, pkgs, ... }:
{
  plugins.dap = {
    enable = true;

    adapters.executables.lldb = {
      command = "${pkgs.lldb}/bin/lldb-dap";
    };

    adapters.executables.python = {
      command = "${pkgs.python3Packages.debugpy}/bin/python";
      args = [ "-m" "debugpy.adapter" ];
    };

    configurations = {
      c = [
        {
          name = "Launch executable (LLDB)";
          type = "lldb";
          request = "launch";
          program.__raw = ''
            function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end
          '';
          cwd = "\${workspaceFolder}";
          stopOnEntry = false;
        }
      ];
      cpp = [
        {
          name = "Launch executable (LLDB)";
          type = "lldb";
          request = "launch";
          program.__raw = ''
            function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end
          '';
          cwd = "\${workspaceFolder}";
          stopOnEntry = false;
        }
      ];
      java = [
        {
          type = "java";
          request = "attach";
          name = "Attach Spring Boot (porta 5005)";
          hostName = "127.0.0.1";
          port = 5005;
        }
      ];
      python = [
        {
          name = "Launch current Python file";
          type = "python";
          request = "launch";
          program.__raw = ''vim.fn.expand("%:p")'';
          pythonPath.__raw = ''function() return vim.fn.exepath("python") end'';
          console = "integratedTerminal";
          cwd = "\${workspaceFolder}";
        }
      ];
    };
  };

  plugins.dap-ui.enable = true;
  plugins.dap-virtual-text.enable = true;

  extraConfigLua = ''
    local dap, dapui = require("dap"), require("dapui")
    dap.listeners.after.event_initialized["nixvim_dapui"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["nixvim_dapui"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["nixvim_dapui"] = function()
      dapui.close()
    end
  '';

  extraPackages = with pkgs; [
    lldb
    gdb
  ];
}
