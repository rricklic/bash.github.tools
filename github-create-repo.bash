#!/bin/bash

usage="$0 -u <GitHub username> -r <new GitHub repo> [-h display usage]"

################################################################################
exit_usage() 
{
   echo $usage
   exit $1;
}

################################################################################
check_for_git_dir()
{
   if [ -d "./.git" ]; then
      echo "Local .git directory already exists, will not create new repo."
      exit 1;
   fi
}

################################################################################
confirm()
{
   user_input=""
   until [ "$user_input" == "n" ] || [ "$user_input" == "no" ] || [ "$user_input" == "y" ] || [ "$user_input" == "yes" ]; do
      echo Will create https://github.com/$github_user/$github_repo.git, continue \(y/n\)?
      read user_input
      user_input=${user_input,,} #convert to lowercase
   done

   if [ "$user_input" == "n" ] || [ "$user_input" == "no" ]; then
      echo "Aborting"
      exit 0;
   fi
}

################################################################################
execute()
{
   echo $1
   eval $1
}

#################################### MAIN ######################################
while getopts ":u:r:h" opt; do
  case $opt in
    u)
      github_user=$OPTARG
      ;;
    r)
      github_repo=$OPTARG
      ;;
    h)
      exit_usage 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit_usage 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit_usage 1
      ;;
  esac
done

if [ -z "${github_user+xxx}" ]; then echo GitHub username \(-u\) must be defined; exit_usage 1; fi
if [ -z "${github_repo+xxx}" ]; then echo New GitHub repository \(-r\) must be defined; exit_usage 1; fi

check_for_git_dir
confirm

execute "git init;"
execute "git add .;"
execute "git commit -a;"
execute "curl -u $github_user https://api.github.com/user/repos -d '{\"name\":\"$github_repo\"}';"
execute "git remote add origin https://github.com/$github_user/$github_repo.git;"
execute "git push -u origin master;"

exit 0
