## pathogen.vim

**install details**:

  * mkdir -p ~/.vim/autoload ~/.vim/bundle 
  * curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

## taglist.vim

**install details**:

  1. Unzip taglist.vim to bundle dir.

  2. If the exuberant ctags utility is not present in your PATH, then set the
     Tlist_Ctags_Cmd variable to point to the location of the exuberant ctags 
     utility (not to the directory) in the .vimrc file. [ Needs ctags ]

  4. If you are running a terminal/console version of Vim and the terminal
     doesn't support changing the window width then set the
     'Tlist_Inc_Winwidth' variable to 0 in the .vimrc file.

  5. Restart Vim.

  6. You can now use the ":TlistToggle" command to open/close the taglist
     window. You can use the ":help taglist" command to get more information
     about using the taglist plugin.
