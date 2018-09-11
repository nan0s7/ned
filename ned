#!/bin/sh

cmd=""
s_line="0"
current_file="file.sh"
modified="0"
seperator=" "
#arr_sep=" "
#arr_sep_len=${#arr_sep}
#old_IFS="$IFS"

count_file_size() {
	file_size="0"
	while read -r line; do
		file_size="$(( file_size + 1 ))"
	done < "$current_file"
}

get_value_r() {
	i=0
#	IFS="$arr_sep"
	for element in $1; do
		if [ "$i" -eq "$2" ]; then
			echo "$element"
		else
			i=$(( i + 1 ))
		fi
	done
}

get_length_r() {
	i=0
	for element in $1; do
		i=$(( i + 1 ))
	done
	echo "$i"
}

check_number_r() {
	number="$1"
	bool=0
	i=1
	while [ "$i" -le "${#number}" ]; do
		number_part=$(expr substr "$number" "$i" 1)
		case $number_part in
			(*[!0-9]*|'') tmp="1";;
			(*) tmp="0";;
		esac
		if [ "$tmp" = "1" ]; then
			bool=1
		fi
		i="$(( i + 1 ))"
	done
	echo "$bool"
}

compare_bools_r() {
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

print_help() {
	echo "Usage: [COMMAND] <ARGUMENT> ... "
}

get_input() {
	read_in=""
	printf "$s_line"": "
	read -r read_in
}

print_lines() {
	start="$1"
	end="$2"
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

check_arg_r() {
	if [ -n "$1" ]; then
		echo "0"
	else
		echo "1"
	fi
}

cut_off_cmd_r() {
	echo $(expr substr "$1" 2 ${#1})
}

# will be replaced by a function that reads a certain position of a string for arguments
set_read_args() {
	tmp="$1"
	num_args="$2"
	# make this more general in the future
	if [ "$num_args" -gt "0" ]; then
		if [ "$num_args" -eq "1" ]; then
			read_arg=$(expr substr "$tmp" 1 ${#tmp})
		elif [ "$num_args" -eq "2" ]; then
			space_location=$(expr index "$tmp" " ")
			read_arg=$(expr substr "$tmp" 1 "$(( space_location - 1 ))")
			read_arg_2=$(expr substr "$tmp" "$(( space_location + 1 ))" ${#tmp})
		fi
	fi
}

check_cmd() {
	full_input_cmd="$1"
	cmd=$(expr substr "$full_input_cmd" 1 1)
	if [ "$cmd" = "p" ]; then
		# p. or something prints the whole file
		# p, or something prints enough of the file to fit on screen
		args=$(cut_off_cmd_r "$full_input_cmd")
		num_args=$(get_length_r "$args")
		set_read_args "$args" "$num_args"
		if [ "$num_args" -eq "2" ]; then
			tmp=$(( $(check_number_r "$read_arg") + $(check_number_r "$read_arg_2") ))
			if [ "$tmp" -eq "0" ]; then
				print_lines "$read_arg" "$read_arg_2"
			else
				echo "At least one argument is not a number"
			fi
		elif [ "$num_args" -eq "1" ]; then
			tmp=$(check_number_r "$read_arg")
			if [ "$tmp" -eq "0" ]; then
				print_lines "$read_arg" "$read_arg"
			elif [ "$read_arg" = "." ]; then
				print_lines "0" "$file_size"
			else
				echo "At least one given argument is invalid"
			fi
		else
			print_lines "$s_line" "$s_line"
		fi
	elif [ "$cmd" = "h" ]; then
		echo "print help information"
		print_help
	elif [ "$cmd" = "l" ]; then
		args=$(cut_off_cmd_r "$full_input_cmd")
		num_args=$(get_length_r "$args")
		set_read_args "$args" "$num_args"
		tmp=$(( $(check_number_r "$read_arg") + $(check_arg_r "$read_arg") ))
		if [ "$tmp" -eq "0" ] && [ "$read_arg" -le "$file_size" ]; then
			s_line="$read_arg"
		else
			echo "$current_file only has $file_size lines"
		fi
	elif [ "$cmd" = "n" ]; then
		# create a new file
		# ask if they want to switch to the new file or stay in current
		# can move text between files
		print "new file"
	elif [ "$cmd" = "s" ]; then
		# check if modified
		# if so ask if overwrite okay
		# overwrite
		echo "save"
	elif [ "$cmd" = "w" ]; then
		# w <string> write the following text to the current line (replace or not?)
		# w, continuous writing mode from current line until the end
		# w <something> <replacement> replace something on current line
		echo "write"
	elif [ "$cmd" = "z" ]; then
		# check for a non-empty buffer (buffer could be a file?)
		# replace last thing in buffer
		# repeat until empty
		echo "undo"
	elif [ "$cmd" = "q" ]; then
		if [ "$modified" -eq "0" ]; then
			exit
		fi
	else
		echo "Invalid command"
	fi
}

reset_read() {
	unset read_arg
	unset read_arg_2
}

main() {
	count_file_size
	a=0
	while a=0; do
		get_input
		check_cmd "$read_in"
		reset_read
	done
}

main
