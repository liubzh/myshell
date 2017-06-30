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
DIR_SCRIPT="$(dirname $0)/scripts"
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
    elif [[ ${FILE_IN} != *.md ]]; then
        echo "输入文件扩展名必须为.md"
        exit 1
    fi
    if [ -z "${FILE_OUT}" ]; then
        local fname=$(basename ${FILE_IN})
        FILE_OUT=$(dirname ${FILE_IN})/${fname%.md*}.html
    fi
}

# add for diagram & flowchart. begin
# $1: 输入文件路径-md文件
markDiagrams() {
    local path=/tmp/tmp_diagrams.md
    if [ -f ${path} ]; then
        rm ${path}
    fi
    local processing=false
    ifs=$IFS; IFS="\n"
    while read -r line; do
        if [[ ${line} == \`\`\`sequence ]]; then
            line="\`\`\`\n[[[sequence]]]"
            processing=true
        elif [[ ${line} == \`\`\`flow ]]; then
            line="\`\`\`\n[[[flow]]]"
            processing=true
        elif [[ ${line} == \`\`\` ]]; then
            if ${processing}; then
                line="[[[end]]]\n\`\`\`"
                processing=false
            fi
        fi
        #echo "${line}"
        echo -e "${line}" >> ${path}
    done < ${1}
    IFS=${ifs}
    FILE_IN=${path}
    #echo ${path}
}

parseDiagrams() {
    local path=/tmp/tmp_diagrams.html
    if [ -f ${path} ]; then
        rm ${path}
    fi
    local idxDiagram=1
    local isDiagram=false
    local idxFlow=1
    local isFlow=false
    # 目的：改为以下格式
    #<div id="diagram1"></div>
    #<script>
    #  var diagram1 = Diagram.parse("Alice->Bob: Hello Bob, how are you?\nNote right of Bob: Bob thinks\nBob-->Alice: I am good thanks!");
    #  diagram1.drawSVG("diagram1", {theme: 'simple'});
    #</script>
    #<div id="flowchart1"></div>
    #<script>
    #  var flowchart1 = flowchart.parse('st=>start: 开始\ne=>end: 结束\nop=>operation: 我的操作\ncond=>condition: 确认？\n\nst->op->cond\ncond(yes)->e\ncond(no)->op");
    #  flowchart1.drawSVG("flowchart1", {'line-width': 2});
    #</script>
    local line=""
    ifs=$IFS; IFS="\n"
    while read -r line; do
        if [[ ${line} == \<pre\>\<code\>\[\[\[sequence\]\]\] ]]; then
            echo "检测到 Diagram"
            line="<div id=\"diagram${idxDiagram}\" class=\"diagram\"></div>\n<script>\n  var diagram${idxDiagram} = Diagram.parse('' +"
            isDiagram=true
        elif [[ ${line} == \<pre\>\<code\>\[\[\[flow\]\]\] ]]; then
            echo "检测到 Flowchart"
            line="<div id=\"flowchart${idxFlow}\" class=\"diagram\"></div>\n<script>\n var flowchart${idxFlow} = flowchart.parse('' +"
            isFlow=true
        elif [[ ${line} == \[\[\[end\]\]\] ]]; then
            continue
        elif [[ ${line} == \<\/code\>\<\/pre\> ]]; then
            if [[ ${isDiagram} == true ]]; then
                #echo "检测到 Diagram 结束标签"
                line="'');\n  diagram${idxDiagram}.drawSVG(\"diagram${idxDiagram}\", {theme: 'simple'});\n</script>"
                ((idxDiagram++))
                isDiagram=false
            elif [[ ${isFlow} == true ]]; then
                #echo "检测到 Flowchart 结束标签"
                line="'');\n  flowchart${idxFlow}.drawSVG(\"flowchart${idxFlow}\", {'line-width': 2});\n</script>"
                ((idxFlow++))
                isFlow=false
            fi
        elif [[ ${isDiagram} == true || ${isFlow} == true ]]; then
            line=${line//&gt;/>}
            line=${line//&lt;/<}
            echo "'${line}\n' +" >> ${path}
            continue
        fi
        #echo "${line}"
        echo -e "${line}" >> ${path}
    done < ${1}
    IFS=${ifs}
    mv ${path} ${1}
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
  
    BOWER_HOME_DIR=/home/binzo/github/bower-home-diagram/bower_components

cat > ${FILE_OUT} << CODE
<!doctype html>
<html>
    <head>
	    <meta charset="utf-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1, minimal-ui">
	    <title>${TITLE}</title>

        <!-- github markdown css. begin -->
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
        <!-- github markdown css. end -->

        <link rel="stylesheet" href="${DIR_SCRIPT}/monokai_sublime.min.css">
        <script src="${DIR_SCRIPT}/highlight.min.js"></script>
        <script >hljs.initHighlightingOnLoad();</script>

        <script src="${BOWER_HOME_DIR}/bower-webfontloader/webfont.js" />
        <script src="${BOWER_HOME_DIR}/snap.svg/dist/snap.svg-min.js" />
        <script src="${BOWER_HOME_DIR}/underscore/underscore-min.js" />
        <script src="${BOWER_HOME_DIR}/js-sequence-diagrams/dist/sequence-diagram-min.js" />
        <link href="${BOWER_HOME_DIR}/js-sequence-diagrams/dist/sequence-diagram-min.css" rel="stylesheet" />
        <script src="${BOWER_HOME_DIR}/raphael/raphael.min.js"></script>

        <!-- flowchart. begin
        <script src="${DIR_SCRIPT}/raphael.min.js"></script>
        <script src="${DIR_SCRIPT}/flowchart-latest.js"></script>
        flowchart. end -->
    </head>
    <body>
	    <article class="markdown-body">
CODE

markdown2 --encoding=utf-8 --html4tags --extras=fenced-code-blocks,cuddled-lists,metadata,tables,spoiler ${FILE_IN} >> ${FILE_OUT}

parseDiagrams ${FILE_OUT}

cat >> ${FILE_OUT} << CODE
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