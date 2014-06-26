function makedir(varargin)

% makedir -- Make a new directory.
%  makedir('thePath') creates a new sub-directory named 'thePath'
%   (no embellishments), located within the current directory.
%   A dialog is invoked if manual intervention is needed.  No
%   action is taken if the desired directory already exists.
%   The "present-working-directory" itself remains the same.
%  makedir "p q r" assumes that the arguments represent one
%   path-name with single-blanks between components.
%  makedir p q r is the same as makedir "p q r".

% Copyright (C) 1996-7 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without written explicit consent from the
%    copyright owner does not constitute publication.
 
% Version of 08-Jul-1997 08:36:09.
% Revised    04-Nov-1998 21:57:53.
% Revised    05-Nov-1998 15:24:50.

if nargin < 1, help(mfilename), return, end

thePath = '';
for i = 1:length(varargin)
   if i > 1, thePath = [thePath ' ']; end
   thePath = [thePath varargin{i}];
end

if thePath(1) == '"' & thePath(length(thePath)) == '"'
   thePath = thePath(2:length(thePath)-1);
end

itExists = 1;
trystr = 'cd(thePath); cd ..';
catchstr = 'itExists = 0;';
eval(trystr, catchstr)
if itExists
   disp([' ## Directory already exists: "' thePath '"'])
   return
end

lasterr('')
warn = 'warning(lasterr); lasterr('''');';

thePWD = pwd;
if thePWD(length(thePWD)) == filesep
   thePWD(length(thePWD)) = '';
end

if exist('mkdir', 'builtin') | exist('mkdir', 'file')
   theCommand = ['mkdir(''' thePath ''')'];
  elseif any(findstr(computer, 'MAC'))
   theCommand = ['newfolder(''' thePath ''')'];
  elseif any(findstr(computer, 'VMS'))
   theCommand = ['!create/directory "' thePWD filesep thePath '"'];
  else
   theCommand = ['!mkdir "' thePWD filesep thePath '"'];
end

disp([' ## ' theCommand])
eval(theCommand, warn)

trystr = 'itExists = 1; cd(thePath); cd ..';
catchstr = 'itExists = 0;';
eval(trystr, catchstr)

if itExists
   disp([' ## Directory created: "' thePath '"'])
   return
end

thePrompt = ['Make New ' thePath ' Folder'];
theInstruction = 'Create, Then Save';
while ~itExists
   if any(uisetdir(thePrompt, theInstruction))
      cd ..
      eval(trystr, catchstr)
     else
      break
   end
   thePrompt = [thePrompt '!'];
end

if itExists
   disp([' ## Directory created: "' thePath '"'])
  else
   disp([' ## Unable to create: "' thePath '"'])
end

function theResult = newfolder(theFolderName)

% newfolder -- Create a new Macintosh folder.
%  newfolder('theFolderName') creates a new Macintosh
%   folder of 'theFolderName' in the current directory.
%   The current directory setting remains unchanged.
%   If the folder already exists, no action is taken.
%   The result is logical(1) if successful; otherwise
%   it is logical(0).
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 05-Sep-1997 17:01:27.

% The applescript commands in file "newfolder.mac".
%
% set theTarget to thePath & ":" & theNewFolder
% if not (exists item theTarget) then
%    make new folder at folder thePath
%    set name of folder "untitled folder" of folder thePath to theNewFolder
% end if

if nargin < 1
   help(mfilename)
   return
end

if ~any(findstr(computer, 'MAC'))
   disp([' ## No action taken: "' mfilename '" requires Macintosh computer.'])
   return
end

thePath = pwd;
while thePath(length(thePath)) == filesep
   thePath(length(thePath)) = '';
end
thePath = ['"' thePath '"'];

theNewFolder = ['"' theFolderName '"'];

result = feval('applescript', 'newfolder.mac', ...
            'thePath', thePath, 'theNewFolder', theNewFolder);

if ~isempty(result), disp(result), end

result = logical(isempty(result));

if nargout > 0, theResult = result; end

function theStatus = uisetdir(thePrompt, theInstruction)

% uisetdir -- Open the destination folder via dialog.
%  uisetdir('thePrompt', 'theInstruction') presents the "uiputfile"
%   dialog with 'thePrompt' and 'theInstruction', for selecting the
%   desired destination folder.  The returned status is logical(1)
%   if successful; otherwise, logical(0).
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 03-Jul-1997 09:16:00.

if nargin < 1, thePrompt = 'Open The Destination Folder'; end
if nargin < 2, theInstruction = 'Save If Okay'; end

theFile = 0; thePath = 0;
[theFile, thePath] = uiputfile(theInstruction, thePrompt);

status = 0;                
if isstr(thePath) & any(thePath)
   status = 1;
   eval('cd(thePath)', 'status = 0;')
end

if nargout > 0, theStatus = any(any(status)); end
