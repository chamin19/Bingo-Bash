#chamin   Amin   Camillia   501071556  4

#!/bin/bash

if ! [ -f $1 ] || ! [ -r $1 ] || [ $# -eq 0 ]; then
  echo $ "input file missing or unreadable" > /dev/stderr
  exit 1
fi

inputFile=$1
read seed < $inputFile
numLines=`wc -l < $inputFile`

if [ $numLines -ne 6 ]; then
  echo $ "input file must have 6 lines" > /dev/stderr
  exit 2
fi

nums=`tail -5 < $inputFile`
numOfNums=`wc -w <<< $nums`
line1Words=`echo $seed | wc -w`

row1=`head -2 $inputFile | tail -1` ; numRow1=`wc -w <<< $row1`
row2=`head -3 $inputFile | tail -1` ; numRow2=`wc -w <<< $row2`
row3=`head -4 $inputFile | tail -1` ; numRow3=`wc -w <<< $row3`
row4=`head -5 $inputFile | tail -1` ; numRow4=`wc -w <<< $row4`
row5=`tail -1 $inputFile` ; numRow5=`wc -w <<< $row5`


if [ $line1Words -ne 1 ] ; then
  echo $ "seed line format error" > /dev/stderr
  exit 3
fi

if [[ $seed =~ [^[:digit:]] ]] ; then
  echo $ "seed line format error" > /dev/stderr
  exit 3
fi

if [ $numOfNums -ne 25 ] || [ $numRow1 -ne 5 -o $numRow2 -ne 5 -o $numRow3 -ne 5 -o $numRow4 -ne 5 -o $numRow5 -ne 5 ] ; then
  echo $ "card format error" > /dev/stderr
  exit 4
fi

declare -A arr
declare -A tempArr
declare -A allCalls
callList=""
RANDOM=$seed


fill_array () {
  local -i i=0
  for n in $nums; do
    arr[$i]="$n "
    i+=1
  done
}

marked_row () {
  for i in {0..20..5}; do
    if [[ "${arr[$i]}" =~ "m" ]] && [[ "${arr[$(($i+1))]}" =~ "m" ]] &&
       [[ "${arr[$(($i+2))]}" =~ "m" ]] && [[ "${arr[$(($i+3))]}" =~ "m" ]] &&
       [[ "${arr[$(($i+4))]}" =~ "m" ]]; then
       return 0
    fi
  done
  return 1
}

marked_column () {
  for i in {0..4..1}; do
    if [[ "${arr[$i]}" =~ "m" ]] && [[ "${arr[$(($i+5))]}" =~ "m" ]] &&
       [[ "${arr[$(($i+10))]}" =~ "m" ]] && [[ "${arr[$(($i+15))]}" =~ "m" ]] &&
       [[ "${arr[$(($i+20))]}" =~ "m" ]]; then
       return 0
    fi
  done
  return 1
}

marked_corners () {
  if [[ "${arr[0]}" =~ "m" ]] && [[ "${arr[4]}" =~ "m" ]] &&
     [[ "${arr[20]}" =~ "m" ]] && [[ "${arr[24]}" =~ "m" ]]; then
     return 0
  else
     return 1
  fi
}

is_winner () {
  if marked_column || marked_row || marked_corners; then
    return 0
  else
    return 1
  fi
}

all_possible_calls () {
  for i in {1..75..1}; do
    if [ "$i" -gt 0 -a "$i" -le 15 ]; then
      allCalls[$i]="L"$(printf "%02d" $i)
    fi
    if [ "$i" -gt 15 -a "$i" -le 30 ]; then
      allCalls[$i]="I$i"
    fi
    if [ "$i" -gt 30 -a "$i" -le 45 ]; then
      allCalls[$i]="N$i"
    fi
    if [ "$i" -gt 45 -a "$i" -le 60 ]; then
      allCalls[$i]="U$i"
    fi
    if [ "$i" -gt 61 -a "$i" -le 75 ]; then
      allCalls[$i]="X$i"
    fi
  done
}

#$1: string of next call
add_to_callList () {
  callList+="$1 "
}

generate_call () {
  index=$((1 + $RANDOM % 75))
  newCall=$(echo "${allCalls[$index]}")
  while [[ $callList =~ $newCall ]]; do
    newCall=$(echo "${allCalls[$((1 + $RANDOM % 75))]}")
  done
  callList+=" $newCall"
}

find_call () {
  for i in {0..24..1}; do
    [ $i -eq 12 ] && continue
    local number=`echo "${arr[$i]}" | cut -c1-2`
    if [[ $number =~ "$1" ]]; then
      arr[$i]="$1m"
    fi
  done
}

#$1: most recent callNum
in_card () {
  if [[ $nums =~ $1 ]] ; then
    find_call $1
  fi
}

display_card () {
  echo -e "CALL LIST:$callList"
  echo -e " L   I   N   U   X "
  for i in {0..24..5}; do
    echo "${arr[$i]} ${arr[$(($i+1))]} ${arr[$(($i+2))]} ${arr[$(($i+3))]} ${arr[$(($i+4))]}"
  done
}

has_dups () {
  for n in $nums; do
    if grep -q "$n" <<< "${tempArr[*]}" ; then
      return 0
    fi
    tempArr+="$n "
  done
  return 1
}

has_bad_char () {
  for n in $nums; do
    if ! [[ "$n" =~ ^[[:digit:]]+$ ]]; then
      return 0
    fi
  done
  return 1
}


has_wrong_numbers () {
  if [ "${arr[12]}" != "00 " ] ; then
    return 0
  fi

  for i in {0..24..5}; do
    if [ "${arr[$i]}" -lt 1 -o "${arr[$i]}" -gt 15 ] ||
       [ "${arr[$(($i+1))]}" -lt 16 -o "${arr[$(($i+1))]}" -gt 30 ] ||
       [ "${arr[$(($i+3))]}" -lt 46 -o "${arr[$(($i+3))]}" -gt 60 ] ||
       [ "${arr[$(($i+4))]}" -lt 61 -o "${arr[$(($i+4))]}" -gt 75 ]; then
       return 0
    fi
  done

  for i in {2..22..5}; do
    [ "$i" -eq 12 ] && continue
    if [ "${arr[$i]}" -lt 31 ] || [ "${arr[$i]}" -gt 45 ]; then
      return 0
    fi
  done
  return 1
}

if has_dups || has_bad_char ; then
  echo $ "card format error" > /dev/stderr
  exit 4
fi

fill_array

if has_wrong_numbers ; then
  echo $ "card format error" > /dev/stderr
  exit 4
fi

all_possible_calls

play_game () {
  clear
  arr[12]="00m"
  while [ true ] ; do
    clear
    display_card
    if is_winner ; then
      echo -e "WINNER"
      exit 0
    fi
    read -n 1 -r -p "enter any key to get a call or q to quit: " userInput
    if [ "$userInput" == "q" ]; then
      exit 0
    fi
    generate_call
    currentCall=${callList: -2}
    if [ ${#currentCall} -eq 1 ] ; then
      currentCall="0$currentCall"
    fi
    in_card $currentCall

  done
} 

play_game