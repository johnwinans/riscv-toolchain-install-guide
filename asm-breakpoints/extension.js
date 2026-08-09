// RISC-V debug contribution.
//
// Registers a "riscv-qemu" debug type that launches qemu-system-riscv32 with a
// gdb stub (-S -gdb tcp::PORT), waits for the stub to accept connections, then
// hands the session off to Microsoft's cpptools ("cppdbg") adapter as a remote
// target. QEMU is torn down when the debug session ends.

const vscode = require('vscode');
const cp = require('child_process');
const net = require('net');

/** @type {Map<number, {proc: import('child_process').ChildProcess, output: vscode.OutputChannel}>} */
const servers = new Map();

function defaultConfig() {
  return {
    type: 'riscv-qemu',
    request: 'launch',
    name: 'RISC-V (QEMU)',
    program: '${workspaceFolder}/prog',
    stopAtEntry: true
  };
}

function activate(context) {
  const provider = {
    provideDebugConfigurations() {
      return [defaultConfig()];
    },

    async resolveDebugConfiguration(folder, config) {
      // F5 with no/empty launch.json: start from a sensible default.
      if (!config.type && !config.request && !config.name) {
        config = defaultConfig();
      }
      if (config.type !== 'riscv-qemu') {
        return config;
      }

      const workspaceRoot = folder
        ? folder.uri.fsPath
        : (vscode.workspace.workspaceFolders && vscode.workspace.workspaceFolders[0]
            ? vscode.workspace.workspaceFolders[0].uri.fsPath
            : process.cwd());
      const subst = (v) =>
        typeof v === 'string' ? v.replace(/\$\{workspaceFolder\}/g, workspaceRoot) : v;

      const program = subst(config.program);
      if (!program) {
        vscode.window.showErrorMessage(
          'riscv-qemu: "program" (path to the ELF) is required in the launch configuration.'
        );
        return undefined; // abort the session
      }

      const qemuPath = config.qemuPath || 'qemu-system-riscv32';
      const machine = config.machine || 'virt';
      const memory = config.memory || '128M';
      const bios = config.bios || 'none';
      const gdbPath = config.gdbPath || 'gdb-multiarch';
      const port = config.gdbPort || 1234;
      const cwd = subst(config.cwd) || workspaceRoot;
      const extraArgs = Array.isArray(config.qemuArgs) ? config.qemuArgs : [];
      const stop = config.stopAtEntry !== false;

      const qemuArgs = [
        '-machine', machine,
        '-m', memory,
        '-bios', bios,
        '-device', `loader,file=${program}`,
        '-nographic',
        '-S',
        '-gdb', `tcp::${port}`,
        ...extraArgs
      ];

      // Only one QEMU per port; replace any leftover from a previous session.
      await stopServer(port);

      const output = vscode.window.createOutputChannel(`RISC-V QEMU :${port}`);
      output.show(true);
      output.appendLine(`$ ${qemuPath} ${qemuArgs.join(' ')}`);

      let proc;
      try {
        proc = cp.spawn(qemuPath, qemuArgs, { cwd });
      } catch (e) {
        vscode.window.showErrorMessage(`riscv-qemu: failed to start QEMU (${qemuPath}): ${e.message}`);
        return undefined;
      }
      proc.stdout.on('data', (d) => output.append(d.toString()));
      proc.stderr.on('data', (d) => output.append(d.toString()));
      proc.on('error', (e) =>
        vscode.window.showErrorMessage(`riscv-qemu: QEMU error: ${e.message}`)
      );
      proc.on('exit', (code, signal) => {
        output.appendLine(`\n[QEMU exited: code=${code} signal=${signal}]`);
        servers.delete(port);
      });
      servers.set(port, { proc, output });

      // Wait until the gdb stub is listening so cpptools connects on the first try.
      try {
        await waitForPort(port, 'localhost', 8000);
      } catch (e) {
        await stopServer(port);
        vscode.window.showErrorMessage(
          `riscv-qemu: QEMU gdb stub did not open on port ${port} (${e.message}).`
        );
        return undefined;
      }

      // Hand off to cpptools as a remote target. The unresolved fields below are
      // consumed by the cppdbg adapter, not by us.
      return {
        type: 'cppdbg',
        request: 'launch',
        name: config.name || 'RISC-V (QEMU)',
        program,
        cwd,
        MIMode: 'gdb',
        miDebuggerPath: gdbPath,
        miDebuggerServerAddress: `localhost:${port}`,
        stopAtConnect: stop,
        setupCommands: Array.isArray(config.setupCommands) ? config.setupCommands : []
      };
    }
  };

  context.subscriptions.push(
    vscode.debug.registerDebugConfigurationProvider('riscv-qemu', provider),
    vscode.debug.onDidTerminateDebugSession(async (session) => {
      const addr = session.configuration && session.configuration.miDebuggerServerAddress;
      if (typeof addr === 'string') {
        const p = parseInt(addr.split(':').pop(), 10);
        if (servers.has(p)) {
          await stopServer(p);
        }
      }
    })
  );
}

function waitForPort(port, host, timeoutMs) {
  const start = Date.now();
  return new Promise((resolve, reject) => {
    const tryOnce = () => {
      const sock = net.connect(port, host);
      sock.once('connect', () => {
        sock.destroy();
        resolve();
      });
      sock.once('error', () => {
        sock.destroy();
        if (Date.now() - start > timeoutMs) {
          reject(new Error('timeout'));
        } else {
          setTimeout(tryOnce, 100);
        }
      });
    };
    tryOnce();
  });
}

function stopServer(port) {
  return new Promise((resolve) => {
    const s = servers.get(port);
    if (!s) {
      resolve();
      return;
    }
    servers.delete(port);
    const { proc } = s;
    let done = false;
    const finish = () => {
      if (!done) {
        done = true;
        resolve();
      }
    };
    try {
      proc.once('exit', finish);
      proc.kill('SIGTERM');
      setTimeout(() => {
        try {
          proc.kill('SIGKILL');
        } catch (_) {
          /* already gone */
        }
        finish();
      }, 1500);
    } catch (_) {
      finish();
    }
  });
}

function deactivate() {
  const pending = [];
  for (const port of Array.from(servers.keys())) {
    pending.push(stopServer(port));
  }
  return Promise.all(pending);
}

module.exports = { activate, deactivate };
