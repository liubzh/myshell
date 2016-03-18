#!/bin/bash
#Author:k-touch,liubzh

# 打印帮助信息
function print_help() {
cat <<HELP
diff_gen: 在repo目录下生成所有提交的patch。
  -d/--directory:  指定文件输出的目录。
  -h/--help:       打印帮助信息。
  -m/--modules:    指定模块名。[可以指定多个模块]
                   默认为所有模块。
  -p/--persons:    指定某人、某些人，生成提交patch
  
HELP
}

e_(){
    echo -e "\\033[31m$*\\033[0m"
}
i_(){
    echo -e "\\033[32m$*\\033[0m"
}
w_(){
    echo -e "\\033[33m$*\\033[0m"
}

chk_exit(){
    if (( 0 != $? )); then exit 0; fi
}

# 参数有效性验证
# -d TARGET_DIR
# -m REPO_MODULES
parse_args ()
{
    flag=
    for arg in $*; do
        if [ "$arg" = "-h" -o "$arg" = "--help" ]; then
            print_help
            return 1
        elif [ "$arg" = "-d" -o "$arg" = "--directory" ]; then
            flag=d
        elif [ "$arg" = "-m" -o "$arg" = "--module" ]; then
            flag=m
        elif [ "$arg" = "-p" -o "$arg" = "--persons" ]; then
            flag=p
        else
            if [[ $arg = -* ]]; then
                e_ "非法参数\"$arg\""
                return 1
            fi
            if [ "$flag" = "d" ]; then
                TARGET_DIR="$arg"
            elif [ "$flag" = "m" ]; then
                REPO_MODULES+="$arg "
            elif [ "$flag" = "p" ]; then
                PERSON_LIST+="$arg "
            fi
        fi
    done
}

check_in_repo(){
    if [ ! -d ".repo" ]; then
        e_ "请在repo目录下执行脚本"
        return 1
    fi
}

# REPO_MODULES
read_repo_modules(){
    REPO_MODULES=
    while read line; do
        line=${line%:*}
        REPO_MODULES+="$line "
    done < $repo_list
}

# 检查-m/--modules参数是否有效
# 有效解析为目录形式存储到REPO_MODULES,无效返回
check_arg_repo_modules(){
    if [ -n "$REPO_MODULES" ]; then
        modules=
        for module in $REPO_MODULES; do
            # 若所给参数以"/"结尾，删掉"/"
            if [[ $module = */ ]]; then
                module=${module%*/}
            fi
            found=false
            while read line; do
                if [[ $line = *$module* ]]; then
                    line=${line%:*}
                    modules+="$line "
                    found=true
                fi
            done < $repo_list
            if [ $found = false ]; then
                e_ "没有这个模块：\"$module\""
                return 1
            fi
        done
        REPO_MODULES=$modules
    fi
}

check_modules_availability(){
    modules=
    for item in $REPO_MODULES; do
        if [ ! -d $item ]; then
            e_ "当前目录下没有找到路径\"$item\",怀疑不是完整的repo目录，建议执行'repo sync'。"
            read -p "回车忽略此目录,\"CTRL-C\"中止"
        else
            modules+="$item "
        fi
    done
    REPO_MODULES=$modules
}

anali_default_args(){

    if [ -z "$TARGET_DIR" ]; then
        TARGET_DIR=$DEFAULT_TARGET_DIR
    fi
    if [ -z "$PERSON_LIST" ]; then
        PERSON_LIST=$DEFAULT_PERSON_LIST
    fi

    if [ ! -d $TARGET_DIR ]; then
        mkdir $TARGET_DIR
    else
        if [ -n "`ls $TARGET_DIR`" ]; then
            w_ "\"$TARGET_DIR\"中的内容将会被清除!"
            read -p "回车继续,\"CTRL-C\"中止"
            rm -r $TARGET_DIR/*
        fi
    fi

    # 先将模块信息输出到文件
    repo_list=$TARGET_DIR/repo.list
    repo list > $repo_list

    if [ -z "$REPO_MODULES" ]; then
        read_repo_modules
        chk_exit
    else
        check_arg_repo_modules
        chk_exit
    fi
    check_modules_availability
    chk_exit
    if [ -n "$TARGET_DIR" ]; then
        echo 文件输出目录：$TARGET_DIR
    fi
    if [ -n "$REPO_MODULES" ]; then
        echo 将会解析以下模块：$REPO_MODULES
    fi
    if [ -n "$PERSON_LIST" ]; then
        echo 人员名单：$PERSON_LIST
    fi
}

parse_modules(){
    mypwd=`pwd`
    for module in $REPO_MODULES; do
        cd $mypwd
        target_dir=$mypwd/$TARGET_DIR/$module
        cd $module
        echo $module
        git_log=$mypwd/$TARGET_DIR/git.log
        git log > $git_log
        while read line; do
            if [[ $line = commit* ]]; then
                commit=${line#* }
            elif [[ $line = Author:* ]]; then
                author_in_list=false
                for person in $PERSON_LIST; do
                    if [[ $line = *$person@* ]]; then
                        author_in_list=true
                        break
                    fi
                done
            elif [[ $line = *Request-Id:* ]]; then
                line=${line#*: }
                if [ $author_in_list = true ]; then
                    mkdir -p $target_dir
                    git show $commit > $target_dir/"$person-${line:0:13}-${commit:0:6}"
                fi
            fi
        done < $git_log
    done
    cd $mypwd
}

clean_up_file(){
    rm $git_log
    rm $repo_list
}

DEFAULT_PERSON_LIST="liubzh zhuys xiewy langxw wb032 wb036 yujie shenyan wangdsh zouchl wangqch"
DEFAULT_TARGET_DIR="diff_gen"

parse_args $*
chk_exit
check_in_repo
chk_exit
anali_default_args
chk_exit
parse_modules
chk_exit
clean_up_file
chk_exit
