# intel-bluetooth-wakeup-fix
My simple fix for Intel Bluetooth not working when returning from sleep on Windows 10.

Bluetooth on my Ziyituod ZYT-AX200 fails to start, with `Windows has stopped this device because it has reported problems. (Code 43)` error, when my Windows 10 computer wakes from sleep.  
Disabling and enablying the device fixes this for me.  
So I wrote a simple [script](script.ps1) to do just that and Windows Task Scheduler [task](task.xml) to run the script on wakeup (Microsoft-Windows-Power-Troubleshooter EventID 1).  

## How to setup.
1. Copy base task.xml file.
2. Replace `YOUR_PATH_TO_REPO_DIR_HERE` string with path to this root directory.
3. Import .xml file to your Windows Task Scheduler and enable it.

If you have different device but same problem, then just modify consts at start of the [script](script.ps1).