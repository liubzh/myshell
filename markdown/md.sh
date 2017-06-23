#!/bin/bash

# Originally created by Binzo on 2017-06-19.

function printUsage() {
    cat << TAGMARK

Usage: md.sh [input-file] [output-file]
    [input-file]     文件输入，markdown文件，比如：readme.md，缺省参数默认为当前目录唯一的 .md 文件。
    [output-file]    文件输出，html文件，比如：readme.html，缺省值为当前目录下与 md 同名的 html 文件。

TAGMARK
}

printHelp() {
    echo "Help: md.sh | Binzo's customized 'markdown2'"
    cat << Help
$(printUsage)

更多详细信息查看 markdown2 命令的帮助信息： markdown2 --help
 - github-markdown.css 来源： https://github.com/sindresorhus/github-markdown-css
   关于这里引用的 github-markdown_customized.css 改变了代码块/段的背景色为黑色
 - monokai_sublime.min.css 来源： http://cdn.bootcss.com/highlight.js/8.0/styles/monokai_sublime.min.css
 - highlight.min.js 来源： http://cdn.bootcss.com/highlight.js/8.0/highlight.min.js

另：此命令输出 html 文档，如果想转换成 pdf，可使用命令：wkhtmltopdf，详情查看：wkhtmltopdf --help
Help
}

FILE_IN="$1"
FILE_OUT="$2"
DIR_SCRIPT="$(dirname $0)/script"
TITLE="Binzo's Article"

function checkArgs () {
    while [ $# -gt 0 ];do
        case "$1" in
            -h|--help|\?)
                printHelp
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done

    if [ -z "${FILE_IN}" ]; then
        # 如果 FILE_IN 缺省，判断当前目录下是否存在唯一 md 文件
        local mds=$(find . -name *.md)
        local count=$(echo ${mds} | wc -w)
        if [ ${count} -eq 1 ]; then
            FILE_IN=${mds}
            echo "检索到 md 文档： ${mds}"
        else
            printUsage
            exit 1
        fi
    fi
    if [ -z "${FILE_OUT}" ]; then
        local fname=$(basename ${FILE_IN})
        FILE_OUT=$(dirname ${FILE_IN})/${fname%.md*}.html
    fi
}

# add for diagram & flowchart. begin
# $1: 输入文件路径-md文件
markDiagrams() {
    local path=/tmp/md_diagrams.tmp
    if [ -f ${path} ]; then
        rm ${path}
    fi
    local processing=false
    ifs=$IFS; IFS="\n"
    while read -r line; do
        if [[ ${line} == \`\`\`sequence ]]; then
            line=[[[sequence]]]
            processing=true
        elif [[ ${line} == \`\`\`flow ]]; then
            line=[[[flow]]]
            processing=true
        elif [[ ${line} == \`\`\` ]]; then
            if ${processing}; then
                line=[[[end]]]
                processing=false
            fi
        fi
        echo "${line}"
        echo "${line}" >> ${path}
    done < ${1}
    IFS=${ifs}
}

parseDiagrams() {
    :

}
# add for diagram & flowchart. end

main() {
    checkArgs "$@"

    local title=$(grep "^# " ${FILE_IN} | head -n1)
    if [ -n "${title}" ]; then
        TITLE=${title#*# }
        echo "检测到一级标题：《${TITLE}》"
    fi

    markDiagrams ${FILE_IN}

cat > ${FILE_OUT} << CODE
<!doctype html>
<html>
    <head>
	    <meta charset="utf-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1, minimal-ui">
	    <title>${TITLE}</title>
        <!-- github markdown css -->
	    <link rel="stylesheet" href="${DIR_SCRIPT}/github-markdown_customized.css">
	    <style>
		    body {
			    box-sizing: border-box;
			    min-width: 200px;
			    max-width: 980px;
			    margin: 0 auto;
			    padding: 45px;
		    }
	    </style>
        <!-- code block highlight css. begin -->
	    <link rel="stylesheet" href="${DIR_SCRIPT}/monokai_sublime.min.css">
        <script src="${DIR_SCRIPT}/highlight.min.js"></script>
        <script >hljs.initHighlightingOnLoad();</script>
        <!-- code block highlight css. end -->
        <!-- sequence diagram. begin -->
        <script src="${DIR_SCRIPT}/webfont.js"></script>
        <script src="${DIR_SCRIPT}/snap.svg-min.js"></script>
        <script src="${DIR_SCRIPT}/underscore-min.js"></script>
        <script src="${DIR_SCRIPT}/sequence-diagram-min.js"></script>
        <!-- sequence diagram. end -->raphael.min.js
        <!-- flowchart. begin -->
        <script src="${DIR_SCRIPT}/raphael.min.js"></script>
        <script src="${DIR_SCRIPT}/flowchart-latest.js"></script>
        <!-- flowchart. end -->
        <!-- uml. end -->
    </head>
    <body>
	    <article class="markdown-body">
CODE

markdown2 --encoding=utf-8 --html4tags --extras=fenced-code-blocks,cuddled-lists,metadata,tables,spoiler ${FILE_IN} >> ${FILE_OUT}

cat >> ${FILE_OUT} << CODE
        <div id="diagram1"></div>
        <script>
          var diagram1 = Diagram.parse("Alice->Bob: Hello Bob, how are you?\nNote right of Bob: Bob thinks\nBob-->Alice: I am good thanks!");
          diagram1.drawSVG("diagram1", {theme: 'simple'});
        </script>
        <div id="flowchart1"></div>
        <script>
          var flowchart1 = flowchart.parse('st=>start: 开始\ne=>end: 结束\nop=>operation: 我的操作\ncond=>condition: 确认？\n\nst->op->cond\ncond(yes)->e\ncond(no)->op");
          flowchart1.drawSVG("flowchart1", {'line-width': 2});
        </script>

        <br>
        <hr style="height:1px;border:none;border-top:1px dashed #999999;" />
        <p>Originally created by <a href="liubingzhao@aliyun.com" title="liubingzhao@aliyun.com">Binzo</a>.</p>
    </body>
</html>
CODE

    if [ -f "${FILE_OUT}" ]; then
        echo "输出到文件： ${FILE_OUT}"
        #firefox ${FILE_OUT}
    fi
    

}

main "$@"
