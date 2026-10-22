const vscode = require('vscode');
const fs = require('fs');
const os = require('os');
const path = require('path');

// vim's <F5> leaves one { folder, target, time } JSON file here per request.
const QUEUE = path.join(os.homedir(), '.vim', 'vscode-debug');
const STALE_SECONDS = 120;

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const normalize = p => path.resolve(p).replace(/[\\/]+$/, '').toLowerCase();

function workspaceFolderFor(folderPath) {
	const wanted = normalize(folderPath);
	return (vscode.workspace.workspaceFolders || []).find(f => normalize(f.uri.fsPath) === wanted);
}

function takeRequests() {
	let names;
	try {
		names = fs.readdirSync(QUEUE).filter(name => name.endsWith('.json'));
	} catch {
		return [];
	}
	const taken = [];
	for (const name of names) {
		const file = path.join(QUEUE, name);
		let request;
		try {
			request = JSON.parse(fs.readFileSync(file, 'utf8'));
		} catch {
			continue;
		}
		if (Date.now() / 1000 - request.time > STALE_SECONDS) {
			fs.rmSync(file, { force: true });
			continue;
		}
		const folder = workspaceFolderFor(request.folder);
		if (!folder) {
			continue;
		}
		// Every VSCode window scans the same queue; the rename lets exactly one claim it.
		const claim = `${file}.${process.pid}`;
		try {
			fs.renameSync(file, claim);
		} catch {
			continue;
		}
		fs.rmSync(claim, { force: true });
		taken.push({ folder, target: request.target });
	}
	return taken;
}

// A window opened by `code <folder>` gets here before CMake Tools has loaded the project.
async function cmakeProjectReady(folder) {
	const extension = vscode.extensions.getExtension('ms-vscode.cmake-tools');
	if (!extension) {
		return false;
	}
	const api = (await extension.activate()).getApi(1);
	for (let tries = 0; tries < 120; ++tries) {
		if (await api.getProject(folder.uri)) {
			return true;
		}
		await sleep(500);
	}
	return false;
}

// With cmake.enableAutomaticKitScan off, a folder new to CMake Tools silently gets no kit,
// which means no MSVC environment and a configure that cannot find cl.exe.
async function ensureKit(folder) {
	if (await vscode.commands.executeCommand('cmake.buildKit', folder) !== '__unspec__') {
		return true;
	}
	let kits = [];
	try {
		const file = path.join(process.env.LOCALAPPDATA || '', 'CMakeTools', 'cmake-tools-kits.json');
		kits = JSON.parse(fs.readFileSync(file, 'utf8'));
	} catch {
	}
	if (kits.length === 1) {
		await vscode.commands.executeCommand('cmake.setKitByName', kits[0].name, folder);
	} else {
		await vscode.commands.executeCommand('cmake.selectKit', folder);
	}
	return await vscode.commands.executeCommand('cmake.buildKit', folder) !== '__unspec__';
}

async function debug({ folder, target }) {
	const launches = vscode.workspace.getConfiguration('launch', folder.uri).get('configurations', []);
	if (launches.length > 0) {
		await vscode.commands.executeCommand('workbench.action.debug.start');
		return;
	}
	if (!await cmakeProjectReady(folder)) {
		vscode.window.showErrorMessage(`Vim Debug Bridge: no CMake project in ${folder.name}`);
		return;
	}
	if (!await ensureKit(folder)) {
		return;
	}
	const known = await vscode.commands.executeCommand('cmake.executableTargets', folder) || [];
	const name = known.includes(target) ? target : undefined;
	await vscode.commands.executeCommand('cmake.debugTarget', folder, name);
}

let busy = false;

async function serve() {
	if (busy) {
		return;
	}
	busy = true;
	try {
		for (const request of takeRequests()) {
			await debug(request);
		}
	} finally {
		busy = false;
	}
}

function activate(context) {
	fs.mkdirSync(QUEUE, { recursive: true });
	const watcher = fs.watch(QUEUE, () => serve());
	context.subscriptions.push(
		{ dispose: () => watcher.close() },
		vscode.window.onDidChangeWindowState(state => state.focused && serve())
	);
	serve();
}

module.exports = { activate };
