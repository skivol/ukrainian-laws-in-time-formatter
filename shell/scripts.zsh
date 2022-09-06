# git follow (https://stackoverflow.com/a/8808453)
# log format (https://devhints.io/git-log-format)
# iterate over multiline string (https://unix.stackexchange.com/a/578489)
# non interactive git (https://superuser.com/a/1630304)
# diff to html https://github.com/rtfpessoa/diff2html-cli
generate-htmls-of-changes-for-a-document() {
	local prev=
	for revision in $(git log --reverse --pretty="format:%h" --follow -- "$1"); do
		local editionDate=$(git log --pretty=oneline -n 1 $revision | rg -v "Конвертація" | rg -o "..\...\.....")
		if [[ -z "$prev" || -z $editionDate ]]; then
			# skipping first revision where document was added or conversion to pandoc markdown
			echo "skipping $revision"
			prev=$revision
			continue
		fi;

		editionDate="${editionDate:6:4}.${editionDate:3:2}.${editionDate:0:2}"
		# local editionDate=$(git log --pretty=oneline -n 1 $revision | rg -o "від (\\d{8})" -r '$1')
		# editionDate="${editionDate:0:4}.${editionDate:4:2}.${editionDate:6:2}"
		# echo "$editionDate"
		# sleep 4
		# --matching lines / words
		# --style side
		gd $prev $revision -- $1 | diff2html --hwt $(zq formatter/html)/template.html -i stdin -o stdout > "${editionDate}.html"
		prev=$revision
	done
}
generate-pdf-from-html() {
	# pandoc --pdf-engine=xelatex -V mainfont='Open Sans Light' -V geometry:"top=2cm, bottom=1.5cm, left=2cm, right=2cm" $1 -o $1.pdf
	#
	# https://wkhtmltopdf.org/
	# https://wkhtmltopdf.org/usage/wkhtmltopdf.txt
	# wkhtmltopdf $1 ${1%.html}.pdf

	# https://superuser.com/a/1211603
	# https://github.com/microsoft/WSL/issues/7915#issuecomment-1163333151
	# https://stackoverflow.com/questions/46077392/additional-options-in-chrome-headless-print-to-pdf
	google-chrome --headless --disable-gpu --print-to-pdf-no-header --print-to-pdf=${1%.html}.pdf $1
}
generate-editions-latex() {
	local targetFile=editions.tex
	echo "\\onecolumn
\\section{Зміни у тексті видань різного часу}" > $targetFile
	for edition in $(ls $1/*.pdf); do
		local basenameEdition=$(basename $edition)
		echo "\\subsection{${basenameEdition%.pdf}}
\\includepdf[pages=-]{$1/$basenameEdition}" >> $targetFile
	done
}

extra-markup() {
	# TODO organize this into separate sed script ?

	# https://linuxhint.com/50_sed_command_examples/#s41
	# https://stackoverflow.com/a/12179641
	# 3 and 1 line variants
	# https://stackoverflow.com/questions/148451/how-to-use-sed-to-replace-only-the-first-occurrence-in-a-file
	cat $1 | sed '1N;$!N;s/\(ЗАКОН УКРАЇНИ\)\n\n\(.*\)/# \1\n\n# \2/;P;D' \
		| sed 's/\(КОНСТИТУЦІЯ УКРАЇНИ\)/# \1/' \
		| sed -E '/^(Розділ|Раздел|Частина|Часть)\s/IN;s/(.+)\n(.*)/\n# \1. \2/;P;D' \
		| sed -E '/^.{1,2}\\\.\s[[:upper:]]{4,}/s/(.+)/\n# \1/' \
		| sed -E '/^(Глава|Підрозділ)/Is/(.+)/\n## \1/' \
		| sed -E 's/^(Стаття|Статья)/\n### \1/' \
		| sed -E "s/\| \[УКТ   /\| УКТ ЗЕД/g" | sed -E "s/\| 4%D0%B0-18\)/\|            /g" | sed -E "s/\| ЗЕД\]\(\/go\/58/\|            /g" \
		| sed -E "s/\| ЗЕ? /|    /g" | sed -E "s/\| З /\|   /g" | sed -E "s/\| Е?Д\]\(\/go\/[0-9]{3,4}%D0%B[0-9]-[0-9]{2}\)/\|                      /g" \
		| sed -E "s/ ЕД\]\(\/go\/674%D0%B1-20\)/                      /g" \
		| sed -E 's/\[УКТ ЗЕД\]\(\/go/\0no/g' \
		| sed 's/\/go\//https:\/\/zakon.rada.gov.ua\/laws\/show\//g' \
		| sed -E 's/\/gono\//\/go\//g' \
		| sed -E 's/^(.{1,3}(\)|\\.)\s)?(((\w|-){3,}( \w{1,2})?,?\s(\(.*\)\s)?){1,15})-/\1**\3**-/' \
		| sed -E 's/(\{[^#]+\})/*\1*/g' \
		| sed '0,/\\\[ image \\\]/s//![](.\/gerb.gif "Герб України")/'

	# Current
	# | sed -E '/^(Розділ|Раздел|Частина|Часть)\s[1-9IVX]/Is/(.+)/\n# \1/' \
	#
	# Something complex (with empty line separating chapter number and its name)
	# | sed -E '/^(Розділ|Раздел|Частина|Часть)\s/IN;N;s/(.+)\n(.*)\n([^\[]+)/# \1. \2\3/;P;D' \
	#
	# Constitution (chapter name on the next line)
	# | sed -E '/^(Розділ|Раздел|Частина|Часть)\s/IN;s/(.+)\n(.*)/\n# \1. \2/;P;D'
	#
	# | sed -E '/^Глава/IN;N;s/(.+)\n(.*)\n([^\[]+)/## \1. \2\3/;P;D' \
	#
	# | sed 's/\\\[ image \\\]/![](.\/gerb.gif "Герб України")/'
	# | sed 's/\\\[ image \\\]/![](https:\/\/zakonst.rada.gov.ua\/images\/gerb.gif "Герб України")/'
}
view-doc-with-extra-markup() {
	# https://linuxhint.com/50_sed_command_examples/#s11
	extra-markup $1 | glow -p -
}
alias view-doc=view-doc-with-extra-markup

# https://pandoc.org/MANUAL.html?pandocs-markdown
# https://jdhao.github.io/2019/05/30/markdown2pdf_pandoc/
# https://medium.com/productivity-revolution/10-best-fonts-for-improving-reading-experience-6171ce199e97
# https://stackoverflow.com/questions/25037357/pandoc-long-tablerows-in-markdown-pdf-documents-do-not-get-linewrap
# https://pandoc.org/MANUAL.html#tables
# https://duckduckgo.com/?q=latex+longtable+page+width+to+fit+content&ia=web
# https://duckduckgo.com/?q=latex+change+page+width+to+fit+wide+longtable&ia=web
# https://texblog.org/2011/05/15/multi-page-tables-using-longtable/
# https://www.google.com/search?sxsrf=ALiCzsY8sI3I8FgL6TtMyiw9g0v0jGK5wA:1658700044096&q=LaTeX+longtable+wrap+text&sa=X&ved=2ahUKEwjt1KqXw5L5AhWsBxAIHcSlAG0Q1QJ6BAgoEAE&biw=1536&bih=792&dpr=1.25
# https://stackoverflow.com/questions/27219629/how-can-i-control-cell-width-in-a-pandoc-markdown-table

# https://stackoverflow.com/questions/43658817/pandoc-html-to-markdown-non-html-tables
generate-pdf-for-a-document() {
	# Montserrat Light
	# Merriweather Light
	# -V toc-title='Зміст' -V mainfont='Open Sans Light' -V geometry:"top=2cm, bottom=1.5cm, left=2cm, right=2cm" -V colorlinks -V urlcolor=Blue -V toccolor=Black

	extra-markup $1 | pandoc --pdf-engine=xelatex --metadata-file=$(zq formatter/configs)/config.yml -B $(zq formatter/tex)/credits.tex -H $(zq formatter/tex)/preamble.tex -f markdown -t pdf --toc "${@:2}" -o $1.pdf -
}

# Longtable in 2 column document
# https://github.com/jgm/pandoc/issues/1023

doc-to-pdf() {
	libreoffice --headless --convert-to pdf --outdir . $1
}

pdf-with-changes() {
	local targetFile=$1
	z laws-in-time
	generate-htmls-of-changes-for-a-document $targetFile
	local appendices=()
	if [ -n "$2" ]; then
		appendices=(-A $2)
	fi;
	local editions=()

	if ls *.html; then
		for f in *.html; do; generate-pdf-from-html "$f"; done
		generate-editions-latex .
		editions=(-A editions.tex)
	fi

	generate-pdf-for-a-document $targetFile "${appendices[@]}" "${editions[@]}"
	mv $targetFile.pdf $(zq Desktop)
	rm *.html *.pdf
}

