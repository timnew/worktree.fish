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
  read -l -P "Remove worktree and branch? [y/N] " confirm
  or return  # Exit if user cancelled with Ctrl+C or Ctrl+D

  if string match -qi "y" $confirm
    set -l cwd (pwd)
    set -l worktree (basename "$cwd")

    # split on first `--`
    set -l parts (string split --max=1 -- '--' "$worktree")
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

# List all worktrees
function gwl --description "List all git worktrees"
  git worktree list
end

# Navigate to a worktree or back to base directory
function gwcd --description "Navigate to a worktree branch or back to base directory"
  if test -z "$argv[1]"
    # No branch given, go back to base directory
    set -l cwd (pwd)
    set -l worktree (basename "$cwd")

    # split on first `--`
    set -l parts (string split --max=1 -- '--' "$worktree")
    set -l root $parts[1]

    # Check if we're in a worktree directory
    if test "$root" != "$worktree"
      cd "../$root"
    else
      echo "Already in base directory or not in a worktree"
    end
  else
    # Branch given, navigate to that worktree
    set -l branch $argv[1]
    set -l cwd (pwd)
    set -l worktree (basename "$cwd")

    # Get the base name
    set -l parts (string split --max=1 -- '--' "$worktree")
    set -l base $parts[1]

    set -l target "../$base--$branch"

    if test -d "$target"
      cd "$target"
    else
      echo "Worktree '$target' not found"
      return 1
    end
  end
end

# Autocomplete for ga - suggests branch names
