#!/bin/sh

read_in=""
s_line=0
current_file="file.sh"
cmd_list="p h l n s w z q"

count_file_size() {
	file_size="0"
	while read -r line; do
		file_size="$(( file_size + 1 ))"
	done < "$current_file"
}

arr_valx_r() {
	i=0
	for element in $1; do
		if [ "$i" -eq "$2" ]; then
			echo "$element"
			break
		else
			i=$(( i + 1 ))
		fi
	done
}

arr_xval_r() {
	i=0
	output="a"
	for element in $1; do
		if [ "$element" = "$2" ]; then
			output="$i"
			break
		else
			i=$(( i + 1 ))
		fi
	done
	echo "$output"
}

arr_len_r() {
	i=0
	for element in $1; do
		i=$(( i + 1 ))
	done
	echo "$i"
}

# make a word to array function? so 450 > 4 5 0
is_num_r() {
	number="$1"
	bool=0
	i=1
	while [ "$i" -le "${#number}" ]; do
		number_part=$(expr substr "$number" "$i" 1)
		case $number_part in
			(*[!0-9]*|'') tmp=1;;
			(*) tmp=0;;
		esac
		if [ "$tmp" = "1" ]; then
			bool=1
		fi
		i=$(( i + 1 ))
	done
	echo "$bool"
}

g_and_r() {
	if [ "$1" = "0" ]; then
		if [ "$2" = "0" ]; then
			echo 0
		else
			echo 1
		fi
	else
		echo 1
	fi
}

get_input() {
	read_in=""
	printf "$s_line"": "
	read -r read_in
}

pr_lns() {
	start="$1"
	end="$2"
	if ! [ -n "$end" ]; then end="$start"; fi
	i=0
	while read -r line; do
		if [ "$i" -ge "$start" ]; then
			if [ "$i" -le "$end" ]; then
				echo $line
			fi
		fi
		i="$(( i + 1 ))"
	done < "$current_file"
}

make_file() {
	new_file="$1"
	touch "$new_file"
	if [ "$2" = "1" ]; then
		current_file="$new_file"
	fi
}

# error checking here please
exec_p() {
	args="$1"
	case $2 in
		("2") pr_lns $(arr_valx_r "$args" 0) $(arr_valx_r "$args" 1);;
		("1") pr_lns $(arr_valx_r "$args" 0);;
		("0") pr_lns $s_line;;
	esac
}

exec_l() {
	s_line=$(arr_valx_r "$1" 0)
}

exec_q() {
	exit
}

check_cmd() {
	cmd=$(expr substr "$read_in" 1 1)
	args=$(expr substr "$read_in" 2 ${#read_in})
	num_args=$(arr_len_r "$args")

	if [ $(is_num_r $(arr_xval_r "$cmd_list" "$cmd")) -eq "0" ]; then
		case $cmd in
			("p") exec_p "$args" "$num_args";;
			("l") exec_l "$args";;
			("q") exec_q;;
			(*) echo "wut";;
		esac
	else
		echo "Invalid command"
	fi
}

main() {
	count_file_size

	while true; do
		get_input
		check_cmd
	done
}

main
