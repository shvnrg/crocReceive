# crocReceive 
Minmal GUI for croc file transfer. Easy File Sharing for Discord. 
Please remember. This is just a simple AutoIt Script to make life easier. It probably has some (?) bugs at the moment.
Code Optimizing is still pending. Testing is partitially done and i am already using it without problems. 
Feel free to use or do whatever you want with it, or use a better programming language for the idea ^^.
There are better solutions than AutoIt, but it is working ¯\_(ツ)_/¯ Used ISN AutoIT Studio

***Manual***

**Installation:**
- Extract Croc into a folder of your choice -> https://github.com/schollz/croc/releases
- Extract CrocReceiverGui.exe into the folder where you extracted croc.exe 
- Run CrocReceiverGUI.exe and choose "Install / Uninstall" to register handles and right click menus for files and folders. It will ask Admin rights to do this!
  IF YOU ALREAD HAD THE OLDER VERSION INSTALLED THEN DEINSTALL THE HANDLES AND REINSTALL THEM!
- You are ready to go

**Deinstallation:**
- RRun CrocReceiverGUI.exe and choose "Install / Uninstall". It will unregister handles and remove right click menus. It will ask for Admin rights to do this! 
- Delete Croc and CrocReceiver files
- You are done

**Sending Files:**
There are two ways of sending files. These two ways can be mixed. Marked by 1. and 2. 

1. Right Click Menu
- Right Click a Folders or Files and Choose "Send it with Croc"
- The GUI will open and will add all Files and Folders in the ListView.
  IF YOU SELECTED MULTIPLE FILES OR FOLDERS THERE WILL BE SMALL POPUPS WHICH ARE USED TO GET ALL FILENAMES. DONT PANIC :)
  I had to use this method with the popups because i cant pass multiple Arguments into the Executable with Windows
- You can add more files the same way when the GUI is already open. The newly added files will create new popups which will transfer into the ListView
- When you have all your files in the ListView click "Send Files"
- The Croc CMD Window will open and in the background the Password will be extracted.
- The URL will be copied in the clipboard and can be shared with other people using the tool.
  The Website is just a redirect to open a URL named croc:// which is registered by CrocReceiverGui. I had to use this way because discord blocked custom URI Handles.
- Paste Clipboard into Discord or whatever communication tool you use and send it to someone.
- Keep Croc Window open till partner accepts and transfers are finished.

2. GUI
- Open the CrocReceiverGui and Drag & Drop the files and folders in the ListView
- When you have all your files in the ListView click "Send Files"
- The Croc CMD Window will open and in the background the Password will be extracted.
- The URL will be copied in the clipboard and can be shared with other people using the tool.
  The Website is just a redirect to open a URL named croc:// which is registered by CrocReceiverGui. I had to use this way because discord blocked custom URI Handles.
- Paste Clipboard into Discord or whatever communication tool you use and send it to someone.
- Keep Croc Window open till partner accepts and transfers are finished.

**Receiving Files:**
- Click on Croc Receiver Link you received. They begin with "https://shvnrg.github.io/crocdirect.html?" followed by the CrocPassword.
- The browser will ask if you want to open this Link with the CrocReceiverGUI.exe
- The Code you received will automatically be in the "Code" Field
- Make sure to choose the "Save to" Path where you want to receive the files
- Click "Receive Files"
- Croc Window will open and will show you the files which you will receive. Enter "Y" to receive them.

***Other Stuff***

**Todo:**
- Testing
- Optimizing
- Comments in Code
- etc.
