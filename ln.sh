cd ~
ln -s org/.bash_aliases .
ln -s org/.screenrc .
ln -s org/.emacs .
ln -s org/.tmux.conf .
ln -s org/.gitignore_global .

mkdir -p ~/.claude
ln -sf ~/org/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/org/claude/settings.json ~/.claude/settings.json
ln -sf ~/org/claude/commands ~/.claude/commands
ln -sf ~/org/claude/memory ~/.claude/memory

git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"

touch ~/.hushlogin

git config --global user.email "chris@lablackey.com"
git config --global user.name "chriscauley"
git config --global core.excludesfile ~/.gitignore_global