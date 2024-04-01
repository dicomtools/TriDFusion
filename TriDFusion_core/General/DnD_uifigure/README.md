# Drag and Drop OS file/folder(s) into Matlab uifigure
[![View uiFileDnD on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/80656-uifilednd)

This single file implementation can set up a callback fired when files and/or folders are dropped onto a uifigure component. 

In the callback, full file/folder names are captured for user to decide the action. Ctrl and Shift key status during the drop event are also reported.

Example to drop file/folder into uilistbox:
    
    target = uilistbox(uifigure, 'Position', [80 100 400 100]);
    DnD_uifigure(target, @(o,dat)set(o,'Items',dat.names));

Note: the DnD works only for Matlab R2020b or later.
