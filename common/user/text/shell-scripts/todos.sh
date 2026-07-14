# Find all the TODO messages in the current git repository, under the current working dkrectory, sorted by the commit's date.
# Uses bash parameter expansion or rematches wherever possible to improve performance
set -uo pipefail
tab=$'\t'

function search_gitrepo() {
	exitcode=1 # Signal if no matches found

	while read result; do
		exitcode=0
		# Extract the first two fields
		result="${result%:$1}" # Remove search term
		filepath="${result%:*}" # Get first field
		line_num=${result#*:} # Get second field
		# Ask git for information about the line in this file
		blame=$(git blame --date=short -cL $line_num,$line_num "$filepath")
		# Extract the date and content
		date=${blame#*$tab*$tab} # Remove first 2 fields
		date=${date%%$tab*} # Remove all after 3rd field
		[[ "$blame" =~ [0-9]{1,}\).*$ ]] && content=${BASH_REMATCH[0]}
		# Pass to caller
		echo $date $filepath $content
	# Use git grep to only search tracked files
	done < <(git grep -inHo "$1")

	return $exitcode
}

# Sort search results by date
# Note: keywords are broken up so they don't appear in the search
search_gitrepo "F""IXME" | sort -n
[ ${PIPESTATUS[0]} -eq 0 ] && echo
search_gitrepo "T""ODO" | sort -n

