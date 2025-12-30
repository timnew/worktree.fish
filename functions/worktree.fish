# Create a new worktree and branch from within current git directory.
function gwa --description "Create a new git worktree with a branch in a sibling directory"
  if test -z "$argv[1]"
    echo "Usage: ga [branch name]"
    return 1
  end

  set -l branch $argv[1]
  set -l base (basename "$PWD")
  set -l path "../$base--$branch"

  git worktree add -b "$branch" "$path"
  mise trust "$path"
  cd "$path"
end

# Remove worktree and branch from within active worktree directory.
function gwd --description "Remove the current worktree and its associated branch"
  read -l -n 1 -p "Remove worktree and branch? [y/N] " confirm
  if string match -qi "y" $confirm
    set -l cwd (pwd)
    set -l worktree (basename "$cwd")

    # split on first `--`
    set -l parts (string split --max=1 -- "$worktree")
    set -l root $parts[1]
    set -l branch $parts[2]

    # Protect against accidentally nuking a non-worktree directory
    if test "$root" != "$worktree"
      cd "../$root"
      git worktree remove "$worktree" --force
      git branch -D "$branch"
    end
  end
end

# Autocomplete for ga - suggests branch names
complete -c gwa -x -a "(__fish_git_branches)" -d "Branch name"
complete -c gwd -d "Remove worktree and branch"
