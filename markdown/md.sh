#!/bin/bash

# Originally created by Binzo on 2017-06-19.

function printUsage() {
    cat << TAGMARK

Usage: md.sh [option] [input-file]...
    [input-file]     文件输入，markdown文件，比如：readme.md，缺省参数默认为当前目录唯一的 .md 文件。
选项：
    --no-table-head  不生成表格头 <thead> </thead>

TAGMARK
}

printHelp() {
    echo "Help: md.sh | Binzo's customized 'markdown2'"
    cat << Help
$(printUsage)
markdown2安装：
sudo apt-get install pip
sudo pip install markdown2
更多详细信息查看 markdown2 命令的帮助信息： markdown2 --help
 - github-markdown.css 来源： https://github.com/sindresorhus/github-markdown-css
   关于这里引用的 github-markdown_customized.css 改变了代码块/段的背景色为黑色
 - monokai_sublime.min.css 来源： http://cdn.bootcss.com/highlight.js/8.0/styles/monokai_sublime.min.css
 - highlight.min.js 来源： http://cdn.bootcss.com/highlight.js/8.0/highlight.min.js

另：此命令输出 html 文档，如果想转换成 pdf，可使用命令：wkhtmltopdf，详情查看：wkhtmltopdf --help
Help
}

FILE_IN=""
FILE_OUT=""
FILE_TMP_SCRIPT=/tmp/tip.js
DIR_SCRIPT="$(dirname $0)/scripts"
TITLE="Binzo's Markdown"
NO_TABLE_HEAD=false

CONTAINS_CODE_BLOCK=false
CONTAINS_SEQUENCE_DIAGRAM=false
CONTAINS_FLOWCHART=false
CONTAINS_NOTE=false

function checkArgs () {
    while [ $# -gt 0 ];do
        case "$1" in
            -h|--help|\?)
                printHelp
                exit 0
                ;;
            --no-table-head)
                NO_TABLE_HEAD=true
                shift
                ;;
            *)
                FILE_IN="$1"
                shift
                ;;
        esac
    done

    if [ -z "${FILE_IN}" ]; then
        # 如果 FILE_IN 缺省，判断当前目录下是否存在唯一 md 文件
        local mds=$(find . -name "*.md")
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
    if [ -f ${FILE_TMP_SCRIPT} ]; then
        rm ${FILE_TMP_SCRIPT}
    fi
}

function genTempTipScript() {
    cat >> "${FILE_TMP_SCRIPT}" << CODE
            var t${idx} =document.getElementById("tip${idx}");
            t${idx}.onclick = function() {
                if (tipId == "tip${idx}") {
                    if (oBox.style.visibility == "visible") {
                        oBox.style.visibility = "hidden";
                        tipId = null;
                        return;
                    }
                }
                //box(this, false, this.innerText + "<br>${note}");
                box(this, false, "${note}");
                tipId = "tip${idx}";
            }
CODE
}

