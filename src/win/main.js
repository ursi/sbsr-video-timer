'use strict';

try {
	require(`elm-debug-transformer`).register();
} catch {}

const app = Elm.Main.init();

const
	fs = require(`fs`),
	path = require(`path`),
	{ipcRenderer} = require(`electron`);
	//SupPort = require(`./web-modules/SupPort`).default;

//const port = SupPort(app.ports);
