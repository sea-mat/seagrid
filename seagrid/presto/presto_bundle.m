function presto_bundle

% presto_bundle -- Bundle "presto" software.
%  presto_bundle (no argument) bundles the
%   "presto" software into "presto_install.p".
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 03-Nov-1999 08:11:48.
% Updated    16-Dec-1999 12:07:01.

setdef(mfilename)

dst = 'presto_install';
target = '';

delete([dst '.m'])
delete([dst '.p'])

bundle(dst)

% Get full bundle name and trim the extension.

dst = which(dst);
f = find(dst == '.');
if any(f), dst(f(end):end) = ''; end

% Bundle the routines.

bundle(dst, 'makedir', target)
bundle(dst, 'newfolder.mac', target, 'binary')
bundle(dst, 'eval', target, 'makedir presto')
bundle(dst, 'eval', target, 'cd presto')

bundle(dst, 'README', target)

bundle(dst, 'setdef', target)

bundle(dst, 'presto_bundle', target)

bundle(dst, 'inherit', target)
bundle(dst, 'super', target)
bundle(dst, 'isps', target)
bundle(dst, 'psbind', target)
bundle(dst, 'psevent', target)
bundle(dst, 'ps_test', target)

newversion ps
bundle(dst, '@ps', target)

bundle(dst, 'eval', target, 'cd ..')

bundle(dst, 'disp', target, ' ')
bundle(dst, 'disp', target, ' ## To get started, put the "presto" folder in your Matlab')
bundle(dst, 'disp', target, ' ##  path, then execute "presto_test" at the Matlab prompt.')

% P-coding.

disp(' ## P-coding...')

pcode(dst)
