#!/bin/bash
RC_HOME=`pwd`
SYSTEM=`uname -s`

# do not install tigrc on Linux
if [ $SYSTEM == "Darwin" ]; then
    RC="tmux.conf tigrc"
else
    RC="tmux.conf tigrc"
fi
cd ..

# other than zsh
for target in $RC
do
   if [ -e ".$target" ] && [ ! -L ".$target" ]; then
      mv ".$target" ".$target.old"
      echo
   fi
   if [ ! -L ".$target" ]; then
      ln -s "$RC_HOME/$target" ".$target"
   fi
done

# prezto
for rcfile in $RC_HOME/prezto/*; do
    rcRel=${rcfile##*/}
    ln -s $rcfile ".$rcRel"
done

# install tmux plugins
~/.tmux/plugins/tpm/bin/install_plugins

if [[ "$SHELL" =~ .*/zsh ]]
then
   echo "Good. You are using $SHELL. No need to chsh."
else
   echo "Please change your shell to `which zsh`"
   chsh
fi
