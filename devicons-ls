#!/bin/bash
# Author: Ryan L McIntyre
# Project: devicons-shell

function devicons_get_directory_symbol {

	local symbol=""

	echo "$symbol $1"
	return 0
}

function devicons_get_filetype_symbol {

	declare -A extensions=(
		[txt]=e
		[styl]=
		[scss]=
		[htm]=
		[html]=
		[slim]=
		[ejs]=
		[css]=
		[less]=
		[md]=
		[markdown]=
		[json]=
		[js]=
		[jsx]=
		[rb]=
		[php]=
		[py]=
		[pyc]=
		[pyo]=
		[pyd]=
		[coffee]=
		[mustache]=
		[hbs]=
		[conf]=
		[ini]=
		[yml]=
		[bat]=
		[jpg]=
		[jpeg]=
		[bmp]=
		[png]=
		[gif]=
		[ico]=
		[twig]=
		[cpp]=
		[c++]=
		[cxx]=
		[cc]=
		[cp]=
		[c]=
		[hs]=
		[lhs]=
		[lua]=
		[java]=
		[sh]=
		[fish]=
		[ml]=λ
		[mli]=λ
		[diff]=
		[db]=
		[sql]=
		[dump]=
		[clj]=
		[cljc]=
		[cljs]=
		[edn]=
		[scala]=
		[go]=
		[dart]=
		[xul]=
		[sln]=
		[suo]=
		[pl]=
		[pm]=
		[t]=
		[rss]=
		[f#]=
		[fsscript]=
		[fsx]=
		[fs]=
		[fsi]=
		[rs]=
		[rlib]=
		[d]=
		[erl]=
		[hrl]=
		[vim]=
		[ai]=
		[psd]=
		[psb]=
		[ts]=
		[jl]=
	)

	local filetype
	local default=
	local exist_check=1
	local input=$1
	local filename="$1"
	# using ## for possibly more than one "." (get after last one):
	local filetype="${filename##*.}"

	if [ ! -z "$filetype" ] && [ ${extensions[$filetype]+$exist_check} ]; then
		local symbol=${extensions[$filetype]}
	else
		local symbol=$default
	fi

	echo "$symbol $1"

	return 0
}

# for now wrap piped portion so uses the same 'subshell'
# @todo fixme - dont use pipe
find $1 -maxdepth 1 -type f -printf "%P\n" | sort | { while read line; do
	 lines="$lines $(devicons_get_filetype_symbol $line) \n"
done

echo -en "$lines \n" | column -n
}

find $1 -maxdepth 1 -mindepth 1 -type d -printf "%P\n" | sort | { while read line; do
	 lines="$lines $(devicons_get_directory_symbol $line) \n"
done

echo -en "$lines \n" | column -n
}
