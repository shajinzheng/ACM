#!/bin/bash

function printHeader {
  echo "# $1"
  echo '| ID | Type | Blog | Solutions | Leetcode | Diffculty | TAGS |'
  echo '|:----:|:----:|:-------:|:----:|:----:|:----:|:----:|'
}

function trim {
  local trimmed="$1"
  # Strip leading space.
  trimmed="${trimmed## }"
  # Strip trailing space.
  trimmed="${trimmed%% }"
  # Strip tailling spaces.
  trimmed=${trimmed%%[[:space:]]}
  echo "$trimmed"
}

count_sql=0
count_algorithms=0

function process {
  local id=`echo $1 | awk '{print substr($1, 0, length($1)-1);}'`
  if [[ -n $(find "$1" -maxdepth 1 -name \*.sql -print -quit) ]]; then
    local type=Database
  else
    local type=Algorithms
  fi
  if [ "$type" != "$2" ]; then
    return 
  fi
  if [ "$type" == "Database" ]; then
    count_sql=$((count_sql+1))
  else
    count_algorithms=$((count_algorithms+1))
  fi
  local question=$(echo $1 | awk '{for (i=2; i<=NF; i++) printf ("%s ",$i);}' )
  question=$(trim "$question")
  local sc=$(ls -1q "$1"/ | wc -l)
  local urlencoded=$(echo "$1" | sed -e 's/ /%20/g')
  local solutions="[$sc](https://github.com/DoctorLai/ACM/tree/master/leetcode/$urlencoded)"
  local ext=$(ls -1 "$1" | sed 's/.*\.//' | sort -u | tr "\n" " ")
  local first=$(ls -1q "$1"/ | head -1)
  local leetcodeurl=$(cat "$1/$first" | grep leetcode | awk '{print $2}')
  local blog=$(cat "$1/$first" | grep helloacm | awk '{print $2}')
  diff=$(cat "$1/$first" | grep "^//" | grep -v "http" | cut -d, -f1 | tr -d "/ ")
  blog=$(trim $blog)
  leetcodeurl=$(trim $leetcodeurl)
  if [ ! -z "$blog" ]; then
    question="[$question]($blog)"
  fi   
  local leetcode=" N/A "
  if [ ! -z "$leetcodeurl" ]; then
    leetcode="[Leetcode]($leetcodeurl)"
  fi
  
  local x=""
  for i in $(ls -1q "$1"); do
      local meta=$(cat "$1/$i" | grep "^//" | grep -v "http")
      x+=$(echo $meta | grep "^//" | grep -v "http" | cut -d, -f2-)
      x+=","
  done
  tags=$(echo $x | tr "," "\n" | sort | uniq)  
  echo "| $id | $type | $question | $solutions<br/>$ext | $leetcode | $diff | $tags |"
}                                               

# Process for Algorithms
printHeader "Algorithms (https://leetcode.com)"
for i in *; do
  if [ -d "$i" ]; then
    process "$i" "Algorithms"
  fi    
done

echo ""
# Process for Database
printHeader "Database"
for i in *; do
  if [ -d "$i" ]; then
    process "$i" "Database"
  fi
done

echo
echo Total \*$((count_sql+count_algorithms))\* Questions: \*$count_sql\* Database, \*$count_algorithms\* Algorithms
echo 
echo '*Index generated by [script](https://github.com/DoctorLai/ACM/blob/master/leetcode/GenerateIndex.sh)* at '$(date)
