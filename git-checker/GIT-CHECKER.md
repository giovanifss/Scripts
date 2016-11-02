# Git Checker

Script to find branches in git repositories that have commits not pushed to remote yet.  

## What it does?
This script will:
- Check all subdirectories recursively searching for git repositories.  
- Check in all branches if there is commits not pushed to remote yet.  

## Usage
The script receives a base directory to search inside:  
```git-checker [Base dir] [--parallel]```  

### Operation Modes
The script operates in two different modes:  
- Serial (default)  
- Parallel  

To enable parallel execution (script will create a lot of subprocesses), use the option ```--parallel```  
