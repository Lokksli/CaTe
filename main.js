const { app, BrowserWindow, ipcMain } = require('electron/main')


const path = require('node:path')
const { spawn } = require("child_process");

function generateGraph(mode) {

    return new Promise((resolve, reject) => {

        const rProcess = spawn(
            "Rscript",
            [
                path.join(__dirname, "main.R"),
                mode
            ]
        );

        rProcess.stdout.on("data", (data) => {
            console.log(`R: ${data}`);
        });

        rProcess.stderr.on("data", (data) => {
            console.error(`R error: ${data}`);
        });

        rProcess.on("close", (code) => {

            if (code === 0) {
                console.log("R finished successfully");
                resolve();
            } else {
                reject(
                    new Error(
                        `R exited with code ${code}`
                    )
                );
            }

        });

    });
}


ipcMain.on(
    "set-daily-average",
    async (event, enabled) => {
        console.log(
            "Daily average requested: ",
            enabled
        );

        const mode = enabled
            ? "daily"
            : "raw";

        try {

            await generateGraph(mode);

            event.sender.send(
                "graph-generated"
            );

        } catch (error) {
            console.log("Failed to generate graph:", error);

            event.sender.send("graph-generation-error", error.message);
        }
    }
);



const createWindow = () => {
    const win = new BrowserWindow({
        width: 1920,
        height: 1080,
        webPreferences: {
            preload: path.join(__dirname, 'preload.js')
        }
    })

    win.loadFile("index.html")
    win.webContents.openDevTools()
}

app.whenReady().then(() => {
    ipcMain.handle('ping', () => 'pong')
    createWindow()

})

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') app.quit()
})