# add for diagram & flowchart. begin
# $1: 输入文件路径-md文件
markDiagrams() {
    local path=/tmp/tmp_diagrams.md
    if [ -f "${path}" ]; then
        rm "${path}"
    fi
    local processing=false
    local isnote=false
    ifs=$IFS; IFS="\n"
    while read -r line; do
        if [[ ${line} == \`\`\`sequence ]]; then
            CONTAINS_SEQUENCE_DIAGRAM=true
            line="\`\`\`\n[[[sequence]]]"
            processing=true
        elif [[ ${line} == \`\`\`flow ]]; then
            CONTAINS_FLOWCHART=true
            line="\`\`\`\n[[[flow]]]"
            processing=true
        elif [[ ${line} == \`\`\` && ${processing} == true ]]; then
            line="[[[end]]]\n\`\`\`"
            processing=false
        elif [[ ${line} == \`\`\`* ]]; then
            CONTAINS_CODE_BLOCK=true
        elif [[ ${line} == *\)\)\(* ]]; then
            CONTAINS_NOTE=true
            temp=${line}
            while [[ ${line} == *\)\)\(* ]]; do
                temp=${temp#*\(\(}
                keyword=${temp%%\)\)*}
                temp=${temp#*\)\)\(}
                index=${temp%%\)*}
                line=${line/\(\(${keyword}\)\)\(${index}\)/<code id=\"tip${index}\">${keyword}</code>}
                #echo ${line}
            done
        elif [[ ${line} =~ \(\([0-9]+\)\) ]]; then
            isnote=true
            note=""  # 清空note变量，多个备注复用
            local idx=${line#*\(\(}
            idx=${idx%\)\)*}
            continue # 备注内容不需要写入HTML，continue
        elif [[ ${line} =~ \(\(/\)\) ]]; then
            isnote=false
            genTempTipScript
            continue # 备注内容不需要写入HTML，continue
        elif ${isnote}; then
            if [ -z "${note}" ]; then
                note="${line}"
            else
                note="${note}<br>${line}"
            fi
            continue # 备注内容不需要写入HTML，continue
        fi
        #echo "${line}"
        echo -e "${line}" >> "${path}"
    done < "${1}"
    IFS=${ifs}
    FILE_IN=${path}
    #echo "${path}"
}

parseDiagrams() {
    local path="/tmp/tmp_diagrams.html"
    if [ -f "${path}" ]; then
        rm "${path}"
    fi
    local isTableHead=false  # 当指定不要生成表格头的时候，将<thead></thead>过滤掉
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
            #echo "检测到‘时序图’"
            line="<div id=\"diagram${idxDiagram}\" class=\"diagram\"></div>\n<script>\n  var diagram${idxDiagram} = Diagram.parse('' +"
            isDiagram=true
        elif [[ ${line} == \<pre\>\<code\>\[\[\[flow\]\]\] ]]; then
            #echo "检测到‘流程图’"
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
        # Added for NO_TABLE_HEAD. begin
        elif [[ ${line} == \<thead\> ]]; then
            #echo "<thead>"
            isTableHead=true
        elif [[ ${line} == \</thead\> ]]; then
            #echo "</thead>"
            isTableHead=false
            continue
        # Added for NO_TABLE_HEAD. end
        elif [[ ${isDiagram} == true || ${isFlow} == true ]]; then
            line=${line//&gt;/>}
            line=${line//&lt;/<}
            echo "'${line}\n' +" >> "${path}"
            continue
        fi
        # Added for NO_TABLE_HEAD. begin
        if [[ ${NO_TABLE_HEAD} == true && ${isTableHead} == true ]]; then
            continue
        fi
        # Added for NO_TABLE_HEAD. end
        #echo "${line}"
        echo -e "${line}" >> "${path}"
    done < "${1}"
    IFS=${ifs}
    mv "${path}" "${1}"
}
# add for diagram & flowchart. end

includeScripts() {
    if [[ ${CONTAINS_CODE_BLOCK} == true ]]; then
        echo "检测到‘代码块’，引入代码块高亮库"
        cat >> "${FILE_OUT}" << CODE
        <link rel="stylesheet" href="${DIR_SCRIPT}/monokai_sublime.min.css">
        <script src="${DIR_SCRIPT}/highlight.min.js"></script>
        <script >hljs.initHighlightingOnLoad();</script>
CODE
    fi
    if [[ ${CONTAINS_SEQUENCE_DIAGRAM} == true ]]; then
        echo "检测到‘时序图’，引入时序图绘制库"
        cat >> "${FILE_OUT}" << CODE
        <script src="${DIR_SCRIPT}/webfont.js"></script>
        <script src="${DIR_SCRIPT}/snap.svg-min.js"></script>
        <script src="${DIR_SCRIPT}/underscore-min.js"></script>
        <script src="${DIR_SCRIPT}/sequence-diagram-min.js"></script>
CODE
    fi
    if [[ ${CONTAINS_FLOWCHART} == true ]]; then
        echo "检测到‘流程图’，引入流程图绘制库"
        cat >> "${FILE_OUT}" << CODE
        <script src="${DIR_SCRIPT}/raphael.min.js"></script>
        <script src="${DIR_SCRIPT}/flowchart-latest.js"></script>
CODE
    fi
    if ${CONTAINS_NOTE}; then
        echo "检测到‘备注’，引入备注弹框脚本"
        cat >> "${FILE_OUT}" << CODE
            <style type="text/css">
                #box {
                    background-color: rgba(0,0,0,0.95);
                    position: absolute;
                    border:3px solid white;
                    border-radius: 8px;
                    overflow: auto;
                    color:#fff;
                    padding:10px;
                    visibility:hidden;
                }
            </style>
CODE
    fi
}

main() {
    checkArgs "$@"

    local title=$(grep "^# " "${FILE_IN}" | head -n1)
    if [ -n "${title}" ]; then
        TITLE=${title#*# }
        echo "检测到‘一级标题’：《${TITLE}》"
    fi

    markDiagrams "${FILE_IN}"

cat > "${FILE_OUT}" << CODE
<!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, minimal-ui">
        <title>${TITLE}</title>

        <!-- 排版样式.START -->
        <link rel="stylesheet" href="${DIR_SCRIPT}/github-markdown_customized.css">
        <style type="text/css">
            body {
                box-sizing: border-box;
                min-width: 200px;
                max-width: 980px;
                margin: 0 auto;
                padding: 10px;
            }
            table {
                min-width: body.clientWidth;
            }
        </style>
        <!-- 排版样式.END -->
CODE
includeScripts
cat >> "${FILE_OUT}" << CODE
    </head>
    <body>
        <article class="markdown-body">
CODE

markdown2 --encoding=utf-8 --html4tags --extras=fenced-code-blocks,cuddled-lists,metadata,tables,spoiler "${FILE_IN}" >> "${FILE_OUT}"

parseDiagrams "${FILE_OUT}"

if ${CONTAINS_NOTE}; then
cat >> "${FILE_OUT}" << CODE
        <div id="box"></div>
        <script>
            var boxWidth = 260;
            var boxHeight = 100;
            var boxId = 'box';
            var tipId = null;
            var tipObj = null;
            var boxHtml = "";
            var oBox = document.getElementById(boxId);

            function box(obj, isResize, html) {
                tipObj = obj;
                boxHtml = html;
                oBox.style.width= boxWidth + 'px';
                oBox.style.height=boxHeight + 'px';
                oBox.style.position = "absolute";
                oBox.style.display = "block";
                var L1 = boxWidth; //oBox.offsetWidth;    //获取元素自身的宽度
                var H1 = boxHeight; //oBox.offsetHeight;    //获取元素自身的高度
                var Left = (document.documentElement.clientWidth-L1)/2; //获取实际页面的left值。（页面宽度减去元素自身宽度/2）
                var Top = (document.documentElement.clientHeight-H1)/2;   //获取实际页面的top值。（页面宽度减去元素自身高度/2）
                //Left+=document.body.scrollLeft;
                //Top+=document.body.scrollTop;
                oBox.style.left = Left + 'px';
                oBox.style.top = Top + 'px';

                oBox.onclick = function() {
                    oBox.style.visibility = "hidden";
                };

                if (obj != null) {
                    var Top = obj.offsetTop - boxHeight;
                    if ( Top < 10 ) {
                        Top = obj.offsetTop + 20;
                    }
                    oBox.style.top = Top + 'px';
                    oBox.innerHTML = html;
                    if (isResize == false) {
                        // isResize: 如果是 window resize 事件，不改变显示状态
                        oBox.style.visibility = "visible";
                    }
                }
            }
            window.onresize = function() {
                box(tipObj, true, boxHtml);
            }
            box(null, true, ""); // 加载时执行一次
            /*
            // 示例如下：
            var tip =document.getElementById("tip");
            tip.onclick = function() {
                if (tipId == "tip") {
                    if (oBox.style.visibility == "visible") {
                        oBox.style.visibility = "hidden";
                    }
                }
                box(this, false, this.innerText + "<br>这是“tip”<br>可以折行");
                tipId = "tip";
            }
            */
$(cat ${FILE_TMP_SCRIPT})
        </script>
CODE
fi
        cat >> "${FILE_OUT}" << CODE
        <br>
        <hr style="height:1px;border:none;border-top:1px dashed #f6f8fa;" />
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
