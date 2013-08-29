git filter-branch --commit-filter '
      if [ "$GIT_AUTHOR_EMAIL" = "email@pezcuckwow.com" ];
      then
              GIT_AUTHOR_NAME="Pez Cuckow";
              GIT_AUTHOR_EMAIL="email@pezcuckow.com";
              git commit-tree "$@";
      else
              git commit-tree "$@";
      fi' HEAD
