
# Markdown 解释器环境搭建

## python-markdown2
Github: https://github.com/trentm/python-markdown2
基础解释器选择 markdown2
安装方法如下：
```bash
sudo pip install markdown2
```
**NOTE** 需要 sudo 权限

## npm
Github: https://github.com/npm/npm
安装方法如下：
```bash
sudo apt-get install npm
```

## bower
Github: https://github.com/bower/bower
安装方法如下：
```bash
sudo npm install -g bower
```
**NOTE** 需要 sudo 权限

## sequence-diagrams.js
Github: https://github.com/bramp/js-sequence-diagrams

建一个绘制图标专用的 bower-home 目录，然后克隆代码：
```bash
$ mkdir ~/github/bower-home-diagram
$ cd ~/github/bower-home-diagram
$ git clone https://github.com/bramp/js-sequence-diagrams.git
$ bower install js-sequence-diagrams
$ cd bower_components
$ ls
bower-webfontloader  js-sequence-diagrams  raphael   underscore
eve-raphael          lodash                snap.svg
$ pwd
```
可以看到下载好的组件，这个路径就定为我们的 bower-home

执行 `bower install` 可能会遇到以下错误：
```bash
/usr/bin/env: node: No such file or directory
```

原因是环境变量中无法找到 node 命令，可用以下方式解决：
```bash
$ sudo ln -s /usr/bin/nodejs /usr/bin/node
```

## jquery
如果需要使用 jquery 需安装，这里使用 bower 进行安装：
```bash
bower install jquery
```
******

**以上这些步骤都是让我们了解到我们用到了哪些项目，使用最新版本需要慎重，测试没问题再进行使用。**

## 为确保绘制正常，我们使用官网推荐的 js 库：
详情见：https://bramp.github.io/js-sequence-diagrams/
在介绍中直接下载引用：
```html
<script src="webfont.js"></script>
<script src="snap.svg-min.js"></script>
<script src="underscore-min.js"></script>
<script src="sequence-diagram-min.js"></script>
```

## flowchart
Github: https://github.com/adrai/flowchart.js
绘制流程图需要使用 flowchart.js，安装方式如下：
```bash
bower install flowchart
```

## HTML 转换为 PDF 文档
```bash
sudo apt install wkhtmltopdf
wkhtmltopdf --help
```
**经过测试，wkhtmltopdf 这个命令版本不同也可能造成导出绘制 UML 图失败，所以当不能正常输出时，考虑更新版本**

## 其它
另外：此目录下的两个命令 md 以及 md.sh
md: 这个是引用的当前目录 scripts 下的库文件，已经经过测试，可以正常使用
md.sh: 是尝试使用最新版本的库进行配置，也就是以上提到的 bower 进行安装，但相互协作尚未通过验证，可后续进行学习。
