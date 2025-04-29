#!/bin/bash

# ==========================
# Morse Code Converter Tool
# Author: RAI SULEMAN (Inspired from 3 Body Problem)
# ==========================


set -e

# Display help if --help flag is passed
if [[ "$1" == "--help" ]]; then
    echo "
Morsify - Text to Morse and Morse to Text Encoder/Decoder
Usage:
  morsify                Launch interactive mode
  morsify encode         Encode text or file to morse
  morsify decode         Decode morse to text or file
  morsify --help         Show this help message

Examples:
  morsify encode 'Hello World'       Encode a string of text to morse code
  morsify decode '-- .... . .-.. .-.. --- / .-- --- .-. .-.. -..' Decode a morse string to text
  morsify encode input.txt output.txt Encode content from input.txt to morse and save to output.txt
  morsify decode morse_input.txt decoded_output.txt Decode morse_input.txt to text and save to decoded_output.txt

For more information and to report bugs, visit: https://github.com/codewithmoss/morsify
    "
    exit 0
fi

# If the user hasn't chosen the --help flag, proceed with the rest of the script
echo "Starting Morsify..."


# Define Morse Code Dictionary (standardized with . and - only)
declare -A MORSE_CODE_DICT=(
    ["0"]="-----" ["1"]=".----" ["2"]="..---" ["3"]="...--" ["4"]="....-"
    ["5"]="....." ["6"]="-...." ["7"]="--..." ["8"]="---.." ["9"]="----."
    ["a"]=".-" ["b"]="-..." ["c"]="-.-." ["d"]="-.." ["e"]="."
    ["f"]="..-." ["g"]="--." ["h"]="...." ["i"]=".." ["j"]=".---"
    ["k"]="-.-" ["l"]=".-.." ["m"]="--" ["n"]="-." ["o"]="---"
    ["p"]=".--." ["q"]="--.-" ["r"]=".-." ["s"]="..." ["t"]="-"
    ["u"]="..-" ["v"]="...-" ["w"]=".--" ["x"]="-..-" ["y"]="-.--" ["z"]="--.."
    ["&"]=".-..." ["@"]=".--.-." ["+"]=".-.-." ["$"]="...-..-"
    ["."]=".-.-.-" [":"]="---..." [","]="--..--" [";"]="-.-.-." ["?"]="..--.."
    ["="]="-...-" ["'"]=".----." ["/"]="-..-." ["!"]="-.-.--" ["-"]="-....-"
    ["_"]="..--.-" ["\\"]=".-..-." ["("]="-.--." [")"]="-.--.-"
    [" "]="/" # Space separator
)


# Create Reverse Dictionary for decoding
declare -A REVERSE_MORSE_DICT
for key in "${!MORSE_CODE_DICT[@]}"; do
    REVERSE_MORSE_DICT["${MORSE_CODE_DICT[$key]}"]="$key"
done

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Functions ===============================

# Function to beep for Morse (optional)
play_beep() {
    char="$1"
    if [[ "$char" == "." ]]; then
        echo -n -e "\a"
        sleep 0.1
    elif [[ "$char" == "-" ]]; then
        echo -n -e "\a"
        sleep 0.3
    fi
}

# Function to encode text to Morse
encode_to_morse() {
    local input="$1"
    local output=""

    input=$(echo "$input" | tr '[:upper:]' '[:lower:]')

    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        code="${MORSE_CODE_DICT[$char]}"
        if [[ -n "$code" ]]; then
            output+="$code "
        else
            output+="❌"
        fi
    done

    echo "$output"
}


# Function to decode Morse to text
decode_from_morse() {
    local input="$1"
    local output=""

    for code in $input; do
        char="${REVERSE_MORSE_DICT[$code]}"
        if [[ -n "$char" ]]; then
            output+="$char"
        else
            output+="❌"
        fi
    done

    echo "$output"
}


# Function to get input (manual or file)
get_input_text() {
    echo -e "${CYAN}Choose input source:${NC}"
    echo "1) Manual input"
    echo "2) Read from file"
    read -rp "Choice: " input_choice

    if [[ "$input_choice" == "1" ]]; then
        read -ep "Enter your text or Morse code: " input_text
    elif [[ "$input_choice" == "2" ]]; then
        read -ep "Enter file path: " file_path
        if [[ -f "$file_path" ]]; then
            input_text=$(<"$file_path")
        else
            echo -e "${RED}File not found!${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Invalid input option!${NC}"
        exit 1
    fi
}

# Function to check if input is Morse code
is_morse_code() {
    if [[ "$1" == *"."* && "$1" == *"-"* ]]; then
        return 0  # Valid: contains both dot and dash
    else
        return 1  # Invalid: does not contain Morse code-like symbols
    fi
}


# Function to smartly handle output file saving
smart_save_output() {
    local output="$1"
    local mode="$2" # "encode" or "decode"

    echo -e "${CYAN}Choose output method:${NC}"
    echo "1) Display on screen"
    echo "2) Save to file"
    read -rp "Choice: " output_choice

    if [[ "$output_choice" == "1" ]]; then
        echo -e "${GREEN}Result:${NC}"
        echo "$output"
    elif [[ "$output_choice" == "2" ]]; then
        read -ep "Enter output path (with or without filename): " out_path

        if [[ "$out_path" == */ ]]; then
            # Path ends with slash, only directory given
            if [[ "$mode" == "encode" ]]; then
                out_path="${out_path}morse-code.txt"
            else
                out_path="${out_path}morse-to-text.txt"
            fi
        elif [[ -d "$out_path" ]]; then
            # It's a directory
            if [[ "$mode" == "encode" ]]; then
                out_path="${out_path}/morse-code.txt"
            else
                out_path="${out_path}/morse-to-text.txt"
            fi
        fi

        # Create directory if not exists
        mkdir -p "$(dirname "$out_path")"
        echo "$output" > "$out_path"
        echo -e "${GREEN}Saved to: ${out_path}${NC}"
    else
        echo -e "${RED}Invalid output option!${NC}"
        exit 1
    fi
}

# Main Program ===========================

while true; do
    clear
    echo -e "${GREEN}=== Morse Code Converter ===${NC}"
    echo "Select an option:"
    echo "1) Encode text to Morse code"
    echo "2) Decode Morse code to text"
    echo "3) Exit"
    read -rp "Enter your choice: " choice

    case "$choice" in
        1)
            get_input_text
            encoded_output=$(encode_to_morse "$input_text")
            echo -e "${CYAN}Do you want to hear beeps during encoding? (y/n)${NC}"
            read -rp "Choice: " beep_choice

            if [[ "$beep_choice" =~ ^[Yy]$ ]]; then
                for (( i=0; i<${#encoded_output}; i++ )); do
                    play_beep "${encoded_output:$i:1}"
                    sleep 0.1
                done
            fi

            smart_save_output "$encoded_output" "encode"
            ;;
        2)
            get_input_text

            if is_morse_code "$input_text"; then
                decoded_output=$(decode_from_morse "$input_text")
                smart_save_output "$decoded_output" "decode"
            else
                echo -e "${RED}Input does not look like valid Morse code.${NC}"
            fi
            ;;
        3)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            ;;
    esac

    echo
    read -rp "Press ENTER to continue..."
done

