#! /usr/bin/env bash

queue_dir="$1" ; shift
results_dir="$1" ; shift
tmp_dir="$1" ; shift

mkdir -p "$tmp_dir"

set -x

while true ; do
    file="$( find "$queue_dir" -type f -iname '*.tiff' | head -n 1 )"
    if [ -z "$file" ] ; then # nothing to do
        break
    fi

    mv "$file" "$tmp_dir/scan.tiff" 2> /dev/null || continue
    hash="$( sha1sum "$tmp_dir/scan.tiff" | cut -d\  -f 1 )"
    date="$( date '+%Y-%m-%d-%H-%M-%S' )"

    (
        set -e
        pushd "$tmp_dir" &> /dev/null
        convert scan.tiff page-%d.tiff
        convert scan.tiff page-%d.pdf
        tesseract -c textonly_pdf=1 scan.tiff ocr -l eng

        num_pages="$( ls -1 page-*.tiff | wc -l )"

        for i in $( seq "$num_pages" ) ; do
            index="$(( i - 1 ))"

            tesseract -c textonly_pdf=1 \
                "page-$index.tiff" "ocr-$index" -l eng --psm 12 pdf

            pdftk "ocr-$index.pdf" \
                background "page-$index.pdf" \
                output "merged-$index.pdf"

        done

        pdfunite $(
        for i in $( seq "$num_pages" ) ; do echo $(( i - 1)) ; done |
            sed 's/\(.*\)/merged-\1.pdf/g' ) final.pdf

        popd &> /dev/null

        mv "$tmp_dir/ocr.txt" "$results_dir/$date-$hash.txt"
        mv "$tmp_dir/final.pdf" "$results_dir/$date-$hash.pdf"

        cd "$tmp_dir"
        rm -rf * .* &> /dev/null
    )
done
